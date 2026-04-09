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

    videoElement =
        web.document.getElementById("video_${videoRenderer.viewType}")
            as web.HTMLVideoElement?;
    frameCallback(0.toJS, 0.toJS);
  }

  void _onRendererListener() {
    if (mounted) setState(() {});
  }

  int? callbackID;

  void getFrame(web.HTMLVideoElement element) {
    callbackID =
        element.requestVideoFrameCallbackWithFallback(frameCallback.toJS);
  }

  void cancelFrame(web.HTMLVideoElement element) {
    if (callbackID != null) {
      element.cancelVideoFrameCallbackWithFallback(callbackID!);
    }
  }

  void frameCallback(JSAny now, JSAny metadata) {
    final web.HTMLVideoElement? element = videoElement;
    if (element != null) {
      // only capture frames if video is playing (optimization for RAF)
      if (element.readyState > 2) {
        capture().then((_) async {
          getFrame(element);
        });
      } else {
        getFrame(element);
      }
    } else {
      if (mounted) {
        Future.delayed(Duration(milliseconds: 100)).then((_) {
          frameCallback(0.toJS, 0.toJS);
        });
      }
    }
  }

  ui.Image? capturedFrame;
  num? lastFrameTime;
  Future<void> capture() async {
    final element = videoElement!;
    if (lastFrameTime != element.currentTime) {
      lastFrameTime = element.currentTime;
      try {
        final ui.Image img = await ui_web.createImageFromTextureSource(element,
            width: element.videoWidth,
            height: element.videoHeight,
            transferOwnership: true);

        if (mounted) {
          setState(() {
            capturedFrame?.dispose();
            capturedFrame = img;
          });
        }
      } on web.DOMException catch (err) {
        lastFrameTime = null;
        if (err.name == 'InvalidStateError') {
          // We don't have enough data yet, continue on
        } else {
          rethrow;
        }
      }
    }
  }

  @override
  void dispose() {
    if (mounted) {
      super.dispose();
    }
    capturedFrame?.dispose();
    if (videoElement != null) {
      cancelFrame(videoElement!);
    }
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
    Timer(
        Duration(milliseconds: 10), () => videoRenderer.mirror = widget.mirror);
    videoRenderer.objectFit =
        widget.objectFit == RTCVideoViewObjectFit.RTCVideoViewObjectFitContain
            ? 'contain'
            : 'cover';
  }

  web.HTMLVideoElement? videoElement;

  Widget buildVideoElementView() {
    if (useHtmlElementView) {
      return HtmlElementView(viewType: videoRenderer.viewType);
    } else {
      return LayoutBuilder(builder: (context, constraints) {
        if (videoElement != null && size != constraints.biggest) {
          size = constraints.biggest;
          updateElement();
        }

        return Stack(children: [
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
                            )))))
        ]);
      });
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
      _VideoFrameRequestCallback callback) {
    if (hasProperty('requestVideoFrameCallback'.toJS).toDart) {
      return requestVideoFrameCallback(callback);
    } else {
      return web.window.requestAnimationFrame((double num) {
        callback.callAsFunction(this, 0.toJS, 0.toJS);
      }.toJS);
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
      canvas.drawImage(image, Offset(-size.width, 0),
          Paint()..filterQuality = ui.FilterQuality.high);
    } else {
      canvas.drawImage(
          image, Offset(0, 0), Paint()..filterQuality = ui.FilterQuality.high);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
