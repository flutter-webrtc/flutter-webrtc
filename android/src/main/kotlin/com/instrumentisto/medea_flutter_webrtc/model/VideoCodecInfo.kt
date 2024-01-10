package com.instrumentisto.medea_flutter_webrtc.model

/**
 * Supported video codecs.
 *
 * @property value [String] representation of this enum which will be expected on the Flutter side.
 */
enum class VideoCodec {
  AV1,
  H264,
  H265,
  VP8,
  VP9;

  companion object {
    fun valueOfOrNull(name: String): VideoCodec? {
      return values().firstOrNull { it.name == name }
    }
  }
}

/**
 * [VideoCodec] info for encoding/decoding in a peer connection.
 *
 * @property isHardwareAccelerated Indicator whether hardware acceleration should be used.
 * @property codec [VideoCodec] to be used for encoding/decoding..
 */
data class VideoCodecInfo(
    val codec: VideoCodec,
    val isHardwareAccelerated: Boolean,
) {
  /** Converts this [VideoCodecInfo] into a [Map] which can be returned to the Flutter side. */
  fun asFlutterResult(): Map<String, Any> =
      mapOf("isHardwareAccelerated" to isHardwareAccelerated, "codec" to codec.ordinal)
}
