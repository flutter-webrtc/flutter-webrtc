import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui' as ui;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

import 'package:dart_webrtc/dart_webrtc.dart';
import 'package:web/web.dart' as web;
import 'package:webrtc_interface/webrtc_interface.dart';

import 'rtc_video_renderer_impl.dart';

class RTCVideoView extends StatefulWidget {
  RTCVideoView(
    this._renderer, {
    super.key,
    this.objectFit = RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
    this.mirror = false,
    this.filterQuality = FilterQuality.low,
    this.placeholderBuilder,
  });

  final RTCVideoRenderer _renderer;
  final RTCVideoViewObjectFit objectFit;
  final bool mirror;
  final FilterQuality filterQuality;
  final WidgetBuilder? placeholderBuilder;

  @override
  RTCVideoViewState createState() => RTCVideoViewState();
}

class RTCVideoViewState extends State<RTCVideoView> {
  RTCVideoViewState();

  RTCVideoRenderer get videoRenderer => widget._renderer;

  @override
  void initState() {
    super.initState();
    videoRenderer.addListener(_onRendererListener);
    videoRenderer.mirror = widget.mirror;
    videoRenderer.objectFit =
        widget.objectFit == RTCVideoViewObjectFit.RTCVideoViewObjectFitContain
            ? 'contain'
            : 'cover';

    if (!useHtmlElementView) {
      _startCapture();
    }
  }

  void _onRendererListener() {
    if (mounted) setState(() {});
  }

  int _generation = 0;
  int? callbackID;
  Timer? _retryTimer;
  ui.Image? capturedFrame;
  num? lastFrameTime;
  bool _captureFailureLogged = false;
  web.HTMLVideoElement? videoElement;

  bool _owns(int generation, web.HTMLVideoElement element) =>
      mounted && generation == _generation && identical(element, videoElement);

  void _stopCapture() {
    _generation++;
    _retryTimer?.cancel();
    _retryTimer = null;
    final element = videoElement;
    if (element != null && callbackID != null) {
      element.cancelVideoFrameCallbackWithFallback(callbackID!);
    }
    callbackID = null;
    videoElement = null;
    lastFrameTime = null;
    capturedFrame?.dispose();
    capturedFrame = null;
  }

  void _startCapture() {
    final generation = _generation;
    _pollForElement(generation);
  }

  void _pollForElement(int generation) {
    if (!mounted || generation != _generation) return;
    final element = videoRenderer.findHtmlView();
    if (element == null) {
      _retryTimer = Timer(
        const Duration(milliseconds: 100),
        () => _pollForElement(generation),
      );
      return;
    }
    videoElement = element;
    updateElement();
    _scheduleFrame(element, generation);
  }

  void _scheduleFrame(web.HTMLVideoElement element, int generation) {
    if (!_owns(generation, element)) return;
    callbackID = element.requestVideoFrameCallbackWithFallback(
      ((JSAny now, JSAny metadata) {
        if (!_owns(generation, element)) return;
        callbackID = null;
        _frameCallback(element, generation);
      }).toJS,
    );
  }

  void _frameCallback(web.HTMLVideoElement element, int generation) {
    if (!_owns(generation, element)) return;
    if (element.readyState <= 2) {
      _scheduleFrame(element, generation);
      return;
    }
    _capture(element, generation).then((success) {
      if (!_owns(generation, element)) return;
      if (success) {
        _scheduleFrame(element, generation);
      } else {
        _retryTimer = Timer(
          const Duration(milliseconds: 100),
          () => _scheduleFrame(element, generation),
        );
      }
    });
  }

  Future<bool> _capture(web.HTMLVideoElement element, int generation) async {
    if (lastFrameTime == element.currentTime) return true;
    lastFrameTime = element.currentTime;
    try {
      final image = await captureImage(element);
      if (!_owns(generation, element)) {
        image.dispose();
        return true;
      }
      setState(() {
        capturedFrame?.dispose();
        capturedFrame = image;
      });
      _captureFailureLogged = false;
      return true;
    } on web.DOMException catch (error) {
      lastFrameTime = null;
      if (error.name != 'InvalidStateError' && !_captureFailureLogged) {
        debugPrint('RTCVideoView: frame capture failed: $error');
        _captureFailureLogged = true;
      }
      return false;
    } catch (error) {
      if (!_owns(generation, element)) return false;
      if (error is Error) rethrow;
      lastFrameTime = null;
      if (!_captureFailureLogged) {
        debugPrint('RTCVideoView: frame capture failed: $error');
        _captureFailureLogged = true;
      }
      return false;
    }
  }

