import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/src/native/rtc_video_renderer_impl.dart';

import '../interface/enums.dart';
import '../interface/rtc_video_renderer.dart';

class RTCVideoView extends StatelessWidget {
  RTCVideoView(
    this._renderer, {
    Key key,
    this.objectFit = RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
    this.mirror = false,
  })  : assert(objectFit != null),
        assert(mirror != null),
        super(key: key);

  final VideoRenderer _renderer;
  final RTCVideoViewObjectFit objectFit;
  final bool mirror;

  RTCVideoRendererNative get videoRenderer =>
      _renderer as RTCVideoRendererNative;

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
          fit: objectFit == RTCVideoViewObjectFit.RTCVideoViewObjectFitContain
              ? BoxFit.contain
              : BoxFit.cover,
          child: Center(
            child: ValueListenableBuilder<RTCVideoValue>(
              valueListenable: _renderer,
              builder:
                  (BuildContext context, RTCVideoValue value, Widget child) {
                return SizedBox(
                  width: constraints.maxHeight * value.aspectRatio,
                  height: constraints.maxHeight,
                  child: value.renderVideo ? child : Container(),
                );
              },
              child: Transform(
                transform: Matrix4.identity()..rotateY(mirror ? -pi : 0.0),
                alignment: FractionalOffset.center,
                child: videoRenderer.textureId != null
                    ? Texture(textureId: videoRenderer.textureId)
                    : Container(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
