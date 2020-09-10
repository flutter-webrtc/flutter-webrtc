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
  final bool renderVideo;

  const RTCVideoValue({
    this.width = 0.0,
    this.height = 0.0,
    this.rotation = 0,
    this.renderVideo = false,
  });

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
  MethodChannel _channel = WebRTC.methodChannel();
  int _textureId;
  MediaStream _srcObject;
  StreamSubscription<dynamic> _eventSubscription;
  RTCVideoRenderer() : super(RTCVideoValue.empty);

  void initialize() async {
    final response = await _channel
        .invokeMethod<Map<dynamic, dynamic>>('createVideoRenderer', {});
    _textureId = response['textureId'];
    _eventSubscription = _eventChannelFor(_textureId)
        .receiveBroadcastStream()
        .listen(eventListener, onError: errorListener);
  }

  int get textureId => _textureId;

  MediaStream get srcObject => _srcObject;

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
    value = value.copyWith(renderVideo: renderVideo);
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
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
        value =
            value.copyWith(rotation: map['rotation'], renderVideo: renderVideo);
        break;
      case 'didTextureChangeVideoSize':
        value = value.copyWith(
            width: 0.0 + map['width'],
            height: 0.0 + map['height'],
            renderVideo: renderVideo);
        break;
      case 'didFirstFrameRendered':
        break;
    }
    notifyListeners();
  }

  void errorListener(Object obj) {
    final PlatformException e = obj;
    throw e;
  }

  bool get renderVideo => srcObject != null;
}

class RTCVideoView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Center(
          child: _buildVideoView(constraints),
        );
      },
    );
  }

  Widget _buildVideoView(BoxConstraints constraints) {
    return Container(
      width: constraints.maxWidth,
      height: constraints.maxHeight,
      child: FittedBox(
        fit: objectFit == RTCVideoViewObjectFit.RTCVideoViewObjectFitContain
            ? BoxFit.contain
            : BoxFit.cover,
        child: Center(
          child: ValueListenableBuilder<RTCVideoValue>(
            valueListenable: _renderer,
            builder: (BuildContext context, RTCVideoValue value, Widget child) {
              return SizedBox(
                width: constraints.maxHeight * value.aspectRatio,
                height: constraints.maxHeight,
                child: value.renderVideo ? child : Container(),
              );
            },
            child: Transform(
              transform: Matrix4.identity()..rotateY(mirror ? -pi : 0.0),
              alignment: FractionalOffset.center,
              child: _renderer.textureId != null
                  ? Texture(textureId: _renderer.textureId)
                  : Container(),
            ),
          ),
        ),
      ),
    );
  }
}
