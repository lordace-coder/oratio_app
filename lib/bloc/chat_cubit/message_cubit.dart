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

  MessageCubit({
    required this.repository,
    required this.pb,
  }) : super(MessageState()) {
    _initMessageSubscription();
  }

  void _initMessageSubscription() async {
    if (!pb.authStore.isValid) return;
    final currentUserId = pb.authStore.model.id;
    print('${currentUserId}---userid');
    await pb.collection('messages').subscribe(
      '*',
      (e) {
        if (e.action == 'create' && e.record != null) {
          if (e.record?.getStringValue("sender") == currentUserId.toString()) {
            return;
          }
          final message = MessageModel.fromPocketBase(e.record!);
          _handleNewMessage(message);
        }
      },
      filter: 'sender.id = "$currentUserId" || reciever.id = "$currentUserId"',
    );
  }

  void _unsubscribe() {
    pb.collection('messages').unsubscribe();
  }

  Future<void> loadMessages(String otherUserId) async {
    try {
      emit(state.copyWith(isLoading: true));

      if (!pb.authStore.isValid) return;
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
      // save all messages
      messages.map((msg) async {
        if (msg.received) {
          return;
        }
        repository.messageBox.add(msg);
        // *UPDATE MODEL RECIEVED TO TRUE
        await pb
            .collection("messages")
            .update(msg.id, body: {"recieved": true});
      });

      // Mark messages as read after loading
      await markMessagesAsRead();
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future getSavedMessages(String otherUserId) async {
    try {
      emit(MessageState(
        messages: [],
        isLoading: true,
      ));
      final results = await repository.getUnreceivedMessages(otherUserId);
      emit(MessageState(
        messages: results,
      ));
    } catch (e) { 
      
     }
  }

  Future<void> sendMessage({
    required String message,
    required String receiverId,
  }) async {
    try {
      if (!pb.authStore.isValid) return;
      final currentUserId = pb.authStore.model.id;
      final newMessage = MessageModel(
        id: const Uuid().v4(),
        senderId: currentUserId,
        receiverId: receiverId,
        message: message,
        created: DateTime.now(),
        read: false,
      );

      // Save locally first
      // await repository.saveUnreceivedMessage(newMessage);

      // Try to send to PocketBase
      try {
        await pb.collection('messages').create(body: {
          "sender": currentUserId,
          "message": newMessage.message,
          "reciever": receiverId,
        });
        // await repository.markMessageAsReceived(newMessage.id);
      } catch (e) {
        // Message will remain in local storage if send fails
        rethrow;
      }

      // Update state with new message
      final updatedMessages = [newMessage, ...state.messages];
      emit(state.copyWith(messages: updatedMessages));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> markMessagesAsRead() async {
    try {
      if (!pb.authStore.isValid) return;
      final currentUserId = pb.authStore.model.id;

      for (var msg in state.messages) {
        if (msg.read || msg.senderId == currentUserId) continue;
        await pb.collection('messages').update(
          msg.id,
          body: {'read': true},
        );
      }

      // emit(state.copyWith(messages: updatedMessages));
    } catch (e) {}
  }

  void _handleNewMessage(MessageModel message) {
    if (!state.messages.any((msg) => msg.id == message.id)) {
      final updatedMessages = [message, ...state.messages];
      emit(state.copyWith(messages: updatedMessages));
    }
  }

  void logout() {
    _unsubscribe();
    emit(MessageState());
  }
}
