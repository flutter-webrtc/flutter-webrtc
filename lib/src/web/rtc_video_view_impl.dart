import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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

@visibleForTesting
class VideoFrameMetrics {
  int importedFrames = 0;
  int paintInvalidations = 0;
  int paintedFrames = 0;
  int skippedFrames = 0;
  int widgetBuilds = 0;
  int concurrentImports = 0;
  int maxConcurrentImports = 0;
}

@visibleForTesting
class VideoFrameState extends ChangeNotifier {
  VideoFrameState(this.metrics);

  final VideoFrameMetrics metrics;
  ui.Image? _image;
  ui.Image? _paintedImage;
  ui.Image? _retiredImage;
  bool _disposed = false;

  ui.Image? get image => _image;

  void replace(ui.Image image) {
    if (_disposed) {
      image.dispose();
      return;
    }
    final previous = _image;
    _image = image;
    if (previous != null && !identical(previous, _paintedImage)) {
      previous.dispose();
    }
    metrics.paintInvalidations++;
    notifyListeners();
  }

  void clear() {
    if (_disposed || _image == null) return;
    final previous = _image;
    _image = null;
    if (!identical(previous, _paintedImage)) {
      previous?.dispose();
    }
    metrics.paintInvalidations++;
    notifyListeners();
  }

  void markPainted(ui.Image? image) {
    if (_disposed) return;
    metrics.paintedFrames++;
    final previous = _paintedImage;
    _paintedImage = image;
    if (previous == null || identical(previous, image)) return;

    _retiredImage?.dispose();
    _retiredImage = previous;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (identical(_retiredImage, previous)) {
        _retiredImage = null;
        previous.dispose();
      }
    });
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    final image = _image;
    final paintedImage = _paintedImage;
    final retiredImage = _retiredImage;
    _image = null;
    _paintedImage = null;
    _retiredImage = null;
    image?.dispose();
    if (paintedImage != null && !identical(paintedImage, image)) {
      paintedImage.dispose();
    }
    if (retiredImage != null &&
        !identical(retiredImage, image) &&
        !identical(retiredImage, paintedImage)) {
      retiredImage.dispose();
    }
    super.dispose();
  }
}

class RTCVideoViewState extends State<RTCVideoView> {
  RTCVideoRenderer get videoRenderer => widget._renderer;

  final VideoFrameMetrics frameMetrics = VideoFrameMetrics();
  late final VideoFrameState frameState = VideoFrameState(frameMetrics);

  int _pipelineGeneration = 0;
  int _sourceGeneration = 0;
  int? _firstFrameGeneration;
  int? _firstFrameCallbackScheduledGeneration;
  ui.Image? _firstFrameCandidate;
  int? callbackID;
  Timer? _elementRetryTimer;
  web.HTMLVideoElement? videoElement;
  num? _lastFrameTime;
  bool _frameImportInProgress = false;
  bool _pendingFrame = false;
  bool _captureFailureLogged = false;
  late bool _showVideo;

  @override
  void initState() {
    super.initState();
    _showVideo = _canDisplayVideo;
    _sourceGeneration = videoRenderer.sourceGeneration;
    videoRenderer.addListener(_onRendererListener);
    _applyRendererPresentation();
    if (!useHtmlElementView && _showVideo) {
      _startFrameLoop();
    }
  }

  bool get _canDisplayVideo =>
      videoRenderer.renderVideo && videoRenderer.hasVideoTracks;

  void _applyRendererPresentation() {
    videoRenderer.mirror = widget.mirror;
    videoRenderer.objectFit =
        widget.objectFit == RTCVideoViewObjectFit.RTCVideoViewObjectFitContain
            ? 'contain'
            : 'cover';
  }

  void _onRendererListener() {
    if (!mounted) return;
    final showVideo = _canDisplayVideo;
    final sourceChanged = _sourceGeneration != videoRenderer.sourceGeneration;
    if (sourceChanged) {
      _sourceGeneration = videoRenderer.sourceGeneration;
      _firstFrameGeneration = null;
      _firstFrameCallbackScheduledGeneration = null;
      _firstFrameCandidate = null;
      if (!useHtmlElementView) {
        _stopFrameLoop(clearFrame: true);
      }
    }
    if (_showVideo != showVideo) {
      setState(() => _showVideo = showVideo);
    }
    if (!useHtmlElementView && videoElement?.ended == true) {
      _stopFrameLoop(clearFrame: false);
    } else if (!useHtmlElementView &&
        showVideo &&
        (sourceChanged || videoElement == null)) {
      _startFrameLoop();
    } else if (!useHtmlElementView && !showVideo) {
      _stopFrameLoop(clearFrame: true);
    }
  }

  bool _ownsPipeline(int generation, web.HTMLVideoElement element) =>
      mounted &&
      generation == _pipelineGeneration &&
      _sourceGeneration == videoRenderer.sourceGeneration &&
      _canDisplayVideo &&
      !element.ended &&
      identical(element, videoElement);

