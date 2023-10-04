package com.instrumentisto.medea_flutter_webrtc.model

import org.webrtc.RtpParameters.Encoding as WEncoding

/**
 * Representation of an [org.webrtc.RtpParameters.Encoding].
 *
 * @property rid 'rid' of this encoding parameters, created from this config.
 * @property active Indicates whether this parameters are active.
 * @property maxBitrate Maximum bitrate for this parameters.
 * @property maxFramerate Maximum framerate for this parameters.
 * @property scaleResolutionDownBy Resolution will be scaled down for this parameters.
 */
data class Encoding(
    var rid: String,
    var active: Boolean,
    var maxBitrate: Int?,
    var maxFramerate: Double?,
    var scaleResolutionDownBy: Double?,
) {
  companion object {
    /**
     * Creates a new [Encoding] object based on the method call received from the Flutter side.
     *
     * @return [Encoding] created from the provided [Map].
     */
    fun fromMap(map: Map<String, Any>): Encoding {
      return Encoding(
          map["rid"] as String,
          map["active"] as Boolean,
          map["maxBitrate"] as Int?,
          map["maxFramerate"] as Double?,
          map["scaleResolutionDownBy"] as Double?)
    }
  }

  /**
   * Converts this [Encoding] into an [org.webrtc.RtpParameters.Encoding].
   *
   * @return [org.webrtc.RtpParameters.Encoding] created based on this [Encoding].
   */
  fun intoWebRtc(): WEncoding {
    var encoding: WEncoding = WEncoding(rid, active, scaleResolutionDownBy)
    encoding.maxBitrateBps = maxBitrate
    encoding.maxFramerate = maxFramerate?.toInt()
    return encoding
  }
}
