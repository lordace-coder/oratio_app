// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:isolate';

import 'package:pocketbase/pocketbase.dart';

import 'package:oratio_app/bloc/profile_cubit/profile_data_cubit.dart';

class ChatService {
  final PocketBase pb;
  ChatService(this.pb);

  Future<List<ChatPreview>> getRecentChats() async {
    try {
      if (!pb.authStore.isValid) return [];
      final currentUserId = (pb.authStore.model as RecordModel).id;
      final recentChats = await pb.collection('recent_chats').getList(
            page: 1,
            perPage: 50,
            filter: 'members ~ "$currentUserId"',
            expand: 'members,sender',
            sort: '-updated',
          );

      final Map<String, ChatPreview> chatMap = {};

      return recentChats.items.map<ChatPreview>((chat) {
        final bool isSender = chat.expand['sender']![0].id == currentUserId;
        final RecordModel otherParticipant = isSender
            ? chat.expand['members']!
                .firstWhere((member) => member.id != currentUserId)
            : chat.expand['sender']![0];
        final String otherParticipantId = otherParticipant.id;

        final Profile profile = Profile(
          user: otherParticipant,
          userId: otherParticipantId,
          parish: [],
          contact: otherParticipant.getStringValue('phone_number'),
          community: [],
        );

        String msg = chat.getStringValue('message');

        if (msg == '{{file}}') {
          msg = chat.getStringValue('file');
        } else {
          // HANDLE META MESAGES (like contacts sent etc)
          try {
            if (jsonDecode(msg) is Map) {
              final metaMessage = jsonDecode(msg) as Map;
              if (metaMessage['metadata'] == 'contact') {
                msg = "Contact Info : ${metaMessage['first_name']}";
              }
            }
          } catch (e) {
            // Invalid JSON, use message as is
          }
        }
        String messagePreview = isSender ? 'You: $msg' : msg;

        bool active = otherParticipant.getBoolValue('active');
        String? lastSeen = otherParticipant.getStringValue('last_seen');
        if (lastSeen.isEmpty) {
          lastSeen = null;
        }

        if (!chatMap.containsKey(otherParticipantId)) {
          chatMap[otherParticipantId] = ChatPreview(
            participant: otherParticipantId,
            unreadCount: 0,
            preview: _truncateMessage(messagePreview),
            lastMessageAt: DateTime.parse(chat.created).toLocal(),
            profile: profile,
            read: isSender ? chat.getBoolValue('read') : false,
            isSender: isSender,
            active: active,
          );
        }

        if (!chat.getBoolValue('read') && !isSender) {
          chatMap[otherParticipantId]!.unreadCount++;
        }

        if (chatMap[otherParticipantId]!
            .lastMessageAt
            .isBefore(DateTime.parse(chat.updated).toLocal())) {
          chatMap[otherParticipantId] = chatMap[otherParticipantId]!.copyWith(
            preview: _truncateMessage(messagePreview),
            lastMessageAt: DateTime.parse(chat.created).toLocal(),
          );
        }
        return chatMap[otherParticipantId]!;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  String _truncateMessage(String message) {
    // Implement the message truncation logic here
    return message.length > 50 ? '${message.substring(0, 50)}...' : message;
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
  bool active = false;
  String? lastSeen;
  ChatPreview({
    required this.participant,
    required this.unreadCount,
    required this.preview,
    required this.lastMessageAt,
    required this.profile,
    this.read,
    this.lastSeen,
    required this.active,
    required this.isSender,
  });

  ChatPreview copyWith({
    String? participant,
    int? unreadCount,
    bool active = false,
    String? preview,
    DateTime? lastMessageAt,
    Profile? profile,
    bool? read,
    bool? isSender,
  }) {
    return ChatPreview(
      participant: participant ?? this.participant,
      unreadCount: unreadCount ?? this.unreadCount,
      preview: preview ?? this.preview,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      profile: profile ?? this.profile,
      read: read ?? this.read,
      isSender: isSender,
      active: this.active,
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
    return profile.user.getListValue("followers").contains(currentUser.id) &&
        currentUser.getListValue("followers").contains(profile.userId);
  }
}
