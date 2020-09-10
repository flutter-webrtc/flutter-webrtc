import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'media_stream.dart';
import 'utils.dart';
import 'enums.dart';

class RTCVideoRenderer {
  final _channel = WebRTC.methodChannel();
  int _textureId;
  int _rotation = 0;
  double _width = 0.0, _height = 0.0;
  bool _mirror = false;

  MediaStream _srcObject;
  RTCVideoViewObjectFit _objectFit =
      RTCVideoViewObjectFit.RTCVideoViewObjectFitContain;
  StreamSubscription<dynamic> _eventSubscription;

  dynamic onStateChanged;

  void initialize() async {
    final response = await _channel
        .invokeMethod<Map<dynamic, dynamic>>('createVideoRenderer', {});
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
    if (onStateChanged != null) {
      onStateChanged();
    }
  }

  RTCVideoViewObjectFit get objectFit => _objectFit;

  set objectFit(RTCVideoViewObjectFit objectFit) {
    _objectFit = objectFit;
    if (onStateChanged != null) {
      onStateChanged();
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
    return EventChannel('FlutterWebRTC/Texture$textureId');
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
    if (onStateChanged != null) {
      onStateChanged();
    }
  }

  void errorListener(Object obj) {
    final PlatformException e = obj;
    throw e;
  }
}

class RTCVideoView extends StatefulWidget {
  final RTCVideoRenderer _renderer;
  RTCVideoView(this._renderer, {Key key}) : super(key: key);
  @override
  _RTCVideoViewState createState() => _RTCVideoViewState();
}

class _RTCVideoViewState extends State<RTCVideoView> {
  double _aspectRatio;
  RTCVideoViewObjectFit _objectFit;
  bool _mirror;

  @override
  void initState() {
    super.initState();
    _setCallbacks();
    _aspectRatio = widget._renderer.aspectRatio;
    _mirror = widget._renderer.mirror;
    _objectFit = widget._renderer.objectFit;
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
        _objectFit = widget._renderer.objectFit;
      });
    };
  }

  Widget _buildVideoView(BoxConstraints constraints) {
    return Container(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: FittedBox(
            fit:
                _objectFit == RTCVideoViewObjectFit.RTCVideoViewObjectFitContain
                    ? BoxFit.contain
                    : BoxFit.cover,
            child: Center(
                child: SizedBox(
                    width: constraints.maxHeight * _aspectRatio,
                    height: constraints.maxHeight,
                    child: Transform(
                        transform: Matrix4.identity()
                          ..rotateY(_mirror ? -pi : 0.0),
                        alignment: FractionalOffset.center,
                        child: Texture(
                            textureId: widget._renderer._textureId))))));
  }

  @override
  Widget build(BuildContext context) {
    var renderVideo = (widget._renderer._textureId != null &&
        widget._renderer._srcObject != null);

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Center(
          child: renderVideo ? _buildVideoView(constraints) : Container());
    });
  }
}