  @visibleForTesting
  Future<bool> captureFrame() => _capture(videoElement!, _generation);

  @visibleForTesting
  Future<ui.Image> captureImage(web.HTMLVideoElement element) async =>
      await ui_web.createImageFromTextureSource(
        element,
        width: element.videoWidth,
        height: element.videoHeight,
        transferOwnership: true,
      );

  @override
  void dispose() {
    _stopCapture();
    videoRenderer.removeListener(_onRendererListener);
    super.dispose();
  }

  Size? size;

  void updateElement() {
    if (videoElement != null && size != null) {
      videoElement!.width = size!.width.toInt();
      videoElement!.height = size!.height.toInt();
    }
  }

  @override
  void didUpdateWidget(RTCVideoView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget._renderer, videoRenderer)) {
      oldWidget._renderer.removeListener(_onRendererListener);
      _stopCapture();
      videoRenderer.addListener(_onRendererListener);
      if (!useHtmlElementView) _startCapture();
    }
    videoRenderer.mirror = widget.mirror;
    videoRenderer.objectFit =
        widget.objectFit == RTCVideoViewObjectFit.RTCVideoViewObjectFitContain
            ? 'contain'
            : 'cover';
  }

  Widget buildVideoElementView() {
    if (useHtmlElementView) {
      return HtmlElementView(viewType: videoRenderer.viewType);
    } else {
      return LayoutBuilder(
        builder: (context, constraints) {
          if (videoElement != null && size != constraints.biggest) {
            size = constraints.biggest;
            updateElement();
          }

          return Stack(
            children: [
              if (capturedFrame != null)
                Positioned.fill(
                  child: FittedBox(
                    fit: switch (widget.objectFit) {
                      RTCVideoViewObjectFit.RTCVideoViewObjectFitContain =>
                        BoxFit.contain,
                      RTCVideoViewObjectFit.RTCVideoViewObjectFitCover =>
                        BoxFit.cover,
                    },
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: capturedFrame!.width.toDouble(),
                      height: capturedFrame!.height.toDouble(),
                      child: CustomPaint(
                        willChange: true,
                        painter: _ImageFlipPainter(
                          capturedFrame!,
                          widget.mirror,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      );
    }
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
                : widget.placeholderBuilder?.call(context) ?? Container(),
          ),
        );
      },
    );
  }
}

typedef _VideoFrameRequestCallback = JSFunction;

extension _HTMLVideoElementRequestAnimationFrame on web.HTMLVideoElement {
  int requestVideoFrameCallbackWithFallback(
    _VideoFrameRequestCallback callback,
  ) {
    if (hasProperty('requestVideoFrameCallback'.toJS).toDart) {
      return requestVideoFrameCallback(callback);
    } else {
      return web.window.requestAnimationFrame(
        (double num) {
          callback.callAsFunction(this, 0.toJS, 0.toJS);
        }.toJS,
      );
    }
  }

  void cancelVideoFrameCallbackWithFallback(int callbackID) {
    if (hasProperty('requestVideoFrameCallback'.toJS).toDart) {
      cancelVideoFrameCallback(callbackID);
    } else {
      web.window.cancelAnimationFrame(callbackID);
    }
  }

  external int requestVideoFrameCallback(_VideoFrameRequestCallback callback);
  external void cancelVideoFrameCallback(int callbackID);
}

class _ImageFlipPainter extends CustomPainter {
  _ImageFlipPainter(this.image, this.flip);

  final ui.Image image;
  final bool flip;

  @override
  void paint(Canvas canvas, Size size) {
    if (flip) {
      canvas.scale(-1, 1);
      canvas.drawImage(
        image,
        Offset(-size.width, 0),
        Paint()..filterQuality = ui.FilterQuality.high,
      );
    } else {
      canvas.drawImage(
        image,
        Offset(0, 0),
        Paint()..filterQuality = ui.FilterQuality.high,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
