import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:oratio_app/bloc/profile_cubit/profile_data_cubit.dart';
import 'package:oratio_app/popup_notification/popup_notification.dart';
import 'package:oratio_app/services/chat/chat_service.dart';
import 'package:oratio_app/services/file_downloader.dart';
import 'package:oratio_app/ui/pages/chat_page.dart';
import 'package:pocketbase/pocketbase.dart';
import 'dart:async';
import 'dart:isolate';

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
  Timer? _resubscribeTimer;
  Isolate? _resubscribeIsolate;
  ReceivePort? _receivePort;

  ChatCubit(this._chatService, this._pb) : super(ChatInitial());

  // Fetch recent chats
  Future<void> loadRecentChats() async {
    try {
      if (state is! ChatsLoaded) {
        emit(ChatLoading());
      }
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
    BuildContext? context,
  }) async {
    final currentUserId = _pb.authStore.model.id;

    try {
      // example create body
      final body = <String, dynamic>{
        "sender": currentUserId,
        'message': message,
        "read": false,
        "reciever": receiverId
      };

      if (context != null) {
        FileDownloadHandler.showDownloadProgress(context, 0);
      }

      final record = await _pb.collection('messages').create(body: body);

      if (context != null) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context != null) {
        Navigator.of(context).pop();
      }
      final err = e as ClientException;
      emit(ChatError('Failed to send message: ${err.originalError}'));
      rethrow;
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String otherParticipantId) async {
    if (!_pb.authStore.isValid) return;
    final currentUserId = _pb.authStore.model.id;

    try {
      // Get unread messages from messages collection
      final result = await _pb.collection('messages').getList(
            filter:
                'reciever = "$currentUserId" && sender = "$otherParticipantId" && read = false',
          );

      // Mark each message as read in messages collection
      for (final message in result.items) {
        await _pb.collection('messages').update(message.id, body: {
          'read': true,
        });
      }

      // Refresh chat list to reflect changes
      await loadRecentChats();
    } catch (e) {
      emit(ChatError('Failed to mark messages as read: $e'));
      rethrow;
    }
  }

  // Stream real-time updates for new messages
  void subscribeToMessages(BuildContext context) {
    if (!_pb.authStore.isValid) return;
    final currentUserId = (_pb.authStore.model as RecordModel).id;
    _pb.collection('messages').subscribe('*', (e) {
      loadRecentChats();

      if (e.action == 'create' && e.record != null) {
        final message = e.record!;
        if (message.getStringValue('sender') != currentUserId) {
          String msg = message.getStringValue('message');
          if (msg == "{{file}}") {
            msg = 'sent you a file';
          }
        }
      }
    },
        filter: 'sender = "$currentUserId" || reciever = "$currentUserId"',
        expand: 'sender');

    // Start the resubscribe timer
    _startResubscribeTimer(context);
  }

  void _startResubscribeTimer(BuildContext context) {
    _resubscribeTimer?.cancel();
    _resubscribeTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _resubscribeIsolate?.kill(priority: Isolate.immediate);
      _receivePort?.close();
      _receivePort = ReceivePort();
      Isolate.spawn(_resubscribeIsolateEntry, _receivePort!.sendPort)
          .then((isolate) {
        _resubscribeIsolate = isolate;
        _receivePort!.listen((message) {
          if (message == 'resubscribe') {
            subscribeToMessages(context);
          }
        });
      });
    });
  }

  static void _resubscribeIsolateEntry(SendPort sendPort) {
    Timer(const Duration(minutes: 1), () {
      sendPort.send('resubscribe');
    });
  }

  RecordModel get currentUser => _pb.authStore.model;

  int unreadCount({required bool isFriend}) {
    if (state is ChatsLoaded) {
      final currentUser = _pb.authStore.model as RecordModel;
      return (state as ChatsLoaded)
          .chats
          .where((chat) => chat.isFriend(currentUser) == isFriend && chat.unreadCount > 0)
          .length;
    }
    return 0;
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
    _resubscribeTimer?.cancel();
    _resubscribeIsolate?.kill(priority: Isolate.immediate);
    _receivePort?.close();
    return super.close();
  }

  Future<void> logout() async {
    _pb.collection('messages').unsubscribe('*');
    _resubscribeTimer?.cancel();
    _resubscribeIsolate?.kill(priority: Isolate.immediate);
    _receivePort?.close();
    emit(ChatInitial());
  }
}
