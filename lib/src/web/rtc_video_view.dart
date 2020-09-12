import 'dart:async';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../enums.dart';
import './ui_fake.dart' if (dart.library.html) 'dart:ui' as ui;
import 'media_stream.dart';

// An error code value to error name Map.
// See: https://developer.mozilla.org/en-US/docs/Web/API/MediaError/code
const Map<int, String> _kErrorValueToErrorName = {
  1: 'MEDIA_ERR_ABORTED',
  2: 'MEDIA_ERR_NETWORK',
  3: 'MEDIA_ERR_DECODE',
  4: 'MEDIA_ERR_SRC_NOT_SUPPORTED',
};

// An error code value to description Map.
// See: https://developer.mozilla.org/en-US/docs/Web/API/MediaError/code
const Map<int, String> _kErrorValueToErrorDescription = {
  1: 'The user canceled the fetching of the video.',
  2: 'A network error occurred while fetching the video, despite having previously been available.',
  3: 'An error occurred while trying to decode the video, despite having previously been determined to be usable.',
  4: 'The video has been found to be unsuitable (missing or in a format not supported by your browser).',
};

// The default error message, when the error is an empty string
// See: https://developer.mozilla.org/en-US/docs/Web/API/MediaError/message
const String _kDefaultErrorMessage =
    'No further diagnostic information can be determined or provided.';

@immutable
class RTCVideoValue {
  const RTCVideoValue({
    this.width = 0.0,
    this.height = 0.0,
    this.rotation = 0,
    this.renderVideo = false,
  });
  static const RTCVideoValue empty = RTCVideoValue();
  final double width;
  final double height;
  final int rotation;
  final bool renderVideo;
  double get aspectRatio {
    if (width == 0.0 || height == 0.0) {
      return 1.0;
    }
    return (rotation == 90 || rotation == 270)
        ? height / width
        : width / height;
  }

  RTCVideoValue copyWith({
    double width,
    double height,
    int rotation,
    bool renderVideo,
  }) {
    return RTCVideoValue(
      width: width ?? this.width,
      height: height ?? this.height,
      rotation: rotation ?? this.rotation,
      renderVideo: (this.width != 0 && this.height != 0 && renderVideo) ??
          this.renderVideo,
    );
  }

  @override
  String toString() =>
      '$runtimeType(width: $width, height: $height, rotation: $rotation)';
}

class RTCVideoRenderer extends ValueNotifier<RTCVideoValue> {
  RTCVideoRenderer()
      : textureId = _textureCounter++,
        super(RTCVideoValue.empty);

  static int _textureCounter = 1;
  final int textureId;
  html.VideoElement videoElement;
  MediaStream _srcObject;

  bool get muted => videoElement?.muted ?? true;

  set muted(bool mute) => videoElement?.muted = mute;

  bool get renderVideo => videoElement != null && srcObject != null;

  Future<void> initialize() async {
    videoElement = html.VideoElement()
      //..src = 'https://flutter-webrtc-video-view-RTCVideoRenderer-$textureId'
      ..autoplay = true
      ..controls = false
      ..style.objectFit = 'contain' // contain or cover
      ..style.border = 'none';

    // Allows Safari iOS to play the video inline
    videoElement.setAttribute('playsinline', 'true');

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
        'RTCVideoRenderer-$textureId', (int viewId) => videoElement);

    videoElement.onCanPlay.listen((dynamic _) {
      value = value.copyWith(
          rotation: 0,
          width: videoElement.videoWidth.toDouble() ?? 0.0,
          height: videoElement.videoHeight.toDouble() ?? 0.0,
          renderVideo: renderVideo);
      print('RTCVideoRenderer: videoElement.onCanPlay ${value.toString()}');
    });

    videoElement.onResize.listen((dynamic _) {
      value = value.copyWith(
          rotation: 0,
          width: videoElement.videoWidth.toDouble() ?? 0.0,
          height: videoElement.videoHeight.toDouble() ?? 0.0,
          renderVideo: renderVideo);
      print('RTCVideoRenderer: videoElement.onResize ${value.toString()}');
    });

    // The error event fires when some form of error occurs while attempting to load or perform the media.
    videoElement.onError.listen((html.Event _) {
      // The Event itself (_) doesn't contain info about the actual error.
      // We need to look at the HTMLMediaElement.error.
      // See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLMediaElement/error
      var error = videoElement.error;
      throw PlatformException(
        code: _kErrorValueToErrorName[error.code],
        message: error.message != '' ? error.message : _kDefaultErrorMessage,
        details: _kErrorValueToErrorDescription[error.code],
      );
    });

    videoElement.onEnded.listen((dynamic _) {
      print('RTCVideoRenderer: videoElement.onEnded');
    });
  }

  MediaStream get srcObject => _srcObject;

  set srcObject(MediaStream stream) {
    if (videoElement == null) throw 'Call initialize before setting the stream';

    if (stream == null) {
      videoElement.srcObject = null;
      _srcObject = null;
      return;
    }
    _srcObject = stream;
    videoElement.srcObject = stream?.jsStream;
    videoElement.muted = stream?.ownerTag == 'local' ?? false;
    value = value.copyWith(renderVideo: renderVideo);
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await _srcObject?.dispose();
    _srcObject = null;
    videoElement.removeAttribute('src');
    videoElement.load();
  }
}

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

  @override
  void initState() {
    super.initState();
    widget._renderer?.addListener(() => setState(() {}));
  }

  Widget buildVideoElementView(RTCVideoViewObjectFit objFit, bool mirror) {
    // TODO(cloudwebrtc): Add css style for mirror.
    widget._renderer.videoElement.style.objectFit =
        objFit == RTCVideoViewObjectFit.RTCVideoViewObjectFitContain
            ? 'contain'
            : 'cover';
    return HtmlElementView(
        viewType: 'RTCVideoRenderer-${widget._renderer.textureId}');
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
