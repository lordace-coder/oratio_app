// message_cubit.dart
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oratio_app/services/chat/db/chat_hive.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:uuid/uuid.dart';

class MessageState {
  final List<MessageModel> messages;
  final bool isLoading;
  final String? error;

  MessageState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  MessageState copyWith({
    List<MessageModel>? messages,
    bool? isLoading,
    String? error,
  }) {
    return MessageState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// message_cubit.dart
class MessageCubit extends Cubit<MessageState> {
  final MessageRepository repository;
  final PocketBase pb;
  StreamSubscription? _subscription;

  MessageCubit({
    required this.repository,
    required this.pb,
  }) : super(MessageState()) {
    _initMessageSubscription();
  }

  UnsubscribeFunc? _unsubscribe;

  void _initMessageSubscription() async {
    final currentUserId = pb.authStore.model.id;
    await pb.collection('messages').subscribe(
      '*',
      (e) {
        if (e.action == 'create' && e.record != null) {
          final message = MessageModel.fromPocketBase(e.record!);
          _handleNewMessage(message);
        }
      },
      filter: 'sender.id = "$currentUserId" || reciever.id = "$currentUserId"',
    );
  }

  Future<void> loadMessages(String otherUserId) async {
    try {
      emit(state.copyWith(isLoading: true));

      final currentUserId = pb.authStore.model.id;
      final response = await pb.collection('messages').getFullList(
            sort: '-created',
            filter:
                'reciever.id = "$otherUserId" || sender.id = "$otherUserId"',
          );
      final messages =
          response.map((item) => MessageModel.fromPocketBase(item)).toList();
      emit(state.copyWith(
        messages: messages,
        isLoading: false,
      ));

      // Mark messages as read after loading
      await markMessagesAsRead(otherUserId);
    } catch (e) {
      print(e);
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> sendMessage({
    required String message,
    required String receiverId,
  }) async {
    try {
      final currentUserId = pb.authStore.model.id;
      final newMessage = MessageModel(
        id: const Uuid().v4(),
        senderId: currentUserId,
        receiverId: receiverId,
        message: message,
        created: DateTime.now(),
        read: true,
      );

      // Save locally first
      await repository.saveUnreceivedMessage(newMessage);

      // Try to send to PocketBase
      try {
        await pb.collection('messages').create(body: newMessage.toJson());
        await repository.markMessageAsReceived(newMessage.id);
      } catch (e) {
        // Message will remain in local storage if send fails
        print('Failed to send message: $e');
      }

      // Update state with new message
      final updatedMessages = [newMessage, ...state.messages];
      emit(state.copyWith(messages: updatedMessages));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> markMessagesAsRead(String senderId) async {
    try {
      final currentUserId = pb.authStore.model.id;
      await pb.collection('messages').update(
        'filter=sender.id = "$senderId" && reciever.id = "$currentUserId" && read = false',
        body: {'read': true},
      );

      // Update local state
      final updatedMessages = state.messages.map((msg) {
        if (msg.senderId == senderId && !msg.read) {
          return msg.copyWith(read: true);
        }
        return msg;
      }).toList();

      emit(state.copyWith(messages: updatedMessages));
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  void _handleNewMessage(MessageModel message) {
    if (!state.messages.any((msg) => msg.id == message.id)) {
      final updatedMessages = [message, ...state.messages];
      emit(state.copyWith(messages: updatedMessages));
    }
  }
}
