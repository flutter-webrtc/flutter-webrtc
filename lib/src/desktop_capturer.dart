import 'dart:typed_data';

enum SourceType {
  Screen,
  Window,
}

final desktopSourceTypeToString = <SourceType, String>{
  SourceType.Screen: 'screen',
  SourceType.Window: 'window',
};

final tringToDesktopSourceType = <String, SourceType>{
  'screen': SourceType.Screen,
  'window': SourceType.Window,
};

class ThumbnailSize {
  ThumbnailSize(this.width, this.height);
  factory ThumbnailSize.fromMap(Map<dynamic, dynamic> map) {
    return ThumbnailSize(map['width'], map['height']);
  }
  int width;
  int height;
}

abstract class DesktopCapturerSource {
  /// The identifier of a window or screen that can be used as a
  /// chromeMediaSourceId constraint when calling
  String get id;

  /// A screen source will be named either Entire Screen or Screen <index>,
  /// while the name of a window source will match the window title.
  String get name;

  ///A thumbnail image of the source. ARGB
  Uint8List? get thumbnail;

  /// specified in the options passed to desktopCapturer.getSources.
  /// The actual size depends on the scale of the screen or window.
  ThumbnailSize get thumbnailSize;

  /// The type of the source.
  SourceType get type;
}

abstract class DesktopCapturer {
  Future<List<DesktopCapturerSource>> getSources(
      {required List<SourceType> types, ThumbnailSize? thumbnailSize});
}
