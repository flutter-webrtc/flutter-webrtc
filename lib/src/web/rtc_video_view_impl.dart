import 'dart:async';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/src/web/media_stream_impl.dart';

import '../interface/enums.dart';
import '../interface/media_stream.dart';
import '../interface/rtc_video_renderer.dart';
import 'ui_fake.dart' if (dart.library.html) 'dart:ui' as ui;

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

class RTCVideoRendererWeb extends RTCVideoRenderer {
  RTCVideoRendererWeb() : textureId = _textureCounter++;

  static int _textureCounter = 1;
  final int textureId;
  html.VideoElement videoElement;
  MediaStream _srcObject;
  final _subscriptions = <StreamSubscription>[];

  @override
  bool get muted => videoElement?.muted ?? true;

  @override
  set muted(bool mute) => videoElement?.muted = mute;

  @override
  bool get renderVideo => videoElement != null && srcObject != null;

  @override
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

    _subscriptions.add(
      videoElement.onCanPlay.listen(
        (dynamic _) {
          _updateAllValues();
          print('RTCVideoRenderer: videoElement.onCanPlay ${value.toString()}');
        },
      ),
    );

    _subscriptions.add(
      videoElement.onResize.listen(
        (dynamic _) {
          _updateAllValues();
          print('RTCVideoRenderer: videoElement.onResize ${value.toString()}');
        },
      ),
    );

    // The error event fires when some form of error occurs while attempting to load or perform the media.
    _subscriptions.add(
      videoElement.onError.listen(
        (html.Event _) {
          // The Event itself (_) doesn't contain info about the actual error.
          // We need to look at the HTMLMediaElement.error.
          // See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLMediaElement/error
          var error = videoElement.error;
          throw PlatformException(
            code: _kErrorValueToErrorName[error.code],
            message:
                error.message != '' ? error.message : _kDefaultErrorMessage,
            details: _kErrorValueToErrorDescription[error.code],
          );
        },
      ),
    );

    _subscriptions.add(
      videoElement.onEnded.listen(
        (dynamic _) {
          print('RTCVideoRenderer: videoElement.onEnded');
        },
      ),
    );
  }

  void _updateAllValues() {
    value = value.copyWith(
        rotation: 0,
        width: videoElement?.videoWidth?.toDouble() ?? 0.0,
        height: videoElement?.videoHeight?.toDouble() ?? 0.0,
        renderVideo: renderVideo);
  }

  @override
  MediaStream get srcObject => _srcObject;

  @override
  set srcObject(MediaStream stream) {
    if (videoElement == null) throw 'Call initialize before setting the stream';

    if (stream == null) {
      videoElement.srcObject = null;
      _srcObject = null;
      return;
    }
    _srcObject = stream;
    var _native = stream as MediaStreamWeb;
    videoElement.srcObject = _native.jsStream;
    videoElement.muted = stream?.ownerTag == 'local' ?? false;
    value = value.copyWith(renderVideo: renderVideo);
  }

  @override
  Future<void> dispose() async {
    await _srcObject?.dispose();
    _srcObject = null;
    _subscriptions.forEach((s) => s.cancel());
    videoElement.removeAttribute('src');
    videoElement.load();

    return super.dispose();
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

  final RTCVideoRendererWeb _renderer;
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
