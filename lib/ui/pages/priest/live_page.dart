import 'package:flutter/material.dart';
import 'package:oratio_app/networkProvider/priest_requests.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

class LiveMassPage extends StatefulWidget {
  LiveMassPage({super.key, required this.parishId, this.isPriest = false});
  final String parishId;
  bool isPriest = false;
  @override
  State<LiveMassPage> createState() => _LiveMassPageState();

  static Route<dynamic> route(
      {required String parishId, bool isPriest = false}) {
    return MaterialPageRoute(
      builder: (_) => LiveMassPage(
        parishId: parishId,
        isPriest: isPriest,
      ),
    );
  }
}

class _LiveMassPageState extends State<LiveMassPage> {
  WebSocketChannel? channel;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isPriest) {
      connectWebSocket();
    }
  }

  void connectWebSocket() {
    channel = WebSocketChannel.connect(
      Uri.parse('ws://bookmass.fly.dev/ws/live?parishId=${widget.parishId}'),
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
          setParishLiveStatus(false);
        }
      },
      onError: (error) {
        if (mounted) {
          print('WebSocket error: $error');
        }
      },
    );

    if (mounted) {
      setParishLiveStatus(true);
    }
  }

  void setParishLiveStatus(bool isLive) {
    if (mounted) {
      // Implement the logic to update the parish's live status in your app
      print('Parish live status: $isLive');
    }
  }

  @override
  void dispose() {
    if (widget.isPriest) {
      channel?.sink.close(status.normalClosure);
      setParishLiveStatus(false);
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
