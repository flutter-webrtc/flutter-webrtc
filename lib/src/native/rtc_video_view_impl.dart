import 'dart:math';

import 'package:flutter/material.dart';

import '../interface/enums.dart';
import '../interface/rtc_video_renderer.dart';
import '../rtc_video_renderer.dart';
import 'rtc_video_renderer_impl.dart';

class RTCVideoView extends StatelessWidget {
  RTCVideoView(
    this._renderer, {
    Key? key,
    this.objectFit = RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
    this.mirror = false,
    this.filterQuality = FilterQuality.low,
  }) : super(key: key);

  final RTCVideoRenderer _renderer;
  final RTCVideoViewObjectFit objectFit;
  final bool mirror;
  final FilterQuality filterQuality;

  RTCVideoRendererNative get videoRenderer =>
      _renderer.delegate as RTCVideoRendererNative;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) =>
            _buildVideoView(constraints));
  }

  Widget _buildVideoView(BoxConstraints constraints) {
    return Center(
      child: Container(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: FittedBox(
          clipBehavior: Clip.hardEdge,
          fit: objectFit == RTCVideoViewObjectFit.RTCVideoViewObjectFitContain
              ? BoxFit.contain
              : BoxFit.cover,
          child: Center(
            child: ValueListenableBuilder<RTCVideoValue>(
              valueListenable: videoRenderer,
              builder:
                  (BuildContext context, RTCVideoValue value, Widget? child) {
                return SizedBox(
                  width: constraints.maxHeight * value.aspectRatio,
                  height: constraints.maxHeight,
                  child: child,
                );
              },
              child: Transform(
                transform: Matrix4.identity()..rotateY(mirror ? -pi : 0.0),
                alignment: FractionalOffset.center,
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
      ),
    );
  }
}
