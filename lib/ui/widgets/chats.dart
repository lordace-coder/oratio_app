import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/properties/email.dart';
import 'package:flutter_contacts/properties/name.dart';
import 'package:flutter_contacts/properties/phone.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ace_toast/ace_toast.dart';
import 'package:oratio_app/services/contact_service.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/audio_message.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomBubble extends StatelessWidget {
  final types.Message message;
  final bool isUser;

  const CustomBubble({
    super.key,
    required this.message,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    Widget messageContent;

    if (message is types.TextMessage) {
      messageContent = _buildTextMessage(message as types.TextMessage);
    } else if (message is types.FileMessage) {
      final fileType = getFileMessageType((message as types.FileMessage).uri);
      switch (fileType) {
        case FileMessageType.image:
          messageContent = _buildImageMessage(message as types.FileMessage);
          break;
        case FileMessageType.audio:
          messageContent = _buildAudioMessage(message as types.FileMessage);
          break;
        case FileMessageType.document:
          messageContent = _buildDocumentMessage(message as types.FileMessage);
          break;
        case FileMessageType.video: // Add this case
          messageContent = VideoMessage(
            message: message as types.FileMessage,
            isUser: isUser,
          );
          break;
        default:
          messageContent =
              _buildGenericFileMessage(message as types.FileMessage);
      }
    } else if (message is types.CustomMessage) {
      messageContent = _buildContactMessage(message as types.CustomMessage);
    } else {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: messageContent,
      ),
    );
  }

  bool isValidJson(String str) {
    try {
      json.decode(str);
      return true;
    } catch (e) {
      return false;
    }
  }

  Widget _buildTextMessage(types.TextMessage message) {
    if (isValidJson(message.text)) {
      final json = jsonDecode(message.text) as Map<String, dynamic>;
      if (json.containsKey('metadata') && json['metadata'] == "contact") {
        return _buildContactMessage(types.CustomMessage(
          author: message.author,
          id: message.id,
          metadata: json,
          createdAt: message.createdAt,
        ));
      }
    }
    return Container(
      decoration: BoxDecoration(
        color: isUser
            ? AppColors.primary
            : const Color.fromARGB(255, 234, 234, 235),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isUser ? 12 : 0),
          topRight: Radius.circular(isUser ? 0 : 12),
          bottomLeft: const Radius.circular(12),
          bottomRight: const Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            message.text,
            style: TextStyle(
                fontSize: 16, color: isUser ? Colors.white : Colors.black),
          ),
          const SizedBox(height: 4),
          _buildUserTimestamp(message.createdAt!, isUser),
        ],
      ),
    );
  }

  Widget _buildImageMessage(types.FileMessage message) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 280, // Maximum width similar to WhatsApp
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isUser
              ? AppColors.primary
              : const Color.fromARGB(255, 234, 234, 235),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 300, // Maximum height for the image
                ),
                child: Image.network(
                  message.uri,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      width: 280,
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      width: 280,
                      height: 200,
                      child: Center(
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 32,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildUserTimestamp(message.createdAt!, isUser),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioMessage(types.FileMessage message) {
    return AudioMessageWidget(
      audioUrl: message.uri,
    );
  }

  Widget _buildDocumentMessage(types.FileMessage message) {
    return Container(
      decoration: BoxDecoration(
        color: isUser
            ? AppColors.primary
            : const Color.fromARGB(255, 234, 234, 235),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(90),
                    color: Colors.white.withOpacity(0.1)),
                child: const Icon(
                  FontAwesomeIcons.fileInvoice,
                  size: 18.5,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  message.name ?? 'Document',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${(message.size ?? 0) ~/ 1024} KB',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          _buildUserTimestamp(message.createdAt!, isUser),
        ],
      ),
    );
  }

  Widget _buildGenericFileMessage(types.FileMessage message) {
    return Container(
      decoration: BoxDecoration(
        color: isUser ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(90),
                    color: isUser
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1)),
                child: Icon(
                  FontAwesomeIcons.fileInvoice,
                  size: 18.5,
                  color: isUser ? Colors.white : Colors.black45,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  message.name ?? 'File',
                  style: TextStyle(
                      fontSize: 16, color: isUser ? Colors.white : null),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _buildUserTimestamp(message.createdAt!, isUser),
        ],
      ),
    );
  }

  Widget _buildContactMessage(types.CustomMessage message) {
    final contact = message.metadata;

    if (contact == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser
              ? AppColors.primary
              : const Color.fromARGB(255, 234, 234, 235),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          'Invalid contact data',
          style: TextStyle(
            fontSize: 16,
            color: isUser ? Colors.white : Colors.black,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isUser
            ? AppColors.primary
            : const Color.fromARGB(255, 234, 234, 235),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[300],
                child: Icon(
                  Icons.person,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact['name'] ?? contact['first_name'] ?? 'Unknown',
                    style: TextStyle(
                      fontSize: 16,
                      color: isUser ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    contact['phone'] ?? 'No phone number',
                    style: TextStyle(
                      fontSize: 14,
                      color: isUser ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (contact['email'].toString().isNotEmpty)
                    Text(
                      contact['email'] ?? 'No email',
                      style: TextStyle(
                        fontSize: 14,
                        color: isUser ? Colors.white : Colors.black,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildUserTimestamp(message.createdAt!, isUser),
              ElevatedButton.icon(
                onPressed: () => _saveContact(contact),
                icon: const Icon(Icons.save),
                label: const Text('Save'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: isUser ? AppColors.primary : Colors.white,
                  backgroundColor: isUser ? Colors.white : AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _saveContact(Map<String, dynamic> contact) async {
    final firstName = contact['first_name'] ?? '';
    final lastName = contact['last_name'] ?? '';
    final phone = contact['phone'] ?? '';
    final email = contact['email'] ?? '';

    final newContact = Contact(
      name: Name(first: firstName, last: lastName),
      displayName: '$firstName $lastName',
      phones: [Phone(phone, customLabel: '$firstName $lastName')],
      emails: [Email(email)],
    );

    try {
      await newContact.insert();
      NotificationService.showInfo("Contact saved successfully");
    } catch (e) {
      NotificationService.showError("Error saving contact");
    }
  }

  Widget _buildUserTimestamp(int timestamp, bool isUser) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatTime(timestamp),
          style: TextStyle(
            fontSize: 12,
            color: isUser
                ? Colors.white.withOpacity(0.5)
                : Colors.black.withOpacity(0.5),
          ),
        ),
        if (isUser) ...[
          const SizedBox(width: 4),
          if (isUser)
            Icon(
              message.status == types.Status.seen ? Icons.done_all : Icons.done,
              size: 16,
              color: message.status == types.Status.seen
                  ? Colors.green
                  : Colors.white.withOpacity(0.5),
            ),
        ],
      ],
    );
  }

  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('HH:mm').format(date);
  }

  Future<void> cacheMessages(List<types.Message> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedMessages =
        messages.map((msg) => jsonEncode(msg.toJson())).toList();
    await prefs.setStringList('cached_messages', encodedMessages);
  }

  Future<List<types.Message>> getCachedMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedMessages = prefs.getStringList('cached_messages') ?? [];
    return encodedMessages
        .map((msg) => types.Message.fromJson(jsonDecode(msg)))
        .toList();
  }
}

class CustomChatInput extends StatefulWidget {
  final void Function(types.PartialText) onSendMessage;
  final Function()? onAttachmentPressed;

  const CustomChatInput({
    super.key,
    required this.onSendMessage,
    this.onAttachmentPressed,
  });

  @override
  _CustomChatInputState createState() => _CustomChatInputState();
}

class _CustomChatInputState extends State<CustomChatInput> {
  final TextEditingController _textController = TextEditingController();
  bool _isComposing = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    final partialText = types.PartialText(text: text.trim());
    widget.onSendMessage(partialText);

    _textController.clear();
    setState(() {
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: widget.onAttachmentPressed,
              ),
              Expanded(
                child: TextField(
                  controller: _textController,
                  onChanged: (text) {
                    setState(() {
                      _isComposing = text.trim().isNotEmpty;
                    });
                  },
                  onSubmitted: _handleSubmitted,
                  decoration: InputDecoration(
                    hintText: 'Type a message',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: IconButton(
                  icon: Icon(
                    Icons.send,
                    color: _isComposing
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                  onPressed: _isComposing
                      ? () => _handleSubmitted(_textController.text)
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum FileMessageType {
  image,
  audio,
  document,
  video,
  unknown,
}

FileMessageType getFileMessageType(String fileUrl) {
  // Convert to lowercase to handle uppercase extensions
  final extension = fileUrl.toLowerCase().split('.').last;

  // Image extensions
  if ([
    'jpg',
    'jpeg',
    'png',
  ].contains(extension)) {
    return FileMessageType.image;
  }

//video extensions
  if ([
    'mp4',
    'mkv',
    'mpeg',
  ].contains(extension)) {
    return FileMessageType.video;
  }

  // Audio extensions
  if ([
    'mp3',
    'wav',
    'm4a',
    'aac',
    'ogg',
  ].contains(extension)) {
    return FileMessageType.audio;
  }

  // Document extensions
  if ([
    'pdf',
    'doc',
    'docx',
  ].contains(extension)) {
    return FileMessageType.document;
  }

  // If no match found
  return FileMessageType.unknown;
}

class VideoMessage extends StatefulWidget {
  final types.FileMessage message;
  final bool isUser;

  const VideoMessage({
    super.key,
    required this.message,
    required this.isUser,
  });

  @override
  State<VideoMessage> createState() => _VideoMessageState();
}

class _VideoMessageState extends State<VideoMessage> {
  String? thumbnailUrl;
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
    _initializeVideoPlayer();
  }

  Future<void> _generateThumbnail() async {
    try {
      if (mounted) {}
    } catch (e) {
      debugPrint('Error generating thumbnail: $e');
    }
  }

  Future<void> _initializeVideoPlayer() async {
    _controller = VideoPlayerController.network(widget.message.uri);
    try {
      await _controller.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video player: $e');
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isUser ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: AspectRatio(
                  aspectRatio:
                      _isInitialized ? _controller.value.aspectRatio : 16 / 9,
                  child: Container(
                    color: Colors.black,
                    child: _isInitialized
                        ? VideoPlayer(_controller)
                        : const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
              // Play button overlay
              if (_isInitialized)
                InkWell(
                  onTap: () {
                    setState(() {
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                    });
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              // Duration overlay
              if (_isInitialized)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _formatDuration(_controller.value.duration),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // File name and timestamp
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.videocam,
                  size: 16,
                  color: widget.isUser ? Colors.white : Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.message.name ?? 'Video',
                    style: TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontSize: 12,
                      color: widget.isUser ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(widget.message.size ?? 0) ~/ (1024 * 1024)} MB',
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.isUser ? Colors.white : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
