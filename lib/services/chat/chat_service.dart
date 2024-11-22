import 'dart:convert';
import 'package:oratio_app/bloc/profile_cubit/profile_data_cubit.dart';
import 'package:pocketbase/pocketbase.dart';

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
      print(messages);
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

        // Create or update chat preview
        if (!chatMap.containsKey(otherParticipantId)) {
          chatMap[otherParticipantId] = ChatPreview(
            participant: otherParticipantId,
            unreadCount: 0,
            preview: message.getStringValue('message'),
            lastMessageAt: DateTime.parse(message.created),
            profile: profile,
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
            preview: _truncateMessage(message.getStringValue('message')),
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

  ChatPreview({
    required this.participant,
    required this.unreadCount,
    required this.preview,
    required this.lastMessageAt,
    required this.profile,
  });

  ChatPreview copyWith({
    String? participant,
    int? unreadCount,
    String? preview,
    DateTime? lastMessageAt,
    Profile? profile,
  }) {
    return ChatPreview(
      participant: participant ?? this.participant,
      unreadCount: unreadCount ?? this.unreadCount,
      preview: preview ?? this.preview,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      profile: profile ?? this.profile,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'participant': participant,
      'unreadCount': unreadCount,
      'preview': preview,
      'lastMessageAt': lastMessageAt.millisecondsSinceEpoch,
      'profile': {
        'userId': profile.userId,
        'contact': profile.contact,
      },
    };
  }

  factory ChatPreview.fromMap(Map<String, dynamic> map) {
    return ChatPreview(
      participant: map['participant'] as String,
      unreadCount: map['unreadCount'] as int,
      preview: map['preview'] as String,
      lastMessageAt:
          DateTime.fromMillisecondsSinceEpoch(map['lastMessageAt'] as int),
      profile: Profile(
        user: map['profile']['user'] as RecordModel,
        userId: map['profile']['userId'] as String,
        parish: (map['profile']['parish'] as List<dynamic>)
            .map((e) => e as RecordModel)
            .toList(),
        contact: map['profile']['contact'] as String,
        community: (map['profile']['community'] as List<dynamic>)
            .map((e) => e as RecordModel)
            .toList(),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatPreview.fromJson(String source) =>
      ChatPreview.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ChatPreview(participant: $participant, unreadCount: $unreadCount, preview: $preview, lastMessageAt: $lastMessageAt, profile: $profile)';
  }

  @override
  bool operator ==(covariant ChatPreview other) {
    if (identical(this, other)) return true;

    return other.participant == participant &&
        other.unreadCount == unreadCount &&
        other.preview == preview &&
        other.lastMessageAt == lastMessageAt &&
        other.profile == profile;
  }

  @override
  int get hashCode {
    return participant.hashCode ^
        unreadCount.hashCode ^
        preview.hashCode ^
        lastMessageAt.hashCode ^
        profile.hashCode;
  }
}
