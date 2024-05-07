import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:webrtc_interface/webrtc_interface.dart';

import 'rtc_video_platform_view_controller.dart';

class RTCVideoPlatFormView extends StatefulWidget {
  const RTCVideoPlatFormView({
    super.key,
    required this.onViewReady,
    this.objectFit = RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
    this.mirror = false,
  });
  final void Function(RTCVideoPlatformViewController)? onViewReady;
  final RTCVideoViewObjectFit objectFit;
  final bool mirror;
  @override
  NativeVideoPlayerViewState createState() => NativeVideoPlayerViewState();
}

class NativeVideoPlayerViewState extends State<RTCVideoPlatFormView> {
  RTCVideoPlatformViewController? _controller;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) =>
            _buildVideoView(context, constraints));
  }

  Widget _buildVideoView(BuildContext context, BoxConstraints constraints) {
    return Center(
      child: Container(
        width: constraints.maxWidth *
            (widget.objectFit ==
                    RTCVideoViewObjectFit.RTCVideoViewObjectFitCover
                ? _controller?.value.aspectRatio ?? 1.0
                : 1.0),
        height: constraints.maxHeight,
        child: FittedBox(
          clipBehavior: Clip.hardEdge,
          fit: widget.objectFit ==
                  RTCVideoViewObjectFit.RTCVideoViewObjectFitContain
              ? BoxFit.contain
              : BoxFit.cover,
          child: Center(
            child: SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: Transform(
                transform: Matrix4.identity()
                  ..rotateY(widget.mirror ? -pi : 0.0),
                alignment: FractionalOffset.center,
                child: _buildNativeView(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNativeView() {
    const viewType = 'rtc_video_platform_view';
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: viewType,
        onPlatformViewCreated: onPlatformViewCreated,
        creationParams: <String, dynamic>{
          'objectFit': widget.objectFit.index,
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    return Text('RTCVideoPlatformView only support for iOS.');
  }

  void reBuildView() {
    setState(() {});
  }

  Future<void> onPlatformViewCreated(int id) async {
    final controller = RTCVideoPlatformViewController(id);
    _controller = controller;
    widget.onViewReady?.call(controller);
    controller.onFirstFrameRendered = reBuildView;
    controller.onResize = reBuildView;
    await _controller?.initialize();
  }
}
