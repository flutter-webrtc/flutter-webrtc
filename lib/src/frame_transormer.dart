import 'dart:typed_data';

enum MediaType { AUDIO, VIDEO, DATA }

enum FrameType { KEY, DELTA, UNKNOWN }

abstract class EncodedFrame {
  MediaType get mediaType;

  FrameType get frameType;

  int get timestamp;

  int get ssrc;

  String get mimeType;

  Uint8List get data;

  set data(Uint8List data);
}

abstract class FrameTransformer {
  /// Transform the frame.
  Future<EncodedFrame> transform(EncodedFrame frame);
}
