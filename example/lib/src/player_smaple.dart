import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';

import 'player/player_panel/player_live_view.dart';
import 'player/player_panel/player_settings.dart';
import 'player/player_panel/webrtc_player_panel.dart';
import 'player/webrtc_player_controller.dart';
import 'player/webrtc_player_controls.dart';
import 'player/webrtc_player_state.dart';

class PlayerSample extends StatefulWidget {
  @override
  PlayerSampleState createState() => PlayerSampleState();
}

class PlayerSampleState extends State<PlayerSample> {
  WebRTCPlayerController playerController = WebRTCPlayerController();
  TextEditingController textEditingController = TextEditingController();

  String url = 'webrtc';

  bool isCodeH264 = true;

  FijkPlayer player = FijkPlayer();
  String rtspUrl = 'rtsp';
  TextEditingController rtspTextEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textEditingController.text = url;
    rtspTextEditingController.text = rtspUrl;

    player.setOption(FijkOption.hostCategory, 'enable-snapshot', 1);
    player.setOption(FijkOption.playerCategory, 'mediacodec-all-videos', 1);
    startPlay();
  }

  void startPlay() async {
    await player.setOption(FijkOption.hostCategory, 'request-screen-on', 1);
    await player.setOption(FijkOption.hostCategory, 'request-audio-focus', 1);
    await player.setDataSource(rtspUrl, autoPlay: true).catchError((e) {
      print('setDataSource error: $e');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Webrtc Player'),
      ),
      body: ListView(
        children: [
          TextField(
            controller: textEditingController,
            onChanged: (v) {
              setState(() {
                url = v;
              });
            },
            decoration: InputDecoration(
                suffix: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                textEditingController.text = '';
                setState(() {
                  url = '';
                });
              },
            )),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              const Spacer(),
              Checkbox(
                  value: isCodeH264,
                  onChanged: (v) {
                    setState(() {
                      isCodeH264 = v!;
                    });
                  }),
              TextButton(
                  onPressed: () {
                    setState(() {
                      isCodeH264 = true;
                    });
                  },
                  child: Text('H264')),
              const Spacer(),
              Checkbox(
                  value: !isCodeH264,
                  onChanged: (v) {
                    setState(() {
                      isCodeH264 = !v!;
                    });
                  }),
              TextButton(
                  onPressed: () {
                    setState(() {
                      isCodeH264 = false;
                    });
                  },
                  child: Text('H265')),
              const Spacer(),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
              onPressed: () {
                if (url.isNotEmpty) playerController.setDataSource(url: url);
                // playerController.setTuringError(WebrtcError.none);
                if (rtspUrl.isNotEmpty) startPlay();
              },
              child: Text('Confirm')),
          SizedBox(height: 80),
          Container(
            height: (MediaQuery.of(context).size.width - 32) * 9 / 16,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: WebRTCPlayerControls(
              code: isCodeH264 ? WebrtcCodeType.h264 : WebrtcCodeType.h265,
              controller: playerController,
              panelBuilder: (context, rect) {
                return WebrtcPlayerPanel(
                  controller: playerController,
                  texturePos: rect,
                  settings: PlayerSettings.live(),
                  builder: (context) => PlayerLiveView(),
                );
              },
            ),
          ),
          const Divider(color: Colors.red),
          TextField(
            controller: rtspTextEditingController,
            onChanged: (v) {
              setState(() {
                rtspUrl = v;
              });
            },
            decoration: InputDecoration(
              suffix: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  rtspTextEditingController.text = '';
                  setState(() {
                    rtspUrl = '';
                  });
                },
              ),
            ),
          ),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: FijkView(player: player),
          ),
        ],
      ),
    );
  }
}
