import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'media_stream.dart';
import 'utils.dart';

enum RTCVideoViewObjectFit {
  RTCVideoViewObjectFitContain,
  RTCVideoViewObjectFitCover,
}

typedef void VideoRotationChangeCallback(int textureId, int rotation);
typedef void VideoSizeChangeCallback(
    int textureId, double width, double height);

class RTCVideoRenderer {
  MethodChannel _channel = WebRTC.methodChannel();
  int _textureId;
  int _rotation = 0;
  double _width = 0.0, _height = 0.0;
  bool _mirror;
  MediaStream _srcObject;
  RTCVideoViewObjectFit _objectFit =
      RTCVideoViewObjectFit.RTCVideoViewObjectFitContain;
  StreamSubscription<dynamic> _eventSubscription;
  VideoSizeChangeCallback onVideoSizeChanged;
  VideoRotationChangeCallback onVideoRotationChanged;
  dynamic onFirstFrameRendered;

  initialize() async {
    final Map<dynamic, dynamic> response =
        await _channel.invokeMethod('createVideoRenderer', {});
    _textureId = response['textureId'];
    _eventSubscription = _eventChannelFor(_textureId)
        .receiveBroadcastStream()
        .listen(eventListener, onError: errorListener);
  }

  int get rotation => _rotation;

  double get width => _width;

  double get height => _height;

  set mirror(bool mirror) {
    _mirror = mirror;
  }

  set objectFit(RTCVideoViewObjectFit objectFit) {
    _objectFit = objectFit;
  }

  set srcObject(MediaStream stream) {
    _srcObject = stream;
    _channel.invokeMethod('videoRendererSetSrcObject', <String, dynamic>{
      'textureId': _textureId,
      'streamId': stream != null ? stream.id : ''
    });
  }

  Future<Null> dispose() async {
    await _channel.invokeMethod(
      'videoRendererDispose',
      <String, dynamic>{'textureId': _textureId},
    );
  }

  EventChannel _eventChannelFor(int textureId) {
    return new EventChannel('cloudwebrtc.com/WebRTC/Texture$textureId');
  }

  void eventListener(dynamic event) {
    final Map<dynamic, dynamic> map = event;
    switch (map['event']) {
      case 'didTextureChangeRotation':
        _rotation = map['rotation'];
        if (this.onVideoRotationChanged != null)
          this.onVideoRotationChanged(_textureId, _rotation);
        break;
      case 'didTextureChangeVideoSize':
        _width = map['width'];
        _height = map['height'];
        if (this.onVideoSizeChanged != null)
          this.onVideoSizeChanged(_textureId, _width, _height);
        break;
      case 'didFirstFrameRendered':
        if (this.onFirstFrameRendered != null) this.onFirstFrameRendered();
        break;
    }
  }

  void errorListener(Object obj) {
    final PlatformException e = obj;
    throw e;
  }
}

class RTCVideoView extends StatefulWidget {
  final RTCVideoRenderer renderer;
  RTCVideoView(this.renderer);
  @override
  _RTCVideoViewState createState() => new _RTCVideoViewState(renderer);
}

class _RTCVideoViewState extends State<RTCVideoView> {
  final RTCVideoRenderer renderer;
  var aspectRatio = 1.0;

  _RTCVideoViewState(this.renderer);

  @override
  void initState() {
    super.initState();
    _setCallbacks();
  }

  @override
  void deactivate() {
    super.deactivate();
    renderer.onVideoRotationChanged = null;
    renderer.onVideoSizeChanged = null;
    renderer.onFirstFrameRendered = null;
  }

  void _setCallbacks() {
    renderer.onVideoRotationChanged = (int textureId, int rotation) {
      setState(() {
        _updateContainerSize();
      });
    };
    renderer.onVideoSizeChanged = (int textureId, double width, double height) {
      setState(() {
        _updateContainerSize();
      });
    };
    renderer.onFirstFrameRendered = () {
      setState(() {
        _updateContainerSize();
      });
    };
  }

  void _updateContainerSize() {
    double textureWidth = 0.0, textureHeight = 0.0;
    if (renderer.rotation == 90 || renderer.rotation == 270) {
      textureWidth = min(renderer.width, renderer.height);
      textureHeight = max(renderer.width, renderer.height);
      aspectRatio = textureWidth / textureHeight;
    } else {
      textureWidth = max(renderer.width, renderer.height);
      textureHeight = min(renderer.width, renderer.height);
      aspectRatio = textureWidth / textureHeight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
        child: (this.renderer._textureId == null || this.renderer._srcObject == null)
            ? new Container()
            : new AspectRatio(
                aspectRatio: aspectRatio,
                child: new Texture(textureId: this.renderer._textureId)));
  }
}
