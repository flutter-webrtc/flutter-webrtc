import 'package:flutter/material.dart';

import 'center_button.dart';
import 'player_view_widget.dart';

class PlayerLiveView extends PlayerViewWidget {
  PlayerLiveView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      width: MediaQuery.of(context).size.width,
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
          if (settings.canPtz) ...[
            const Spacer(),
            CenterButton.ptz(
              iconSize: 20,
              backgroundColor: Colors.transparent,
              showing: true,
              active: true,
              onPressed: onTapPtz,
              expand: false,
              borderEnabled: false,
            ),
          ],
          if (settings.canHd && !fullscreen) ...[
            const Spacer(),
            IconButton(
              icon: hd
                  ? Icon(
                      Icons.sd_outlined,
                      color: Colors.white,
                    )
                  : Icon(
                      Icons.sd_outlined,
                      color: Colors.white,
                    ),
              onPressed: onTapHd,
            ),
          ],
          if (settings.canRecord) ...[
            const Spacer(),
            IconButton(
              icon: record
                  ? const Icon(Icons.mic, color: Colors.white, size: 20)
                  : const Icon(Icons.mic_off, color: Colors.white, size: 20),
              onPressed: onTapRecord,
            ),
          ],
          if (settings.canAudio) ...[
            const Spacer(),
            IconButton(
              icon: audio
                  ? const Icon(Icons.volume_up, color: Colors.white, size: 20)
                  : const Icon(Icons.volume_off, color: Colors.white, size: 20),
              onPressed: onTapAudio,
            ),
          ],
          if (settings.canFullscreen) ...[
            const Spacer(),
            CenterButton.fullExist(
              iconSize: 20,
              showing: true,
              active: fullscreen,
              onPressed: onTapFullScreen,
              expand: false,
              borderEnabled: false,
            ),
          ],
          const Spacer(),
        ],
      ),
    );
  }
}
