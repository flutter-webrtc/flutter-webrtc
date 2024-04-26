import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'rtc_video_platform_view_controller.dart';

class RTCVideoPlatFormView extends StatefulWidget {
  const RTCVideoPlatFormView({
    super.key,
    required this.onViewReady,
  });
  final void Function(RTCVideoPlatformViewController)? onViewReady;

  @override
  NativeVideoPlayerViewState createState() => NativeVideoPlayerViewState();
}

class NativeVideoPlayerViewState extends State<RTCVideoPlatFormView> {
  RTCVideoPlatformViewController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// RepaintBoundary is a widget that isolates repaints
    return RepaintBoundary(
      child: _buildNativeView(),
    );
  }

  Widget _buildNativeView() {
    const viewType = 'rtc_video_platform_view';
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: viewType,
        onPlatformViewCreated: onPlatformViewCreated,
      );
    }
    /*
    else if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: viewType,
        onPlatformViewCreated: onPlatformViewCreated,
      );
    } 
    */
    return Text('$defaultTargetPlatform is not yet supported by this plugin.');
  }

  Future<void> onPlatformViewCreated(int id) async {
    final controller = RTCVideoPlatformViewController(id);
    _controller = controller;
    widget.onViewReady?.call(controller);
  }
}
