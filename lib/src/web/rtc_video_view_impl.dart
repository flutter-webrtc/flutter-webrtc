import 'package:flutter/material.dart';
import 'package:flutter_webrtc/src/web/rtc_video_renderer_impl.dart';

import '../interface/enums.dart';
import '../interface/rtc_video_renderer.dart';

class RTCVideoView extends StatefulWidget {
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
  @override
  _RTCVideoViewState createState() => _RTCVideoViewState();
}

class _RTCVideoViewState extends State<RTCVideoView> {
  _RTCVideoViewState();
  RTCVideoRenderer get videoRenderer =>
      widget._renderer as RTCVideoRenderer;
  @override
  void initState() {
    super.initState();
    widget._renderer?.addListener(() => setState(() {}));
  }

  Widget buildVideoElementView(RTCVideoViewObjectFit objFit, bool mirror) {
    // TODO(cloudwebrtc): Add css style for mirror.
    videoRenderer.videoElement.style.objectFit =
        objFit == RTCVideoViewObjectFit.RTCVideoViewObjectFitContain
            ? 'contain'
            : 'cover';
    return HtmlElementView(
        viewType: 'RTCVideoRenderer-${videoRenderer.textureId}');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Center(
          child: Container(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: widget._renderer.renderVideo
            ? buildVideoElementView(widget.objectFit, widget.mirror)
            : Container(),
      ));
    });
  }
}
