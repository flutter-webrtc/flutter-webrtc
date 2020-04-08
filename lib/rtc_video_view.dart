import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'media_stream.dart';
import 'utils.dart';
import 'enums.dart';

class RTCVideoRenderer {
  MethodChannel _channel = WebRTC.methodChannel();
  int _textureId;
  int _rotation = 0;
  double _width = 0.0, _height = 0.0;
  bool _mirror = false;
  double _aspectRatio = 1.0;
  MediaStream _srcObject;
  StreamSubscription<dynamic> _eventSubscription;

  dynamic onStateChanged;

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

  double get aspectRatio => (_width == 0 || _height == 0)
      ? 1.0
      : (_rotation == 90 || _rotation == 270)
          ? _height / _width
          : _width / _height;

  bool get mirror => _mirror;

  set mirror(bool mirror) {
    _mirror = mirror;
    if (this.onStateChanged != null) {
      this.onStateChanged();
    }
  }

  set srcObject(MediaStream stream) {
    _srcObject = stream;
    _channel.invokeMethod('videoRendererSetSrcObject', <String, dynamic>{
      'textureId': _textureId,
      'streamId': stream != null ? stream.id : '',
      'ownerTag': stream != null ? stream.ownerTag : ''
    });
  }

  Future<Null> dispose() async {
    await _eventSubscription?.cancel();
    await _channel.invokeMethod(
      'videoRendererDispose',
      <String, dynamic>{'textureId': _textureId},
    );
  }

  EventChannel _eventChannelFor(int textureId) {
    return new EventChannel('FlutterWebRTC/Texture$textureId');
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
    if (this.onStateChanged != null) {
      this.onStateChanged();
    }
  }

  void errorListener(Object obj) {
    final PlatformException e = obj;
    throw e;
  }
}

class RTCVideoView extends StatefulWidget {
  final RTCVideoRenderer _renderer;

  final RTCVideoViewObjectFit objectFit;

  RTCVideoView(
    this._renderer, {
    Key key,
    this.objectFit = RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
  })  : assert(objectFit != null),
        super(key: key);

  @override
  _RTCVideoViewState createState() => new _RTCVideoViewState();
}

class _RTCVideoViewState extends State<RTCVideoView> {
  double _aspectRatio;
  bool _mirror;

  @override
  void initState() {
    super.initState();
    _setCallbacks();
    _aspectRatio = widget._renderer.aspectRatio;
    _mirror = widget._renderer.mirror;
  }

  @override
  void dispose() {
    super.dispose();
    widget._renderer.onStateChanged = null;
  }

  void _setCallbacks() {
    widget._renderer.onStateChanged = () {
      setState(() {
        _aspectRatio = widget._renderer.aspectRatio;
        _mirror = widget._renderer.mirror;
      });
    };
  }

  Widget _buildVideoView(BoxConstraints constraints) {
    return Container(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: FittedBox(
            fit: widget.objectFit == RTCVideoViewObjectFit.RTCVideoViewObjectFitContain ? BoxFit.contain : BoxFit.cover,
            child: new Center(
                child: new SizedBox(
                    width: constraints.maxHeight * _aspectRatio,
                    height: constraints.maxHeight,
                    child: new Transform(
                        transform: Matrix4.identity()
                          ..rotateY(_mirror ? -pi : 0.0),
                        alignment: FractionalOffset.center,
                        child:
                            new Texture(textureId: widget._renderer._textureId))))));
  }

  @override
  Widget build(BuildContext context) {
    bool renderVideo =
        (widget._renderer._textureId != null && widget._renderer._srcObject != null);

    return new LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return new Center(
          child: renderVideo ? _buildVideoView(constraints) : new Container());
    });
  }
}