  void _startFrameLoop() {
    if (useHtmlElementView || !_canDisplayVideo) return;
    if (videoElement != null || _elementRetryTimer != null) return;
    final generation = _pipelineGeneration;
    _findVideoElement(generation);
  }

  void _findVideoElement(int generation) {
    if (!mounted || generation != _pipelineGeneration || !_canDisplayVideo) {
      return;
    }
    final element = videoRenderer.findHtmlView();
    if (element == null) {
      _elementRetryTimer = Timer(const Duration(milliseconds: 100), () {
        _elementRetryTimer = null;
        _findVideoElement(generation);
      });
      return;
    }
    videoElement = element;
    _scheduleFrame(element, generation);
  }

  void _stopFrameLoop({required bool clearFrame}) {
    _pipelineGeneration++;
    _elementRetryTimer?.cancel();
    _elementRetryTimer = null;
    final element = videoElement;
    if (element != null && callbackID != null) {
      element.cancelVideoFrameCallbackWithFallback(callbackID!);
    }
    callbackID = null;
    videoElement = null;
    _lastFrameTime = null;
    _pendingFrame = false;
    if (clearFrame) frameState.clear();
  }

  void _scheduleFrame(web.HTMLVideoElement element, int generation) {
    if (!_ownsPipeline(generation, element) || callbackID != null) return;
    callbackID = element.requestVideoFrameCallbackWithFallback(
      ((JSAny now, JSAny metadata) {
        if (!_ownsPipeline(generation, element)) return;
        callbackID = null;
        _scheduleFrame(element, generation);
        if (element.readyState <= 2 ||
            element.videoWidth == 0 ||
            element.videoHeight == 0) {
          return;
        }
        unawaited(_captureLatestFrame(element, generation));
      }).toJS,
    );
  }

  Future<void> _captureLatestFrame(
    web.HTMLVideoElement element,
    int generation, {
    bool force = false,
  }) async {
    if (!_ownsPipeline(generation, element)) return;
    if (_frameImportInProgress) {
      if (_pendingFrame) frameMetrics.skippedFrames++;
      _pendingFrame = true;
      return;
    }
    if (!force &&
        !element.supportsVideoFrameCallback &&
        _lastFrameTime == element.currentTime) {
      frameMetrics.skippedFrames++;
      return;
    }

    _lastFrameTime = element.currentTime;
    _frameImportInProgress = true;
    _pendingFrame = false;
    frameMetrics.concurrentImports++;
    frameMetrics.maxConcurrentImports = math.max(
      frameMetrics.maxConcurrentImports,
      frameMetrics.concurrentImports,
    );
    try {
      final image = await captureImage(element);
      if (!_ownsPipeline(generation, element)) {
        image.dispose();
        return;
      }
      frameMetrics.importedFrames++;
      frameState.replace(image);
      _captureFailureLogged = false;
      if (_firstFrameGeneration != _sourceGeneration) {
        _firstFrameCandidate = image;
      }
    } on web.DOMException catch (error) {
      _lastFrameTime = null;
      if (error.name != 'InvalidStateError') _logCaptureFailure(error);
    } catch (error) {
      _lastFrameTime = null;
      _logCaptureFailure(error);
    } finally {
      frameMetrics.concurrentImports--;
      _frameImportInProgress = false;
      if (_pendingFrame) {
        _pendingFrame = false;
        final currentElement = videoElement;
        final currentGeneration = _pipelineGeneration;
        if (currentElement != null &&
            _ownsPipeline(currentGeneration, currentElement)) {
          unawaited(
            _captureLatestFrame(
              currentElement,
              currentGeneration,
              force: true,
            ),
          );
        }
      }
    }
  }

