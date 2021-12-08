import 'dart:async';

import 'package:flutter/material.dart';

import '../interface/enums.dart';
import '../rtc_video_renderer.dart';
import '../web/rtc_video_renderer_impl.dart';

class RTCVideoView extends StatefulWidget {
  RTCVideoView(
    this._renderer, {
    Key? key,
    this.objectFit = RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
    this.mirror = false,
    this.enableContextMenu = true,
    this.filterQuality = FilterQuality.low,
  }) : super(key: key);

  final RTCVideoRenderer _renderer;
  final RTCVideoViewObjectFit objectFit;
  final bool mirror;
  final bool enableContextMenu;
  final FilterQuality filterQuality;

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
    widget._renderer.delegate.addListener(_onRendererListener);
    videoRenderer.mirror = widget.mirror;
    videoRenderer.enableContextMenu = widget.enableContextMenu;
    videoRenderer.objectFit =
        widget.objectFit == RTCVideoViewObjectFit.RTCVideoViewObjectFitContain
            ? 'contain'
            : 'cover';
  }

  void _onRendererListener() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget._renderer.delegate.removeListener(_onRendererListener);
    super.dispose();
  }

  @override
  void didUpdateWidget(RTCVideoView oldWidget) {
    super.didUpdateWidget(oldWidget);
    videoRenderer.mirror = widget.mirror;
    Timer(
        Duration(milliseconds: 10), () => videoRenderer.mirror = widget.mirror);
    videoRenderer.enableContextMenu = widget.enableContextMenu;
    videoRenderer.objectFit =
        widget.objectFit == RTCVideoViewObjectFit.RTCVideoViewObjectFitContain
            ? 'contain'
            : 'cover';
  }

  Widget buildVideoElementView() {
    return HtmlElementView(
      viewType: 'RTCVideoRenderer-${videoRenderer.textureId}',
    );
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
                ? buildVideoElementView()
                : Container(),
          ),
        );
      },
    );
  }
}
