// message_cubit.dart
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oratio_app/services/chat/db/chat_hive.dart';
import 'package:oratio_app/services/reporting_service.dart';
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
  }) : super(MessageState());

  // Removed global subscription - each chat page handles its own subscription
  // void _initMessageSubscription() async {
  //   if (!pb.authStore.isValid) return;
  //   final currentUserId = pb.authStore.model.id;
  //   await pb.collection('messages').subscribe(
  //     '*',
  //     (e) {
  //       if (e.action == 'create' && e.record != null) {
  //         if (e.record?.getStringValue("sender") == currentUserId.toString()) {
  //           return;
  //         }
  //         final message = MessageModel.fromPocketBase(e.record!);
  //         _handleNewMessage(message);
  //       }
  //     },
  //     filter: 'sender.id = "$currentUserId" || reciever.id = "$currentUserId"',
  //   );
  // }

  void _unsubscribe() {
    pb.collection('messages').unsubscribe();
  }

  Future<void> loadMessages(String otherUserId, {bool showLoading = false}) async {
    try {
      // Don't emit loading state to prevent flickering
      if (!pb.authStore.isValid) return;

      final response = await pb.collection('messages').getFullList(
            sort: '-created',
            filter:
                '(reciever = "$otherUserId" && sender = "${pb.authStore.model.id}") || (reciever = "${pb.authStore.model.id}" && sender = "$otherUserId")',
          );
      final messages =
          response.map((item) => MessageModel.fromPocketBase(item)).toList();

      emit(state.copyWith(
        messages: messages,
        isLoading: false,
        error: null,
      ));

      // Mark messages as received directly (removed isolate)
      await _markMessagesAsReceived(messages);

      // Cache messages
      await _cacheMessages(otherUserId, messages);
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  Future<void> _markMessagesAsReceived(List<MessageModel> messages) async {
    try {
      for (var msg in messages) {
        if (!msg.received) {
          repository.messageBox.add(msg);
          await pb
              .collection("messages")
              .update(msg.id, body: {"received": true});
        }
      }
    } catch (e) {
      // Silently fail - not critical
      print('Error marking messages as received: $e');
    }
  }

  Future<void> _cacheMessages(
      String userId, List<MessageModel> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedMessages =
        messages.map((msg) => jsonEncode(msg.toJson())).toList();
    await prefs.setStringList('cached_messages_$userId', encodedMessages);
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
    } catch (e) {}
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
      // Update state with new message
      final updatedMessages = [newMessage, ...state.messages];
      emit(state.copyWith(messages: updatedMessages));
      // Save locally first
      // await repository.saveUnreceivedMessage(newMessage);

      // Try to send to PocketBase
      try {
        await pb.collection('messages').create(body: {
          "sender": currentUserId,
          "message": newMessage.message,
          "reciever": receiverId,
        });
      } catch (e) {
        // Message will remain in local storage if send fails
        rethrow;
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> markMessagesAsRead(String otherParticipantId) async {
    if (!pb.authStore.isValid) return;
    final currentUserId = pb.authStore.model.id;

    try {
      // Get unread messages
      final result = await pb.collection('messages').getList(
            filter:
                'reciever = "$currentUserId" && sender = "$otherParticipantId" && read = false',
          );

      // Mark each message as read
      for (final message in result.items) {
        await pb.collection('messages').update(message.id, body: {
          'read': true,
        });
      }

      // Refresh chat list
      await loadMessages(otherParticipantId);
    } catch (e) {
      emit(state.copyWith(
        error: 'Failed to mark messages as read: $e',
      ));
    }
  }

  void _handleNewMessage(MessageModel message) {
    if (!state.messages.any((msg) => msg.id == message.id)) {
      final updatedMessages = [message, ...state.messages];
      emit(state.copyWith(messages: updatedMessages));
    }
  }

  void clearMessages() {
    emit(MessageState());
  }

  void logout() {
    _unsubscribe();
    emit(MessageState());
  }
}
