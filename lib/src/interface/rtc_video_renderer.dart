import 'package:flutter/foundation.dart';
import 'media_stream.dart';

@immutable
class RTCVideoValue {
  const RTCVideoValue({
    this.width = 0.0,
    this.height = 0.0,
    this.rotation = 0,
    this.renderVideo = false,
  });
  static const RTCVideoValue empty = RTCVideoValue();
  final double width;
  final double height;
  final int rotation;
  final bool renderVideo;
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

abstract class VideoRenderer extends ValueNotifier<RTCVideoValue> {
  VideoRenderer() : super(RTCVideoValue.empty);

  Function onResize;

  int get videoWidth;

  int get videoHeight;

  bool get muted;
  set muted(bool mute);

  bool get renderVideo;
  int get textureId;

  Future<void> initialize();

  MediaStream get srcObject;
  set srcObject(MediaStream stream);

  @override
  @mustCallSuper
  Future<void> dispose() async {
    super.dispose();
    return Future.value();
  }
}
