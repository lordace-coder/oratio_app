import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oratio_app/bloc/profile_cubit/profile_data_cubit.dart';
import 'package:oratio_app/networkProvider/priest_requests.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:zego_uikit_prebuilt_live_audio_room/zego_uikit_prebuilt_live_audio_room.dart';

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
        print('Received: $message');
      },
      onDone: () {
        print('WebSocket closed');
        setParishLiveStatus(false);
      },
      onError: (error) {
        print('WebSocket error: $error');
      },
    );

    setParishLiveStatus(true);
  }

  void setParishLiveStatus(bool isLive) {
    // Implement the logic to update the parish's live status in your app
    print('Parish live status: $isLive');
  }

  @override
  void dispose() {
    if (widget.isPriest) {
      channel?.sink.close(status.normalClosure);

      setParishLiveStatus(false);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user =
        getPocketBaseFromContext(context).authStore.model as RecordModel;

    return Scaffold(
      body: ZegoUIKitPrebuiltLiveAudioRoom(
        appID: 2015132394,
        appSign:
            "c905dd2394441c4d848c59d16f1505781e1366ecef028e22cc73b3c7010e141f", // Fill in the appSign that you get from ZEGOCLOUD Admin Console.
        userID: user.id,
        userName: user.getStringValue('username'),
        roomID: widget.parishId,
        config: widget.isPriest
            ? ZegoUIKitPrebuiltLiveAudioRoomConfig.host()
            : ZegoUIKitPrebuiltLiveAudioRoomConfig.audience()
          ..turnOnMicrophoneWhenJoining = false
          ..bottomMenuBar = widget.isPriest
              ? ZegoLiveAudioRoomBottomMenuBarConfig(
                  audienceButtons: [],
                )
              : ZegoLiveAudioRoomBottomMenuBarConfig(
                  audienceButtons: [],
                ),
      ),
    );
  }
}
