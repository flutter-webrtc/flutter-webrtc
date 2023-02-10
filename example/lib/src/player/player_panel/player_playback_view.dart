import 'package:flutter/material.dart';

import 'center_button.dart';
import 'player_view_widget.dart';

class PlayerPlaybackView extends PlayerViewWidget {
  PlayerPlaybackView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 40,
      child: Container(
        height: 40,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black12, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Row(
          children: [
            const Spacer(),
            if (settings.canPause)
              CenterButton.playPause(
                iconSize: 20,
                showing: true,
                active: playing,
                onPressed: onTapPlay,
                expand: false,
                borderEnabled: false,
              ),
            if (settings.canRewind)
              CenterButton.image(
                image: Icon(Icons.fast_rewind),
                active: true,
                onPressed: onTapRewind,
                expand: false,
                borderEnabled: false,
              ),
            if (settings.canForward)
              CenterButton.image(
                image: Icon(Icons.forward),
                active: true,
                onPressed: onTapForward,
                expand: false,
                borderEnabled: false,
              ),
            const Spacer(),
            if (settings.canSpeed)
              CenterButton.rectangle(
                text: Text(
                  speed.label,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                  textScaleFactor: speed.textScaleFactor,
                ),
                iconColor: live ? Colors.grey : Colors.white,
                size: const Size(30, 16),
                borderEnabled: false,
                onPressed: () => live ? null : onTapSpeed?.call(speed),
              ),
            if (settings.canAudio)
              IconButton(
                icon: audio
                    ? const Icon(Icons.volume_up, color: Colors.white, size: 20)
                    : const Icon(Icons.volume_off,
                        color: Colors.white, size: 20),
                onPressed: onTapAudio,
              ),
            if (settings.canFullscreen)
              CenterButton.fullExist(
                iconSize: 20,
                showing: true,
                active: fullscreen,
                onPressed: onTapFullScreen,
                expand: false,
                borderEnabled: false,
              ),
          ],
        ),
      ),
    );
  }
}
