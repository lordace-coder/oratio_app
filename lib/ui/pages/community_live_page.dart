import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ace_toast/ace_toast.dart';
import 'package:oratio_app/networkProvider/priest_requests.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

class CommunityLivePage extends StatefulWidget {
  CommunityLivePage(
      {super.key, required this.communityId, this.isHost = false});
  final String communityId;
  bool isHost = false;
  @override
  State<CommunityLivePage> createState() => _CommunityLivePageState();
}

class _CommunityLivePageState extends State<CommunityLivePage> {
  WebSocketChannel? channel;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isHost) {
      connectWebSocket();
    }
  }

  void connectWebSocket() {
    channel = WebSocketChannel.connect(
      Uri.parse(
          'ws://bookmass.fly.dev/ws/community-live?prayerCommunityId=${widget.communityId}'),
    );

    channel!.stream.listen(
      (message) {
        if (mounted) {
          print('Received: $message');
        }
      },
      onDone: () {
        if (mounted) {
          print('WebSocket closed');
          setLiveStatus(false);
        }
      },
      onError: (error) {
        if (mounted) {
          NotificationService.showError("Error occured during live session");
          setLiveStatus(false);
          print('WebSocket error: $error');
        }
      },
    );

    if (mounted) {
      setLiveStatus(true);
    }
  }

  void setLiveStatus(bool isLive) {
    if (mounted) {
      // Implement the logic to update the parish's live status in your app
      if (!isLive) {
        context.pop();
      }
    }
  }

  @override
  void dispose() {
    if (widget.isHost) {
      channel?.sink.close(status.normalClosure);
      setLiveStatus(false);
    }
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted) return const SizedBox.shrink();
    final user =
        getPocketBaseFromContext(context).authStore.model as RecordModel;
    return Container();
  }
}
