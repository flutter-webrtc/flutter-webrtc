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

  dynamic onAspectRatioChanged;

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

	double get aspectRatio =>
			_width == 0 || _height == 0 ? 1 : _width / _height;

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
        break;
      case 'didTextureChangeVideoSize':
        _width = 0.0 + map['width'];
        _height = 0.0 + map['height'];
        break;
      case 'didFirstFrameRendered':
        break;
    }
     if(this.onAspectRatioChanged != null ){
      this.onAspectRatioChanged();
    }
  }

  void errorListener(Object obj) {
    final PlatformException e = obj;
    throw e;
  }
}

class RTCVideoView extends StatefulWidget {
  RTCVideoRenderer _renderer;
  RTCVideoView(this._renderer);
  @override
  _RTCVideoViewState createState() => new _RTCVideoViewState(_renderer);
}

class _RTCVideoViewState extends State<RTCVideoView> {
  RTCVideoRenderer _renderer;
  double _aspectRatio;
  _RTCVideoViewState(this._renderer);

  @override
  void initState() {
    super.initState();
    _setCallbacks();
    _aspectRatio = _renderer.aspectRatio;
  }

  @override
  void deactivate() {
    super.deactivate();
    _renderer.onAspectRatioChanged = null;
  }

  void _setCallbacks() {
    _renderer.onAspectRatioChanged = (){
      setState(() {
        _aspectRatio = _renderer.aspectRatio;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
        child: (_renderer._textureId == null || _renderer._srcObject == null)
            ? new Container()
            : new AspectRatio(
                aspectRatio: _aspectRatio,
                child: new Texture(textureId: _renderer._textureId)));
  }
}
