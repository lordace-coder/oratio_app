import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:oratio_app/bloc/blocs.dart';
import 'package:oratio_app/bloc/chat_cubit/chat_cubit.dart';
import 'package:oratio_app/bloc/chat_cubit/message_cubit.dart';
import 'package:oratio_app/bloc/posts/post_cubit.dart';
import 'package:oratio_app/bloc/profile_cubit/profile_data_cubit.dart';
import 'package:oratio_app/networkProvider/users.dart';
import 'package:oratio_app/services/chat/chat_service.dart';
import 'package:oratio_app/ui/themes.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.profile});
  final Profile profile;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<types.Message> _messages = [];
  late RecordModel currentUser;
  late PocketBase pb;
  late types.User _user;
  late types.User _otherUser;

  @override
  void initState() {
    super.initState();
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMessages());
  }

  Future<void> _loadMessages() async {
    // FETCH MESSAGES
    final response = await pb.collection('messages').getFullList(
          sort: '-created',
          filter:
              'reciever.id = "${widget.profile.userId}" || sender.id = "${widget.profile.userId}" ',
        );

    final messages = <types.Message>[];
    for (var item in response) {
      messages.add(types.TextMessage(
          author:
              item.getStringValue('sender') == _user.id ? _user : _otherUser,
          id: item.id,
          text: item.getStringValue('message')));
    }
    setState(() {
      _messages = messages;
    });
    await Future.delayed(Durations.extralong4);
    context.read<ChatCubit>().markMessagesAsRead(_otherUser.id);
  }

  // void _handleSendPressed(types.PartialText message) {
  //   final textMessage = types.TextMessage(
  //     author: _user,
  //     createdAt: DateTime.now().millisecondsSinceEpoch,
  //     id: const Uuid().v4(),
  //     text: message.text,
  //   );
  //   context
  //       .read<ChatCubit>()
  //       .sendMessage(message: message.text, receiverId: widget.profile.userId);
  //   //  LOAD MESSAGES AGAIN OR JUST ADD NEW TEXT TO MESSAGE
  //   _addMessage(textMessage);
  // }

  void subscribeToMessages() {
    pb.collection('messages').subscribe(
      '*',
      (e) {
        print('updated inchat');
        if (e.action == 'create') {
          // Check if the message involves the current user

          if (e.record == null) {
            return;
          }
          final message = e.record!;
          // TODO update ui with new message
          final newMsg = types.TextMessage(
              author: _otherUser,
              id: message.id,
              text: message.getStringValue('message'));
          if (mounted) {
            _addMessage(newMsg);
          }

          print([e.record, 'new message in current chat']);
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

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
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
                  _handleImageSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Photo'),
                ),
              ),
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
    );

    if (result != null && result.files.single.path != null) {
      final message = types.FileMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        mimeType: lookupMimeType(result.files.single.path!),
        name: result.files.single.name,
        size: result.files.single.size,
        uri: result.files.single.path!,
      );

      _addMessage(message);
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

      _addMessage(message);
    }
  }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      await OpenFilex.open(message.uri);
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
    if (mounted) {
      print(context.read<MessageCubit>().state.messages);
    }
  }

  void _handleSendPressed(types.PartialText message) {
    context.read<MessageCubit>().sendMessage(
          message: message.text,
          receiverId: widget.profile.userId,
        );
  }

  @override
  Widget build(BuildContext context) {
    _loadInitialMessages();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                widget.profile.user.getStringValue('username')[0].toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
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
                const Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocConsumer<MessageCubit, MessageState>(
          listener: (ctx, state) {},
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            final messages = state.messages.map((msg) {
              print(['file path', msg.filePath!.isNotEmpty]);
              if (msg.filePath != null && msg.filePath!.isNotEmpty) {
                // Handle file message
                return types.FileMessage(
                  author: msg.senderId == _user.id ? _user : _otherUser,
                  id: msg.id,
                  name: msg.filePath!.split('/').last, // Get filename from path
                  size: 0, // You might want to store file size in your model
                  uri: msg.filePath!,
                  createdAt: msg.created.millisecondsSinceEpoch,
                );
              } else {
                // Handle text message
                return types.TextMessage(
                  author: msg.senderId == _user.id ? _user : _otherUser,
                  id: msg.id,
                  text: msg.message,
                  createdAt: msg.created.millisecondsSinceEpoch,
                );
              }
            }).toList();

            return Chat(
              messages: messages,
              onAttachmentPressed: _handleAttachmentPressed,
              onMessageTap: _handleMessageTap,
              onPreviewDataFetched: _handlePreviewDataFetched,
              onSendPressed: _handleSendPressed,
              showUserAvatars: true,
              showUserNames: true,
              user: _user,
              theme: DefaultChatTheme(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
          }),
    );
  }
}
