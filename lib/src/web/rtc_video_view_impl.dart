import 'package:flutter/material.dart';

import '../interface/enums.dart';
import '../rtc_video_renderer.dart';
import '../web/rtc_video_renderer_impl.dart';

class RTCVideoView extends StatefulWidget {
  RTCVideoView(
    this._renderer, {
    Key key,
    this.objectFit = RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
    this.mirror = false,
  })  : assert(objectFit != null),
        assert(mirror != null),
        super(key: key);

  final RTCVideoRenderer _renderer;
  final RTCVideoViewObjectFit objectFit;
  final bool mirror;
  @override
  _RTCVideoViewState createState() => _RTCVideoViewState();
}

class _RTCVideoViewState extends State<RTCVideoView> {
  _RTCVideoViewState();
  RTCVideoRendererWeb get videoRenderer =>
      widget._renderer.delegate as RTCVideoRendererWeb;
  @override
  void initState() {
    super.initState();
    widget._renderer?.delegate?.addListener(() => setState(() {}));
  }

  Widget buildVideoElementView(RTCVideoViewObjectFit objFit, bool mirror) {
    videoRenderer.mirror = mirror;
    videoRenderer.objectFit =
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
