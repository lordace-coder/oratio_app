// ignore_for_file: public_member_api_docs, sort_constructors_first
// message_model.g.dart
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pocketbase/pocketbase.dart';

part 'chat_hive.g.dart';

@HiveType(typeId: 0)
class MessageModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String senderId;

  @HiveField(2)
  final String receiverId;

  @HiveField(3)
  final String message;

  @HiveField(4)
  final String? filePath;

  @HiveField(5)
  final DateTime created;

  @HiveField(6)
  bool received;

  @HiveField(7)
  bool read;

  MessageModel({
    required this.id,
    required this.read,
    required this.senderId,
    required this.receiverId,
    required this.message,
    this.filePath,
    required this.created,
    this.received = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      senderId: json['sender'],
      receiverId: json['reciever'],
      message: json['message'],
      filePath: json['file'],
      created: DateTime.parse(json['created']),
      received: json['recieved'] ?? false,
      read: json['read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': senderId,
      'reciever': receiverId,
      'message': message,
      'file': filePath,
      'created': created.toIso8601String(),
      'recieved': received,
    };
  }

  MessageModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? message,
    String? filePath,
    DateTime? created,
    bool? received,
    bool? read,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      message: message ?? this.message,
      filePath: filePath ?? this.filePath,
      created: created ?? this.created,
      received: received ?? this.received,
      read: read ?? this.read,
    );
  }

  factory MessageModel.fromPocketBase(RecordModel record) {
    return MessageModel(
      id: record.id,
      senderId: record.getStringValue('sender'), // or record.data['sender']
      receiverId: record.getStringValue(
          'reciever'), // note the spelling 'reciever' matches your schema
      message: record.getStringValue('message'),
      filePath: record.getStringValue('file'),
      created: DateTime.parse(record.created),
      received: record.getBoolValue('recieved'),
      read: record.getBoolValue(
          'read'), // note the spelling 'recieved' matches your schema
    );
  }
}

// message_repository.dart

class MessageRepository {
  final PocketBase pocketBase;
  final Box<MessageModel> messageBox;

  MessageRepository({
    required this.pocketBase,
    required this.messageBox,
  });

  Future<void> saveUnreceivedMessage(MessageModel message) async {
    await messageBox.put(message.id, message);
  }

  Future<void> markMessageAsReceived(String messageId) async {
    final message = messageBox.get(messageId);
    if (message != null) {
      message.received = true;
      await message.save();

      // Update in PocketBase
      await pocketBase.collection('messages').update(
        messageId,
        body: {'recieved': true},
      );
    }
  }

  Future<List<MessageModel>> getUnreceivedMessages(String otherUserId) async {
    print(['hive saved', messageBox.values.map((i) => i.message).toList()]);
    return messageBox.values
        .where((message) => (message.receiverId == otherUserId ||
            message.senderId == otherUserId))
        .toList();
  }
}
