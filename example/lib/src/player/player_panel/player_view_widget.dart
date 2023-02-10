import 'package:flutter/material.dart';

import 'player_settings.dart';
import 'player_state.dart';

typedef PlayerViewWidgetBuilder = PlayerViewWidget Function(
  BuildContext context,
);

typedef PlayerSpeedCallback = void Function(PlayerSpeed);

abstract class PlayerViewWidget extends StatelessWidget {
  late PlayerSettings settings;

  late VoidCallback? onTapPlay;
  late VoidCallback? onTapFullScreen;
  late VoidCallback? onTapPtz;
  late VoidCallback? onTapRecord;
  late VoidCallback? onTapAudio;
  late VoidCallback? onTapHd;
  late PlayerSpeedCallback? onTapSpeed;
  late VoidCallback? onTapRewind;
  late VoidCallback? onTapForward;

  late bool playing;
  late bool hd;
  late bool fullscreen;
  late bool record;
  late bool audio;
  late PlayerSpeed speed;
  late bool live;
  late PlayerState state;
  late String description;

  PlayerViewWidget({Key? key}) : super(key: key) {
    settings = const PlayerSettings();
    onTapPlay = () {};
    onTapFullScreen = () {};
    onTapPtz = () {};
    onTapRecord = () {};
    onTapRewind = () {};
    onTapForward = () {};
    onTapHd = () {};
    onTapSpeed = (_) {};
    onTapAudio = () {};
    playing = true;
    hd = false;
    fullscreen = true;
    record = false;
    audio = false;
    speed = PlayerSpeed.x1;
    live = true;
    state = PlayerState.connecting;
    description = '';
  }
}
