package com.cloudwebrtc.webrtc.model

import org.webrtc.RtpTransceiver.RtpTransceiverInit as WRtpTransceiverInit

/**
 * Representation of an [org.webrtc.RtpTransceiver.RtpTransceiverInit].
 *
 * @property direction Direction of the transceiver, created from this config.
 */
data class RtpTransceiverInit(val direction: RtpTransceiverDirection) {
  companion object {
    /**
     * Creates a new [RtpTransceiverInit] object based on the method call received from the Flutter
     * side.
     *
     * @return [RtpTransceiverInit] created from the provided [Map].
     */
    fun fromMap(map: Map<String, Any>): RtpTransceiverInit {
      return RtpTransceiverInit(RtpTransceiverDirection.fromInt(map["direction"] as Int))
    }
  }

  /**
   * Converts this [RtpTransceiverInit] into an [org.webrtc.RtpTransceiver.RtpTransceiverInit].
   *
   * @return [org.webrtc.RtpTransceiver.RtpTransceiverInit] created based on this
   * [RtpTransceiverInit].
   */
  fun intoWebRtc(): WRtpTransceiverInit {
    return WRtpTransceiverInit(direction.intoWebRtc())
  }
}