  void _handleFramePainted(ui.Image image) {
    final generation = _sourceGeneration;
    if (!identical(image, _firstFrameCandidate) ||
        _firstFrameGeneration == generation ||
        _firstFrameCallbackScheduledGeneration == generation) {
      return;
    }
    _firstFrameCallbackScheduledGeneration = generation;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          generation != _sourceGeneration ||
          _firstFrameGeneration == generation) {
        return;
      }
      _firstFrameGeneration = generation;
      _firstFrameCandidate = null;
      videoRenderer.onFirstFrameRendered?.call();
    });
  }

  void _logCaptureFailure(Object error) {
    if (_captureFailureLogged) return;
    debugPrint('RTCVideoView: frame capture failed: $error');
    _captureFailureLogged = true;
  }

  @visibleForTesting
  Future<void> captureFrame() {
    final element = videoElement!;
    return _captureLatestFrame(element, _pipelineGeneration, force: true);
  }

  @visibleForTesting
  Future<ui.Image> captureImage(web.HTMLVideoElement element) async =>
      await ui_web.createImageFromTextureSource(
        element,
        width: element.videoWidth,
        height: element.videoHeight,
        transferOwnership: true,
      );

  @override
  void didUpdateWidget(RTCVideoView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget._renderer, videoRenderer)) {
      oldWidget._renderer.removeListener(_onRendererListener);
      if (!useHtmlElementView) {
        _stopFrameLoop(clearFrame: true);
      }
      videoRenderer.addListener(_onRendererListener);
      _sourceGeneration = videoRenderer.sourceGeneration;
      _firstFrameGeneration = null;
      _firstFrameCallbackScheduledGeneration = null;
      _firstFrameCandidate = null;
      _showVideo = _canDisplayVideo;
      if (!useHtmlElementView && _showVideo) {
        _startFrameLoop();
      }
    }
    _applyRendererPresentation();
  }

  @override
  void dispose() {
    if (!useHtmlElementView) {
      _stopFrameLoop(clearFrame: false);
    }
    videoRenderer.removeListener(_onRendererListener);
    frameState.dispose();
    super.dispose();
  }

  Widget _buildVideoView() {
    if (useHtmlElementView) {
      return HtmlElementView(viewType: videoRenderer.viewType);
    }
    return SizedBox.expand(
      child: CustomPaint(
        willChange: true,
        painter: VideoFramePainter(
          frameState,
          objectFit: widget.objectFit,
          mirror: widget.mirror,
          filterQuality: widget.filterQuality,
          onFramePainted: _handleFramePainted,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    frameMetrics.widgetBuilds++;
    return LayoutBuilder(
      builder: (context, constraints) => Center(
        child: SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: _showVideo
              ? _buildVideoView()
              : widget.placeholderBuilder?.call(context) ?? const SizedBox(),
        ),
      ),
    );
  }
}

typedef _VideoFrameRequestCallback = JSFunction;

extension _HTMLVideoElementRequestAnimationFrame on web.HTMLVideoElement {
  bool get supportsVideoFrameCallback =>
      hasProperty('requestVideoFrameCallback'.toJS).toDart;

  int requestVideoFrameCallbackWithFallback(
    _VideoFrameRequestCallback callback,
  ) {
    if (supportsVideoFrameCallback) {
      return requestVideoFrameCallback(callback);
    }
    return web.window.requestAnimationFrame((double _) {
      callback.callAsFunction(this, 0.toJS, 0.toJS);
    }.toJS);
  }

  void cancelVideoFrameCallbackWithFallback(int callbackID) {
    if (supportsVideoFrameCallback) {
      cancelVideoFrameCallback(callbackID);
    } else {
      web.window.cancelAnimationFrame(callbackID);
    }
  }

  external int requestVideoFrameCallback(_VideoFrameRequestCallback callback);
  external void cancelVideoFrameCallback(int callbackID);
}

@visibleForTesting
class VideoFramePainter extends CustomPainter {
  VideoFramePainter(
    this.frameState, {
    required this.objectFit,
    required this.mirror,
    required this.filterQuality,
    this.onFramePainted,
  }) : super(repaint: frameState);

  final VideoFrameState frameState;
  final RTCVideoViewObjectFit objectFit;
  final bool mirror;
  final ui.FilterQuality filterQuality;
  final ValueChanged<ui.Image>? onFramePainted;

  @override
  void paint(Canvas canvas, Size size) {
    final image = frameState.image;
    if (image == null || size.isEmpty) {
      frameState.markPainted(null);
      return;
    }

    final sourceSize = Size(image.width.toDouble(), image.height.toDouble());
    final destination = destinationRect(sourceSize, size, objectFit);

    canvas.save();
    canvas.clipRect(Offset.zero & size);
    if (mirror) {
      canvas
        ..translate(size.width, 0)
        ..scale(-1, 1);
    }
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, sourceSize.width, sourceSize.height),
      destination,
      Paint()..filterQuality = filterQuality,
    );
    canvas.restore();
    frameState.markPainted(image);
    onFramePainted?.call(image);
  }

  @visibleForTesting
  static Rect destinationRect(
    Size sourceSize,
    Size outputSize,
    RTCVideoViewObjectFit objectFit,
  ) {
    final widthScale = outputSize.width / sourceSize.width;
    final heightScale = outputSize.height / sourceSize.height;
    final scale =
        objectFit == RTCVideoViewObjectFit.RTCVideoViewObjectFitContain
            ? math.min(widthScale, heightScale)
            : math.max(widthScale, heightScale);
    final destinationSize = sourceSize * scale;
    return Rect.fromLTWH(
      (outputSize.width - destinationSize.width) / 2,
      (outputSize.height - destinationSize.height) / 2,
      destinationSize.width,
      destinationSize.height,
    );
  }

  @override
  bool shouldRepaint(covariant VideoFramePainter oldDelegate) =>
      !identical(frameState, oldDelegate.frameState) ||
      objectFit != oldDelegate.objectFit ||
      mirror != oldDelegate.mirror ||
      filterQuality != oldDelegate.filterQuality;
}
