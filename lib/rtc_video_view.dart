import 'package:webrtc/media_stream.dart';
import 'package:webrtc/webrtc.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

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
  bool _mirror = false;
  bool _muted = false;
  MediaStream _srcObject;
  RTCVideoViewObjectFit _objectFit =
      RTCVideoViewObjectFit.RTCVideoViewObjectFitContain;
  StreamSubscription<dynamic> _eventSubscription;
  VideoSizeChangeCallback onVideoSizeChange;
  VideoRotationChangeCallback onVideoRotationChange;

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

  set muted(bool muted) {
    _muted = muted;
  }

  set mirror(bool mirror) {
    _mirror = mirror;
  }

  set objectFit(RTCVideoViewObjectFit objectFit) {
    _objectFit = objectFit;
  }

  set srcObject(MediaStream stream) {
    _channel.invokeMethod('videoRendererSetSrcObject', <String, dynamic>{
      'textureId': _textureId,
      'streamId': stream != null ? stream.id : ''
    });
    _srcObject = stream;
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
        if (this.onVideoRotationChange != null)
          this.onVideoRotationChange(_textureId, _rotation);
        break;
      case 'didTextureChangeVideoSize':
        _width = map['width'];
        _height = map['height'];
        if (this.onVideoSizeChange != null)
          this.onVideoSizeChange(_textureId, _width, _height);
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
  double textureWidth = 0.0;
  double textureHeight = 0.0;
  _RTCVideoViewState(this.renderer){
    this.textureHeight = 0.0;
    this.textureWidth = 0.0;
  }
  @override
  void initState() {
    super.initState();
    renderer.onVideoRotationChange = (int textureId, int rotation) {
      setState(() {
        _updateContainerSize();
      });
    };
    renderer.onVideoSizeChange = (int textureId, double width, double height) {
      setState(() {
        _updateContainerSize();
      });
    };
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  void _updateContainerSize() {
    if (context.findRenderObject() != null) {
      final BoxConstraints constraints = context.findRenderObject().constraints;
      if (constraints is BoxConstraints) {
        double scale = 1.0;
        if (renderer.rotation == 90 || renderer.rotation == 270) {
          textureWidth = min(renderer.width, renderer.height);
          textureHeight = max(renderer.width, renderer.height);
          scale = min(constraints.minWidth / textureWidth,
              constraints.minHeight / textureHeight);
        } else {
          textureWidth = max(renderer.width, renderer.height);
          textureHeight = min(renderer.width, renderer.height);
          scale = max(constraints.minWidth / textureWidth,
              constraints.minHeight / textureHeight);
        }
        textureWidth *= scale;
        textureHeight *= scale;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
        child: (this.renderer._textureId == null ||
                this.renderer._srcObject == null)
            ? new Container()
            : new Container(
                width: this.textureWidth,
                height: this.textureHeight,
                child: new Texture(textureId: this.renderer._textureId),
              ));
  }
}
