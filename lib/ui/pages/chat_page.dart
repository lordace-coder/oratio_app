import 'dart:isolate';

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
import 'package:intl/intl.dart';
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

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.profile});
  final Profile profile;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<types.Message> _messages = [];
  late RecordModel currentUser;
  late PocketBase pb;
  late types.User _user;
  late types.User _otherUser;

  @override
  void initState() {
    super.initState();
    context
        .read<ChatCubit>()
        .markMessagesAsRead(widget.profile.userId)
        .then((_) {
      context.read<ChatCubit>().loadRecentChats();
    });
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
        lastName: widget.profile.user.getStringValue('last_name'));
    subscribeToMessages();

    _clearMessages();
    _loadCachedMessages();

    _loadInitialMessages();
  }

  void _clearMessages() {
    setState(() {
      _messages.clear();
    });
  }

  Future<void> _loadCachedMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedMessages =
        prefs.getStringList('cached_messages_${widget.profile.userId}') ?? [];
    if (encodedMessages.isEmpty) return;
    final cachedMessages = encodedMessages
        .map((msg) {
          try {
            return types.Message.fromJson(
                jsonDecode(msg) as Map<String, dynamic>);
          } catch (e) {
            print('Error decoding message: $e');
            return null;
          }
        })
        .whereType<types.Message>()
        .toList();
    setState(() {
      _messages.addAll(cachedMessages);
    });
  }

  Future<void> _handleMessageCache() async {
    final messages = _messages.map((msg) => jsonEncode(msg.toJson())).toList();
    final userId = widget.profile.userId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('cached_messages_$userId', messages);
    print(['cached messages', 'cached_messages_$userId', messages]);
  }

  @override
  void dispose() {
    _handleMessageCache();
    super.dispose();
  }

  intl.DateFormat format = intl.DateFormat("yyyy-MM-dd HH:mm:ss.SSS'Z'");
  void subscribeToMessages() async {
    // TODO CHANGE THIS TO USE WEBSOCKETS
    await pb.collection('messages').subscribe(
      '*',
      (e) {
        if (e.action == 'create' && e.record != null) {
          final message = e.record!;
          final newMsg = types.TextMessage(
              author: _otherUser,
              id: message.id,
              text: message.getStringValue('message'));
          if (mounted) {
            _addMessage(newMsg);
          }
        }
      },
      filter: 'reciever.id = "${currentUser.id}"',
    );
  }

  void unsubscribeToMessages() {
    try {
      pb.collection('messages').unsubscribe('*');
    } catch (e) {
      print('unsubscribe error $e');
    }
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleContactSelection() async {
    // Request permission to access contacts

    // Open contact picker
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

      final message = types.CustomMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        metadata: contactData,
      );

      NotificationService.showInfo('Sending contact...');
      try {
        contactData["metadata"] = "contact";
        context.read<MessageCubit>().sendMessage(
              message: jsonEncode(contactData),
              receiverId: widget.profile.userId,
            );
      } catch (e) {
        print(e);
        NotificationService.showError('Contact send failed');
      }

      _addMessage(message);
    }
  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          height: 144,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleFileSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('File'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleContactSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Contact'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Cancel'),
                ),
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
        filePreview = Image.memory(fileBytes, fit: BoxFit.cover);
      } else if (mimeType != null && mimeType.startsWith('video/')) {
        filePreview = const Icon(Icons.videocam, size: 100);
      } else {
        filePreview = const Icon(Icons.insert_drive_file, size: 100);
      }

      bool? confirmSend = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
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
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Send'),
              ),
            ],
          );
        },
      );

      if (confirmSend == true) {
        final message = types.FileMessage(
          author: _user,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: const Uuid().v4(),
          mimeType: mimeType,
          name: fileName,
          size: result.files.single.size,
          uri: filePath,
        );

        NotificationService.showInfo('Uploading file...');
        try {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const AlertDialog(
                title: Text('Uploading...'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LinearProgressIndicator(),
                    SizedBox(height: 20),
                    Text('Please wait...'),
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
              http.MultipartFile.fromBytes('file', fileBytes,
                  filename: fileName)
            ],
          );

          if (mounted) {
            Navigator.of(context, rootNavigator: true).pop();
            _addMessage(message);
          }
        } catch (e) {
          if (mounted) {
            Navigator.of(context, rootNavigator: true).pop();
          }
          print(e);
          NotificationService.showError('File upload failed');
        }
      }
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);

      final message = types.ImageMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: const Uuid().v4(),
        name: result.name,
        size: bytes.length,
        uri: result.path,
        width: image.width.toDouble(),
      );
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
      } else {
        // Handle other file types if necessary
      }
    }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      _messages[index] = updatedMessage;
    });
  }

  Future<void> _loadInitialMessages() async {
    await context.read<MessageCubit>().loadMessages(widget.profile.userId);
  }

  void _handleSendPressed(types.PartialText message) {
    context.read<MessageCubit>().sendMessage(
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
                      // left: 3,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getFullName(widget.profile.user),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
            ],
          ),
        ),
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
        child: BlocConsumer<MessageCubit, MessageState>(
          listener: (ctx, state) {
            if (state.isLoading) {
              _clearMessages();
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final messages = state.messages.map((msg) {
              if (msg.filePath != null && msg.filePath!.isNotEmpty) {
                // Handle file message
                return types.FileMessage(
                  author: msg.senderId == _user.id ? _user : _otherUser,
                  id: msg.id,
                  name: msg.filePath!.split('/').last, // Get filename from path
                  size: 0, // You might want to store file size in your model
                  uri: pb.files
                      .getUrl(
                          RecordModel(
                              collectionName: "messages",
                              id: msg.id,
                              collectionId: "nnh9nuyiwl32nsv"),
                          msg.filePath!)
                      .toString(),
                  createdAt: msg.created.millisecondsSinceEpoch,
                  status: msg.read ? types.Status.seen : types.Status.sent,
                );
              } else {
                // Handle text message
                final createdAtUtc = msg.created.toUtc().millisecondsSinceEpoch;

                return types.TextMessage(
                  author: msg.senderId == _user.id ? _user : _otherUser,
                  id: msg.id,
                  text: msg.message,
                  status: msg.read ? types.Status.seen : types.Status.sent,
                  createdAt: createdAtUtc,
                );
              }
            }).toList();

            return Chat(
              bubbleBuilder: (child,
                      {required message, required nextMessageInGroup}) =>
                  CustomBubble(
                      message: message, isUser: message.author == _user),
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
