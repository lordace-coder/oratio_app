import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:oratio_app/bloc/profile_cubit/profile_data_cubit.dart';
import 'package:oratio_app/popup_notification/popup_notification.dart';
import 'package:oratio_app/services/chat/chat_service.dart';
import 'package:oratio_app/ui/pages/chat_page.dart';
import 'package:pocketbase/pocketbase.dart';

// Chat State
abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}

class ChatsLoaded extends ChatState {
  final List<ChatPreview> chats;

  const ChatsLoaded(this.chats);

  @override
  List<Object?> get props => [chats];
}

// Chat Cubit
class ChatCubit extends Cubit<ChatState> {
  final ChatService _chatService;
  final PocketBase _pb;

  ChatCubit(this._chatService, this._pb) : super(ChatInitial());

  // Fetch recent chats
  Future<void> loadRecentChats() async {
    try {
      emit(ChatLoading());
      final chats = await _chatService.getRecentChats();
      emit(ChatsLoaded(chats));
    } catch (e) {
      emit(ChatError('Failed to load chats: $e'));
    }
  }

  // Send a new message
  Future<void> sendMessage({
    required String receiverId,
    required String message,
  }) async {
    final currentUserId = _pb.authStore.model.id;

    try {
      //   final currentUserId = _pb.authStore.model.id;
      //   'sender': currentUserId,
      //   'receiver': receiverId,
      //   'message': message,
      //   'read': false,
      // });
      // example create body
      final body = <String, dynamic>{
        "sender": currentUserId,
        'message': message,
        "read": false,
        "reciever": receiverId
      };

      final record = await _pb.collection('messages').create(body: body);
      // Refresh chat list after sending message
      await loadRecentChats();
    } catch (e) {
      final err = e as ClientException;
      emit(ChatError('Failed to send message: ${err.originalError}'));
      rethrow;
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String otherParticipantId) async {
    try {
      final currentUserId = _pb.authStore.model.id;

      // Get unread messages
      final result = await _pb.collection('messages').getList(
            filter:
                'reciever = "$currentUserId" && sender = "$otherParticipantId" && read = false',
          );

      // Mark each message as read
      for (final message in result.items) {
        await _pb.collection('messages').update(message.id, body: {
          'read': true,
        });
      }

      // Refresh chat list
      await loadRecentChats();
    } catch (e) {
      print(e);
      emit(ChatError('Failed to mark messages as read: $e'));
    }
  }

  // Stream real-time updates for new messages
  void subscribeToMessages(BuildContext context) {
    final currentUserId = (_pb.authStore.model as RecordModel).id;
    _pb.collection('messages').subscribe('*', (e) {
      if (e.action == 'create') {
        // Check if the message involves the current user

        if (e.record == null) {
          return;
        }
        final message = e.record!;
        if (e.record?.getStringValue('sender') != currentUserId) {
          String msg = e.record!.getStringValue('message');
          if (msg == "{{file}}") {
            msg = 'sent you a file';
          }
          PopupNotification.show(
            onTap: () async {
              await context
                  .read<ProfileDataCubit>()
                  .visitProfile(e.record!.getStringValue('sender'));
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatPage(
                      profile: (context.read<ProfileDataCubit>().state
                              as ProfileDataLoaded)
                          .guestProfile!),
                ),
              );
            },
            title:
                '${message.expand['sender']?.first.getStringValue('username')} :',
            message: msg,
            icon: FontAwesomeIcons.message,
          );
        }
        if (message.data['sender'] == currentUserId ||
            message.data['receiver'].toString().contains(currentUserId)) {
          loadRecentChats(); // Refresh chat list when new message arrives
        }

        loadRecentChats();
      }
    },
        filter:
            'sender.id = "$currentUserId" || reciever.id = "$currentUserId"',
        expand: 'sender');
  }

  RecordModel get currentUser => _pb.authStore.model;
  int unreadCount(bool friend) {
    int count = 0;
    if (friend) {
      getRecentChats().forEach((item) {
        if (item.unreadCount > 0) {
          count++;
        }
      });
    } else {
      getMessageRequests().forEach((item) {
        if (item.unreadCount > 0) {
          count++;
        }
      });
    }

    return count;
  }

  List<ChatPreview> getRecentChats() {
    if (state is ChatsLoaded) {
      return (state as ChatsLoaded)
          .chats
          .where((chat) => chat.isFriend(currentUser))
          .toList();
    }
    return [];
  }



  List<ChatPreview> getMessageRequests() {
    if (state is ChatsLoaded) {
      return (state as ChatsLoaded)
          .chats
          .where((chat) => !chat.isFriend(currentUser))
          .toList();
    }
    return [];
  }

  @override
  Future<void> close() {
    _pb.collection('messages').unsubscribe('*');
    return super.close();
  }

  Future<void> logout()async{
     _pb.collection('messages').unsubscribe('*');
     emit(ChatInitial());
  }
}
