import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' as intl;
import 'package:mime/mime.dart';
import 'package:ace_toast/ace_toast.dart';
import 'package:oratio_app/bloc/blocs.dart';
import 'package:oratio_app/bloc/chat_cubit/chat_cubit.dart';
import 'package:oratio_app/bloc/chat_cubit/message_cubit.dart';
import 'package:oratio_app/bloc/profile_cubit/profile_data_cubit.dart';
import 'package:oratio_app/helpers/functions.dart';
import 'package:oratio_app/networkProvider/users.dart';
import 'package:oratio_app/services/contact_service.dart';
import 'package:oratio_app/services/file_downloader.dart';
import 'package:oratio_app/ui/pages/video_display_page.dart';
import 'package:oratio_app/ui/routes/route_names.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:oratio_app/ui/widgets/chats.dart';
import 'package:oratio_app/ui/widgets/image_viewer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:oratio_app/ui/widgets/block_user_modal.dart';
import 'package:oratio_app/models/report_model.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.profile});
  final Profile profile;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  late RecordModel currentUser;
  late PocketBase pb;
  late types.User _user;
  late types.User _otherUser;
  bool _isSubscribed = false;
  bool _isInitialized = false;
  late MessageCubit _messageCubit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _messageCubit = context.read<MessageCubit>();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    if (_isInitialized) return;

    pb = context.read<PocketBaseServiceCubit>().state.pb;
    currentUser = pb.authStore.model as RecordModel;

    _user = types.User(
      id: currentUser.id,
      firstName: currentUser.getStringValue('first_name'),
      lastName: currentUser.getStringValue('last_name'),
    );

    _otherUser = types.User(
      id: widget.profile.userId,
      firstName: widget.profile.user.getStringValue('first_name'),
      lastName: widget.profile.user.getStringValue('last_name'),
    );

    // Clear any previous messages first (synchronously)
    _messageCubit.clearMessages();

    // Load messages
    await _messageCubit.loadMessages(widget.profile.userId);

    // Mark messages as read after loading
    await context.read<ChatCubit>().markMessagesAsRead(widget.profile.userId);

    // Subscribe to realtime updates
    _subscribeToMessages();

    // Reload chat list
    context.read<ChatCubit>().loadRecentChats();

    _isInitialized = true;
  }

  void _subscribeToMessages() {
    if (_isSubscribed) return;

    try {
      pb.collection('messages').subscribe(
        '*',
        (e) {
          if (!mounted) return;

          if (e.action == 'create' && e.record != null) {
            final message = e.record!;
            final senderId = message.getStringValue('sender');
            final receiverId = message.getStringValue('reciever');

            // Process messages for this conversation (both incoming and outgoing)
            if ((senderId == widget.profile.userId && receiverId == currentUser.id) ||
                (senderId == currentUser.id && receiverId == widget.profile.userId)) {
              // Reload messages silently
              _messageCubit.loadMessages(
                widget.profile.userId,
                showLoading: false,
              );

              // Mark as read if we received it (this also reloads chat list)
              if (senderId == widget.profile.userId && receiverId == currentUser.id) {
                context.read<ChatCubit>().markMessagesAsRead(widget.profile.userId);
              } else {
                // If it's our own message, just reload chat list
                context.read<ChatCubit>().loadRecentChats();
              }
            }
          }
        },
        filter: '(sender = "${widget.profile.userId}" && reciever = "${currentUser.id}") || (sender = "${currentUser.id}" && reciever = "${widget.profile.userId}")',
      );

      _isSubscribed = true;
    } catch (e) {
      // Silent fail - realtime updates will not work but app continues
    }
  }

  void _unsubscribeFromMessages() {
    if (_isSubscribed) {
      try {
        pb.collection('messages').unsubscribe('*');
        _isSubscribed = false;
      } catch (e) {
        // Silent fail
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _unsubscribeFromMessages();
    // Clear messages state when leaving chat (using saved reference)
    _messageCubit.clearMessages();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Resubscribe when app comes back to foreground
      _subscribeToMessages();
      // Reload messages
      _messageCubit.loadMessages(widget.profile.userId, showLoading: false);
    } else if (state == AppLifecycleState.paused) {
      // Unsubscribe when app goes to background
      _unsubscribeFromMessages();
    }
  }

  void _handleContactSelection() async {
    Contact? contact = await ContactService.openDeviceContactPicker();

    if (contact != null) {
      final contactData = {
        'first_name': contact.name.first ?? '',
        'last_name': contact.name.last ?? '',
        'phone': contact.phones.isNotEmpty
            ? contact.phones.first.number
            : 'No phone number',
        'email': contact.emails.isNotEmpty
            ? contact.emails.first.address
            : 'No email',
      };

      NotificationService.showInfo('Sending contact...');
      try {
        contactData["metadata"] = "contact";
        await _messageCubit.sendMessage(
              message: jsonEncode(contactData),
              receiverId: widget.profile.userId,
            );
        NotificationService.showSuccess('Contact sent');
      } catch (e) {
        NotificationService.showError('Contact send failed');
      }
    }
  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) => SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.insert_drive_file, color: AppColors.primary),
                title: const Text('File'),
                onTap: () {
                  Navigator.pop(context);
                  _handleFileSelection();
                },
              ),
              ListTile(
                leading: Icon(Icons.contacts, color: AppColors.primary),
                title: const Text('Contact'),
                onTap: () {
                  Navigator.pop(context);
                  _handleContactSelection();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
      withData: true,
    );

    if (result != null &&
        result.files.single.path != null &&
        result.files.single.bytes != null) {
      final filePath = result.files.single.path!;
      final fileName = result.files.single.name;
      final fileBytes = result.files.single.bytes!;
      final mimeType = lookupMimeType(filePath);

      Widget filePreview;
      if (mimeType != null && mimeType.startsWith('image/')) {
        filePreview = Image.memory(fileBytes, fit: BoxFit.cover, height: 200);
      } else if (mimeType != null && mimeType.startsWith('video/')) {
        filePreview = const Icon(Icons.videocam, size: 100);
      } else {
        filePreview = const Icon(Icons.insert_drive_file, size: 100);
      }

      bool? confirmSend = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Send File'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                filePreview,
                const SizedBox(height: 20),
                Text(fileName),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Send'),
              ),
            ],
          );
        },
      );

      if (confirmSend == true && mounted) {
        NotificationService.showInfo('Uploading file...');
        try {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text('Uploading...'),
                  ],
                ),
              );
            },
          );

          await pb.collection('messages').create(
            body: <String, dynamic>{
              "sender": _user.id,
              "message": "{{file}}",
              "reciever": _otherUser.id,
            },
            files: [
              http.MultipartFile.fromBytes('file', fileBytes, filename: fileName)
            ],
          );

          if (mounted) {
            Navigator.of(context, rootNavigator: true).pop();
            NotificationService.showSuccess('File sent');
          }
        } catch (e) {
          if (mounted) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          NotificationService.showError('File upload failed');
        }
      }
    }
  }

  void _handleMessageTap(BuildContext context, types.Message message) async {
    if (message is types.ImageMessage) {
      openImageView(context, message.uri, imageUrl: message.uri);
    } else if (message is types.VideoMessage) {
      openVideo(context, message.uri);
    } else if (message is types.FileMessage) {
      final mimeType = lookupMimeType(message.uri);
      if (mimeType != null && mimeType.startsWith('image/')) {
        openImageView(context, message.uri, imageUrl: message.uri);
      } else if (mimeType != null && mimeType.startsWith('video/')) {
        openVideo(context, message.uri);
      }
    }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    // Handle preview data if needed
  }

  void _handleSendPressed(types.PartialText message) {
    _messageCubit.sendMessage(
          message: message.text,
          receiverId: widget.profile.userId,
        );
  }

  String? getAvatarUrl() {
    if (widget.profile.user.getStringValue('avatar').isNotEmpty) {
      final img = pb
          .getFileUrl(
              widget.profile.user, widget.profile.user.getStringValue('avatar'))
          .toString();
      if (img.isNotEmpty) {
        return img;
      }
    }
    return null;
  }

  String _getLastSeenTime(String? updated) {
    if (updated == null) {
      return 'unknown';
    }
    try {
      return formatDateTimeToHoursAgo(DateTime.parse(updated));
    } catch (e) {
      return 'unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onTap: () => context.pushNamed(RouteNames.profilepagevisitor,
              pathParameters: {'id': widget.profile.userId}),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: getAvatarUrl() != null
                        ? CachedNetworkImageProvider(getAvatarUrl()!)
                        : null,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: getAvatarUrl() != null
                        ? null
                        : Text(
                            widget.profile.user
                                .getStringValue('username')[0]
                                .toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                  ),
                  if (widget.profile.user.getBoolValue('active'))
                    Positioned(
                      right: 0,
                      bottom: -2,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getFullName(widget.profile.user),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.profile.user.getBoolValue('active') == false)
                      Text(
                        'last seen ${_getLastSeenTime(widget.profile.user.updated)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            position: PopupMenuPosition.under,
            onSelected: (value) async {
              if (value == 'block') {
                final userName = getFullName(widget.profile.user);
                final result = await showBlockUserDialog(
                  context,
                  userId: widget.profile.userId,
                  userName: userName,
                );
                if (result == true && mounted) {
                  NotificationService.showInfo('User blocked');
                  Navigator.pop(context);
                }
              } else if (value == 'report') {
                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    contentPadding: const EdgeInsets.all(24),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            FontAwesomeIcons.flag,
                            color: Colors.red.shade600,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Report User?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Report ${getFullName(widget.profile.user)} for inappropriate behavior or content?',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await showSpamDialog(
                            context,
                            contentId: widget.profile.userId,
                            contentType: 'user',
                            reportedUserId: widget.profile.userId,
                          );
                        },
                        child: Text(
                          'Report',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'block',
                child: Row(
                  children: [
                    Icon(FontAwesomeIcons.userSlash, size: 16, color: Colors.orange),
                    SizedBox(width: 12),
                    Text('Block User', style: TextStyle(color: Colors.orange)),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'report',
                child: Row(
                  children: [
                    Icon(FontAwesomeIcons.flag, size: 16, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Report User', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage(
              'assets/images/wallet_bg.jpeg',
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(.85), BlendMode.lighten),
          ),
        ),
        child: BlocBuilder<MessageCubit, MessageState>(
          builder: (context, state) {
            // Show error state if there's an error and no messages
            if (state.error != null && state.messages.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Failed to load messages',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context
                            .read<MessageCubit>()
                            .loadMessages(widget.profile.userId);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }

            final messages = state.messages.map((msg) {
              if (msg.filePath != null && msg.filePath!.isNotEmpty) {
                return types.FileMessage(
                  author: msg.senderId == _user.id ? _user : _otherUser,
                  id: msg.id,
                  name: msg.filePath!.split('/').last,
                  size: 0,
                  uri: pb.files
                      .getUrl(
                        RecordModel(
                          collectionName: "messages",
                          id: msg.id,
                          collectionId: "nnh9nuyiwl32nsv",
                        ),
                        msg.filePath!,
                      )
                      .toString(),
                  createdAt: msg.created.millisecondsSinceEpoch,
                  status: msg.read ? types.Status.seen : types.Status.sent,
                );
              } else {
                return types.TextMessage(
                  author: msg.senderId == _user.id ? _user : _otherUser,
                  id: msg.id,
                  text: msg.message,
                  status: msg.read ? types.Status.seen : types.Status.sent,
                  createdAt: msg.created.toUtc().millisecondsSinceEpoch,
                );
              }
            }).toList();

            return Chat(
              bubbleBuilder: (child,
                      {required message, required nextMessageInGroup}) =>
                  CustomBubble(message: message, isUser: message.author == _user),
              messages: messages,
              onAttachmentPressed: _handleAttachmentPressed,
              onMessageTap: _handleMessageTap,
              onPreviewDataFetched: _handlePreviewDataFetched,
              onSendPressed: _handleSendPressed,
              customBottomWidget: CustomChatInput(
                onSendMessage: _handleSendPressed,
                onAttachmentPressed: _handleAttachmentPressed,
              ),
              dateIsUtc: true,
              dateHeaderThreshold: 7200000,
              user: _user,
              emojiEnlargementBehavior: EmojiEnlargementBehavior.single,
              theme: DefaultChatTheme(
                backgroundColor: Colors.transparent,
                inputBackgroundColor: Theme.of(context).colorScheme.surface,
                primaryColor: AppColors.primary,
                secondaryColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                inputTextColor: Theme.of(context).colorScheme.onSurface,
                inputTextCursorColor: Theme.of(context).colorScheme.primary,
                inputTextDecoration: InputDecoration(
                  hintStyle: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                sentMessageBodyTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 16,
                ),
                receivedMessageBodyTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                ),
                userAvatarNameColors: [
                  Colors.blue,
                  Theme.of(context).colorScheme.secondary,
                  Theme.of(context).colorScheme.tertiary,
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
