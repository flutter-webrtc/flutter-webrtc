import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
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
  bool _showVideoView = false;
  @override
  void dispose() {
    final controller = _controller;
    controller?.onFirstFrameRendered = null;
    controller?.onSrcObjectChange = null;
    controller?.onResize = null;
    _controller = null;
    unawaited(controller?.dispose());
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
      child: FittedBox(
        clipBehavior: Clip.hardEdge,
        fit: widget.objectFit ==
                RTCVideoViewObjectFit.RTCVideoViewObjectFitContain
            ? BoxFit.contain
            : BoxFit.cover,
        child: Center(
          child: SizedBox(
            width: _showVideoView
                ? widget.objectFit ==
                        RTCVideoViewObjectFit.RTCVideoViewObjectFitCover
                    ? constraints.maxWidth
                    : constraints.maxHeight *
                        (_controller?.value.aspectRatio ?? 1.0)
                : 0.1,
            height: _showVideoView ? constraints.maxHeight : 0.1,
            child: Transform(
              transform: Matrix4.identity()..rotateY(widget.mirror ? -pi : 0.0),
              alignment: FractionalOffset.center,
              child: _buildNativeView(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNativeView(BuildContext context) {
    const viewType = 'rtc_video_platform_view';
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: viewType,
        onPlatformViewCreated: onPlatformViewCreated,
        creationParams: <String, dynamic>{},
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      return AppKitView(
        viewType: viewType,
        onPlatformViewCreated: onPlatformViewCreated,
        creationParams: <String, dynamic>{},
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return IgnorePointer(
        child: PlatformViewLink(
          viewType: viewType,
          surfaceFactory: (
            BuildContext context,
            PlatformViewController controller,
          ) {
            return AndroidViewSurface(
              controller: controller as AndroidViewController,
              gestureRecognizers: const <Factory<
                  OneSequenceGestureRecognizer>>{},
              hitTestBehavior: PlatformViewHitTestBehavior.opaque,
            );
          },
          onCreatePlatformView: (PlatformViewCreationParams params) {
            final AndroidViewController controller =
                PlatformViewsService.initSurfaceAndroidView(
              id: params.id,
              viewType: viewType,
              layoutDirection:
                  Directionality.maybeOf(context) ?? TextDirection.ltr,
              creationParams: <String, dynamic>{},
              creationParamsCodec: const StandardMessageCodec(),
              onFocus: () => params.onFocusChanged(true),
            );
            controller.addOnPlatformViewCreatedListener(
              params.onPlatformViewCreated,
            );
            controller.addOnPlatformViewCreatedListener(onPlatformViewCreated);
            controller.create();
            return controller;
          },
        ),
      );
    }
    return Text('RTCVideoPlatformView only supports iOS, macOS, and Android.');
  }

  void showVideoView(bool show) {
    if (mounted) {
      _showVideoView = show;
      setState(() {});
    }
  }

  Future<void> onPlatformViewCreated(int id) async {
    final controller = RTCVideoPlatformViewController(id);
    _controller = controller;
    controller.onFirstFrameRendered = () => showVideoView(true);
    controller.onSrcObjectChange = () => showVideoView(false);
    controller.onResize = () => showVideoView(true);
    await controller.initialize();
    if (!mounted || _controller != controller) return;
    widget.onViewReady?.call(controller);
  }
}
