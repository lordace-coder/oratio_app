// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:pocketbase/pocketbase.dart';

import 'package:oratio_app/bloc/profile_cubit/profile_data_cubit.dart';

class ChatService {
  final PocketBase pb;
  ChatService(this.pb);

  Future<List<ChatPreview>> getRecentChats() async {
    try {
      final currentUserId = (pb.authStore.model as RecordModel).id;
      final messages = await pb.collection('messages').getList(
            page: 1,
            perPage: 50,
            filter:
                'sender.id = "$currentUserId" || reciever.id = "$currentUserId"',
            expand: 'sender,reciever',
            sort: '-created',
          );

      final chatMap = <String, ChatPreview>{};

      for (final RecordModel message in messages.items) {
        // Determine the other participant
        final bool isSender = message.expand['sender']![0].id == currentUserId;
        final RecordModel otherParticipant = isSender
            ? message.expand['reciever']![0]
            : message.expand['sender']![0];
        final String otherParticipantId = otherParticipant.id;

        // Create profile for other participant
        final Profile profile = Profile(
          user: otherParticipant,
          userId: otherParticipantId,
          parish: [], // You'll need to fetch this from your actual data
          contact: otherParticipant.getStringValue('phone_number'),
          community: [], // You'll need to fetch this from your actual data
        );

        String msg = message.getStringValue('message');
        if (msg == '{{file}}') {
          msg = message.getStringValue('file');
        }
        // Format message preview with "You:" prefix if current user is sender
        String messagePreview = isSender ? 'You: $msg' : msg;

        // Create or update chat preview
        if (!chatMap.containsKey(otherParticipantId)) {
          chatMap[otherParticipantId] = ChatPreview(
            participant: otherParticipantId,
            unreadCount: 0,
            preview: _truncateMessage(messagePreview),
            lastMessageAt: DateTime.parse(message.created),
            profile: profile,
            read: isSender ? message.getBoolValue('read') : false,
            isSender: isSender,
          );
        }

        // Update unread count
        if (!message.getBoolValue('read') && !isSender) {
          chatMap[otherParticipantId]!.unreadCount++;
        }

        // Update most recent message preview
        if (chatMap[otherParticipantId]!
            .lastMessageAt
            .isBefore(DateTime.parse(message.created))) {
          chatMap[otherParticipantId] = chatMap[otherParticipantId]!.copyWith(
            preview: _truncateMessage(messagePreview),
            lastMessageAt: DateTime.parse(message.created),
          );
        }
      }

      // Convert map to sorted list
      return chatMap.values.toList()
        ..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
    } catch (e) {
      print('Error fetching recent chats: $e');
      return [];
    }
  }

  String _truncateMessage(String message, {int maxLength = 50}) {
    return message.length > maxLength
        ? '${message.substring(0, maxLength)}...'
        : message;
  }
}

class ChatPreview {
  final String participant;
  int unreadCount;
  final String preview;
  final DateTime lastMessageAt;
  final Profile profile;
  bool? read;
  bool? isSender;

  ChatPreview({
    required this.participant,
    required this.unreadCount,
    required this.preview,
    required this.lastMessageAt,
    required this.profile,
    this.read,
    required this.isSender,
  });

  ChatPreview copyWith(
      {String? participant,
      int? unreadCount,
      String? preview,
      DateTime? lastMessageAt,
      Profile? profile,
      bool? read,
      bool? isSender}) {
    return ChatPreview(
      participant: participant ?? this.participant,
      unreadCount: unreadCount ?? this.unreadCount,
      preview: preview ?? this.preview,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      profile: profile ?? this.profile,
      read: read ?? this.read,
      isSender: isSender,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'participant': participant,
      'unreadCount': unreadCount,
      'preview': preview,
      'lastMessageAt': lastMessageAt.millisecondsSinceEpoch,
      'profile': profile,
      'read': read,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'ChatPreview(participant: $participant, unreadCount: $unreadCount, preview: $preview, lastMessageAt: $lastMessageAt, profile: $profile, read: $read)';
  }

  @override
  bool operator ==(covariant ChatPreview other) {
    if (identical(this, other)) return true;

    return other.participant == participant &&
        other.unreadCount == unreadCount &&
        other.preview == preview &&
        other.lastMessageAt == lastMessageAt &&
        other.profile == profile &&
        other.read == read;
  }

  @override
  int get hashCode {
    return participant.hashCode ^
        unreadCount.hashCode ^
        preview.hashCode ^
        lastMessageAt.hashCode ^
        profile.hashCode ^
        read.hashCode;
  }

  bool isFriend(RecordModel currentUser) {
    print([
      currentUser.getStringValue('username'),
      profile.user.getListValue("followers"),
      currentUser.id,
      currentUser.getListValue("followers").contains(profile.userId)
    ]);
    return profile.user.getListValue("followers").contains(currentUser.id) &&
        currentUser.getListValue("followers").contains(profile.userId);
  }
}
