import 'package:flutter/foundation.dart';

import 'track.dart';

import '/src/platform/native/video_renderer.dart'
    if (dart.library.js_interop) 'web/video_renderer.dart';

export 'native/video_renderer.dart'
    if (dart.library.js_interop) 'web/video_renderer.dart';

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

  /// Fires once video dimensions are updated.
  Function? onResize;

  /// Fires once the user agent can play the media.
  Function? onCanPlay;

  /// Video`s width in pixels.
  int get videoWidth;

  /// Video`s height in pixels.
  int get videoHeight;

  /// Enables video mirroring.
  set mirror(bool mirror);

  /// Indicates whether media provider object is assigned.
  bool get renderVideo;

  /// ID of an underlying [Texture].
  ///
  /// [Texture]: https://api.flutter.dev/flutter/widgets/Texture-class.html
  int? get textureId;

  /// Initializes all the required underling machinery.
  Future<void> initialize();

  /// Element's assigned media provider object, if any.
  MediaStreamTrack? get srcObject;

  /// Assigns the provided media provider object.
  Future<void> setSrcObject(MediaStreamTrack? track);

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
