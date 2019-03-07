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

typedef void VideoAspectRatioCallback(double aspectRatio);

class RTCVideoRenderer {
  MethodChannel _channel = WebRTC.methodChannel();
  int _textureId;
  int _rotation = 0;
  double _width = 0.0, _height = 0.0;
  bool _mirror;
  double _aspectRatio = 1.0;
  MediaStream _srcObject;
  RTCVideoViewObjectFit _objectFit =
      RTCVideoViewObjectFit.RTCVideoViewObjectFitContain;
  StreamSubscription<dynamic> _eventSubscription;

  VideoAspectRatioCallback onAspectRatioChanged;

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
  
  int get textureId => _textureId;

  double get aspectRatio => _aspectRatio;

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
        _updateAspectRatio();
        break;
      case 'didTextureChangeVideoSize':
        _width = 0.0 + map['width'];
        _height = 0.0 + map['height'];
        _updateAspectRatio();
        break;
      case 'didFirstFrameRendered':
        _updateAspectRatio();
        break;
    }
  }

  void _updateAspectRatio() {
    double aspectRatio = _aspectRatio;
    double textureWidth = 0.0,
        textureHeight = 0.0;
    if (_rotation == 90 || _rotation == 270) {
      textureWidth = min(_width, _height);
      textureHeight = max(_width, _height);
      if (_height != 0.0) {
        aspectRatio = _width / _height;
      }
    } else {
      textureWidth = max(_width, _height);
      textureHeight = min(_width, _height);
      if (_height != 0.0) {
        aspectRatio = _width / _height;
      }
    }
    if(this.onAspectRatioChanged != null && _aspectRatio != aspectRatio){
      this.onAspectRatioChanged(aspectRatio);
    }
    _aspectRatio = aspectRatio;
  }

  void errorListener(Object obj) {
    final PlatformException e = obj;
    throw e;
  }
}

class RTCVideoView extends StatefulWidget {
  RTCVideoRenderer renderer;
  RTCVideoView(this.renderer);
  @override
  _RTCVideoViewState createState() => new _RTCVideoViewState(renderer);
}

class _RTCVideoViewState extends State<RTCVideoView> {
  RTCVideoRenderer renderer;
  double _aspectRatio;

  _RTCVideoViewState(this.renderer);

  @override
  void initState() {
    super.initState();
    _setCallbacks();
    _aspectRatio = renderer.aspectRatio;
  }

  @override
  void deactivate() {
    super.deactivate();
    renderer.onAspectRatioChanged = null;
  }

  void _setCallbacks() {
    renderer.onAspectRatioChanged = (double aspectRatio ){
      setState(() {
        _aspectRatio = aspectRatio;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
        child: (this.renderer._textureId == null || this.renderer._srcObject == null)
            ? new Container()
            : new AspectRatio(
                aspectRatio: _aspectRatio,
                child: new Texture(textureId: this.renderer._textureId)));
  }
}
