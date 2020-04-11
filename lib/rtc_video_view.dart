import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'media_stream.dart';
import 'utils.dart';
import 'enums.dart';

@immutable
class RTCVideoValue {
  static const RTCVideoValue empty = RTCVideoValue();

  final double width;
  final double height;
  final int rotation;

  const RTCVideoValue({
    this.width = 0.0,
    this.height = 0.0,
    this.rotation = 0,
  });

  double get aspectRatio {
    if (width == 0.0 || height == 0.0) {
      return 1.0;
    } else {
      return (rotation == 90 || rotation == 270) ? height / width : width / height;
    }
  }

  RTCVideoValue copyWith({
    double width,
    double height,
    int rotation,
  }) {
    return RTCVideoValue(
      width: width ?? this.width,
      height: height ?? this.height,
      rotation: rotation ?? this.rotation,
    );
  }

  @override
  String toString() => '$runtimeType(width: $width, height: $height, rotation: $rotation)';
}

class RTCVideoRenderer extends ValueNotifier<RTCVideoValue> {
  MethodChannel _channel = WebRTC.methodChannel();
  int _textureId;
  MediaStream _srcObject;
  StreamSubscription<dynamic> _eventSubscription;

  RTCVideoRenderer() : super(RTCVideoValue.empty);

  initialize() async {
    final Map<dynamic, dynamic> response =
        await _channel.invokeMethod('createVideoRenderer', {});
    _textureId = response['textureId'];
    _eventSubscription = _eventChannelFor(_textureId)
        .receiveBroadcastStream()
        .listen(eventListener, onError: errorListener);
  }

  int get textureId => _textureId;

  set srcObject(MediaStream stream) {
    if (stream == null) {
      value = RTCVideoValue.empty;
    }
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
        value = value.copyWith(rotation: map['rotation']);
        break;
      case 'didTextureChangeVideoSize':
        value = value.copyWith(width: 0.0 + map['width'], height: 0.0 + map['height']);
        break;
      case 'didFirstFrameRendered':
        notifyListeners();
        break;
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
  final bool mirror;

  RTCVideoView(
    this._renderer, {
    Key key,
    this.objectFit = RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
    this.mirror = false,
  })  : assert(objectFit != null),
        assert(mirror != null),
        super(key: key);

  @override
  _RTCVideoViewState createState() => _RTCVideoViewState();
}

class _RTCVideoViewState extends State<RTCVideoView> {
  Widget _buildVideoView(BoxConstraints constraints) {
    return Container(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: FittedBox(
            fit: widget.objectFit == RTCVideoViewObjectFit.RTCVideoViewObjectFitContain ? BoxFit.contain : BoxFit.cover,
            child: Center(
              child: ValueListenableBuilder<RTCVideoValue>(
                  valueListenable: widget._renderer,
                  builder: (BuildContext context, RTCVideoValue value, Widget child) {
                    return SizedBox(
                      width: constraints.maxHeight * value.aspectRatio,
                      height: constraints.maxHeight,
                      child: child,
                    );
                  },
                  child: Transform(
                      transform: Matrix4.identity()
                        ..rotateY(widget.mirror ? -pi : 0.0),
                      alignment: FractionalOffset.center,
                      child: Texture(textureId: widget._renderer._textureId))),
            )));
  }

  @override
  Widget build(BuildContext context) {
    bool renderVideo =
        (widget._renderer._textureId != null && widget._renderer._srcObject != null);

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Center(
          child: renderVideo ? _buildVideoView(constraints) : Container());
    });
  }
}
