import 'dart:async';

import 'package:flutter/material.dart';

import '../video_renderer.dart';
import 'video_renderer.dart';

class VideoView extends StatefulWidget {
  const VideoView(
    this._renderer, {
    Key? key,
    this.objectFit = VideoViewObjectFit.contain,
    this.mirror = false,
    this.enableContextMenu = true,
    this.filterQuality = FilterQuality.low,
  }) : super(key: key);

  final VideoRenderer _renderer;
  final VideoViewObjectFit objectFit;
  final bool mirror;
  final bool enableContextMenu;
  final FilterQuality filterQuality;

  WebVideoRenderer get videoRenderer => _renderer as WebVideoRenderer;

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  _VideoViewState();

  WebVideoRenderer get videoRenderer => widget._renderer as WebVideoRenderer;

  @override
  void initState() {
    super.initState();
    widget._renderer.addListener(_onRendererListener);
    videoRenderer.mirror = widget.mirror;
    videoRenderer.enableContextMenu = widget.enableContextMenu;
    videoRenderer.objectFit =
        widget.objectFit == VideoViewObjectFit.contain ? 'contain' : 'cover';
  }

  void _onRendererListener() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget._renderer.removeListener(_onRendererListener);
    super.dispose();
  }

  @override
  void didUpdateWidget(VideoView oldWidget) {
    super.didUpdateWidget(oldWidget);
    videoRenderer.mirror = widget.mirror;
    Timer(const Duration(milliseconds: 10),
        () => videoRenderer.mirror = widget.mirror);
    videoRenderer.enableContextMenu = widget.enableContextMenu;
    videoRenderer.objectFit =
        widget.objectFit == VideoViewObjectFit.contain ? 'contain' : 'cover';
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
          child: SizedBox(
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
