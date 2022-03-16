import 'package:flutter/foundation.dart';

import 'track.dart';

import 'native/video_renderer.dart'
    if (dart.library.html) 'web/video_renderer.dart';

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
    double? width,
    double? height,
    int? rotation,
    bool renderVideo = true,
  }) {
    return RTCVideoValue(
      width: width ?? this.width,
      height: height ?? this.height,
      rotation: rotation ?? this.rotation,
      renderVideo: this.width != 0 && this.height != 0 && renderVideo,
    );
  }

  @override
  String toString() =>
      '$runtimeType(width: $width, height: $height, rotation: $rotation)';
}

abstract class VideoRenderer extends ValueNotifier<RTCVideoValue> {
  VideoRenderer() : super(RTCVideoValue.empty);

  Function? onResize;

  int get videoWidth;

  int get videoHeight;

  set mirror(bool mirror);

  bool get renderVideo;

  int? get textureId;

  Future<void> initialize();

  MediaStreamTrack? get srcObject;

  set srcObject(MediaStreamTrack? track);

  @override
  @mustCallSuper
  Future<void> dispose() async {
    super.dispose();
    return Future.value();
  }
}

enum VideoViewObjectFit {
  contain,
  cover,
}

VideoRenderer createVideoRenderer() {
  return createPlatformSpecificVideoRenderer();
}
