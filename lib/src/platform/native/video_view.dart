import 'dart:math';

import 'package:flutter/material.dart';

import '../../api/peer.dart';
import '../video_renderer.dart';

class VideoView extends StatelessWidget {
  VideoView(
    this._renderer, {
    super.key,
    this.objectFit = VideoViewObjectFit.contain,
    this.mirror = false,
    this.enableContextMenu = true,
    this.filterQuality = FilterQuality.low,
  });

  final VideoRenderer _renderer;
  final VideoViewObjectFit objectFit;
  final bool mirror;
  final bool enableContextMenu;
  final FilterQuality filterQuality;
  final bool _autoRotate = isDesktop;

  NativeVideoRenderer get videoRenderer => _renderer as NativeVideoRenderer;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) =>
            _buildVideoView(constraints));
  }

  Widget _buildVideoView(BoxConstraints constraints) {
    return Center(
      child: SizedBox(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: FittedBox(
          clipBehavior: Clip.hardEdge,
          fit: objectFit == VideoViewObjectFit.contain
              ? BoxFit.contain
              : BoxFit.cover,
          child: Center(
            child: ValueListenableBuilder<RTCVideoValue>(
              valueListenable: videoRenderer,
              builder:
                  (BuildContext context, RTCVideoValue value, Widget? child) {
                Widget result = SizedBox(
                  width: constraints.maxHeight * value.aspectRatio,
                  height: constraints.maxHeight,
                  child: child,
                );
                if (_autoRotate) {
                  result = RotatedBox(
                    quarterTurns: (value.rotation / 90).round(),
                    child: result,
                  );
                }
                return Transform(
                    transform: Matrix4.identity()..rotateY(mirror ? -pi : 0.0),
                    alignment: FractionalOffset.center,
                    child: result);
              },
              child: videoRenderer.textureId != null &&
                      videoRenderer.srcObject != null
                  ? Texture(
                      textureId: videoRenderer.textureId!,
                      filterQuality: filterQuality,
                    )
                  : Container(),
            ),
          ),
        ),
      ),
    );
  }
}
