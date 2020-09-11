import 'dart:async';
import 'dart:html' as html;

import 'package:flutter/material.dart';

import '../enums.dart';
import './ui_fake.dart' if (dart.library.html) 'dart:ui' as ui;
import 'media_stream.dart';

typedef VideoRotationChangeCallback = void Function(
    int textureId, int rotation);
typedef VideoSizeChangeCallback = void Function(
    int textureId, double width, double height);

class RTCVideoRenderer {
  RTCVideoRenderer();
  double _width = 0.0, _height = 0.0;
  MediaStream _srcObject;
  VideoSizeChangeCallback onVideoSizeChanged;
  VideoRotationChangeCallback onVideoRotationChanged;
  dynamic onFirstFrameRendered;
  var isFirstFrameRendered = false;
  dynamic onStateChanged;
  HtmlElementView htmlElementView;
  html.VideoElement _htmlVideoElement;

  static final _videoViews = <html.VideoElement>[];

  bool get isMuted => _htmlVideoElement?.muted ?? true;
  set isMuted(bool i) => _htmlVideoElement?.muted = i;

  static void fixVideoElements() => _videoViews.forEach((v) => v.play());

  void initialize() async {
    print('You don\'t have to call RTCVideoRenderer.initialize on Flutter Web');
  }

  int get rotation => 0;

  double get width => _width ?? 1080;

  double get height => _height ?? 1920;

  int get textureId => 0;

  double get aspectRatio =>
      (_width == 0 || _height == 0) ? (9 / 16) : _width / _height;

  MediaStream get srcObject => _srcObject;

  set srcObject(MediaStream stream) {
    _srcObject = stream;

    if (_srcObject == null) {
      findHtmlView()?.srcObject = null;
      return;
    }

    if (htmlElementView != null) {
      findHtmlView()?.srcObject = stream?.jsStream;
    }

    ui.platformViewRegistry.registerViewFactory(stream.id, (int viewId) {
      final x = html.VideoElement();
      x.autoplay = true;
      x.muted = _srcObject.ownerTag == 'local';
      x.srcObject = stream.jsStream;
      x.id = stream.id;
      _htmlVideoElement = x;
      _videoViews.add(x);
      return x;
    });
    htmlElementView = HtmlElementView(viewType: stream.id);
    if (onStateChanged != null) {
      onStateChanged();
    }
  }

  void findAndApply(Size size) {
    final htmlView = findHtmlView();
    if (_srcObject != null && htmlView != null) {
      if (htmlView.width == size.width.toInt() &&
          htmlView.height == size.height.toInt()) return;
      htmlView.srcObject = _srcObject.jsStream;
      htmlView.width = size.width.toInt();
      htmlView.height = size.height.toInt();
      htmlView.onLoadedMetadata.listen((_) {
        if (htmlView.videoWidth != 0 &&
            htmlView.videoHeight != 0 &&
            (_width != htmlView.videoWidth ||
                _height != htmlView.videoHeight)) {
          _width = htmlView.videoWidth.toDouble();
          _height = htmlView.videoHeight.toDouble();
          if (onVideoSizeChanged != null) {
            onVideoSizeChanged(0, _width, _height);
          }
        }
        if (!isFirstFrameRendered && onFirstFrameRendered != null) {
          onFirstFrameRendered();
          isFirstFrameRendered = true;
        }
      });
      htmlView.onResize.listen((_) {
        if (htmlView.videoWidth != 0 &&
            htmlView.videoHeight != 0 &&
            (_width != htmlView.videoWidth ||
                _height != htmlView.videoHeight)) {
          _width = htmlView.videoWidth.toDouble();
          _height = htmlView.videoHeight.toDouble();
          if (onVideoSizeChanged != null) {
            onVideoSizeChanged(0, _width, _height);
          }
        }
      });
      if (htmlView.videoWidth != 0 &&
          htmlView.videoHeight != 0 &&
          (_width != htmlView.videoWidth || _height != htmlView.videoHeight)) {
        _width = htmlView.videoWidth.toDouble();
        _height = htmlView.videoHeight.toDouble();
        if (onVideoSizeChanged != null) onVideoSizeChanged(0, _width, _height);
      }
    }
  }

  html.VideoElement findHtmlView() {
    if (_htmlVideoElement != null) return _htmlVideoElement;
    final fltPv = html.document.getElementsByTagName('flt-platform-view');
    if (fltPv.isEmpty) return null;
    final lastChild = (fltPv.first as html.Element).shadowRoot.lastChild;
    if (!(lastChild is html.VideoElement)) return null;
    final videoElement = lastChild as html.VideoElement;
    if (_srcObject != null && videoElement.id != _srcObject.id) return null;
    return lastChild;
  }

  Future<Null> dispose() async {
    // TODO(cloudwebrtc): ???
    // https://stackoverflow.com/questions/3258587/how-to-properly-unload-destroy-a-video-element/28060352
  }
}

class RTCVideoView extends StatefulWidget {
  RTCVideoView(this._renderer,
      {Key key,
      this.objectFit = RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
      this.mirror = false})
      : assert(objectFit != null),
        assert(mirror != null),
        super(key: key);

  final RTCVideoRenderer _renderer;
  final RTCVideoViewObjectFit objectFit;
  final mirror;

  @override
  _RTCVideoViewState createState() => _RTCVideoViewState(_renderer);
}

class _RTCVideoViewState extends State<RTCVideoView> {
  _RTCVideoViewState(this._renderer);

  final RTCVideoRenderer _renderer;
  double _aspectRatio;

  @override
  void initState() {
    super.initState();
    _setCallbacks();
    _aspectRatio = _renderer.aspectRatio;
  }

  @override
  void dispose() {
    super.dispose();
    _renderer.onStateChanged = null;
  }

  void _setCallbacks() {
    _renderer.onStateChanged = () {
      setState(() {
        _aspectRatio = _renderer.aspectRatio;
      });
    };
  }

  Widget _buildVideoView(BoxConstraints constraints) {
    _renderer.findAndApply(constraints.biggest);
    return Container(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: SizedBox(
            width: constraints.maxHeight * _aspectRatio,
            height: constraints.maxHeight,
            child: _renderer.htmlElementView ?? Container()));
  }

  @override
  Widget build(BuildContext context) {
    var renderVideo = _renderer._srcObject != null;
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Center(
          child: renderVideo ? _buildVideoView(constraints) : Container());
    });
  }
}
