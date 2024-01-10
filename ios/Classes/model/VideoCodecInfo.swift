/// Supported video codecs.
enum VideoCodec: Int {
  /// [AV1] AOMedia Video 1.
  ///
  /// [AV1]: https://en.wikipedia.org/wiki/AV1
  case AV1

  /// [H.264] Advanced Video Coding (AVC).
  ///
  /// [H.264]: https://en.wikipedia.org/wiki/Advanced_Video_Coding
  case H264

  /// [H.265] High Efficiency Video Coding (HEVC).
  ///
  /// [H.265]: https://en.wikipedia.org/wiki/High_Efficiency_Video_Coding
  case H265

  /// [VP8] codec.
  ///
  /// [VP8]: https://en.wikipedia.org/wiki/VP8
  case VP8

  /// [VP9] codec.
  ///
  /// [VP9]: https://en.wikipedia.org/wiki/VP9
  case VP9
}

/// `VideoCodec` info for encoding/decoding in a peer connection.
class VideoCodecInfo {
  /// Indicator whether hardware acceleration should be used.
  private var isHardwareAccelerated: Bool

  /// `VideoCodec` to be used for encoding/decoding.
  private var codec: VideoCodec

  /// Initializes a new `VideoCodecInfo` with the provided data.
  init(isHardwareAccelerated: Bool, codec: VideoCodec) {
    self.isHardwareAccelerated = isHardwareAccelerated
    self.codec = codec
  }

  /// Converts this controller into a Flutter method call response.
  func asFlutterResult() -> [String: Any] {
    [
      "isHardwareAccelerated": self.isHardwareAccelerated,
      "codec": self.codec.rawValue,
    ]
  }
}
