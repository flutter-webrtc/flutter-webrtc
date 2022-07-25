package com.instrumentisto.medea_flutter_webrtc.model

import org.webrtc.IceCandidate as WIceCandidate

/**
 * Representation of an [org.webrtc.IceCandidate].
 *
 * @property sdpMid `mid` of this [IceCandidate].
 * @property sdpMLineIndex `sdpMLineIndex` of this [IceCandidate].
 * @property sdp SDP of this [IceCandidate].
 */
data class IceCandidate(val sdpMid: String, val sdpMLineIndex: Int, val sdp: String) {
  companion object {
    /**
     * Creates a new [IceCandidate] object based on the method call received from the Flutter side.
     *
     * @return [IceCandidate] created from the provided [Map].
     */
    fun fromMap(map: Map<String, Any>): IceCandidate {
      return IceCandidate(
          map["sdpMid"] as String, map["sdpMLineIndex"] as Int, map["candidate"] as String)
    }

    /**
     * Converts the provided [org.webrtc.IceCandidate] into an [IceCandidate].
     *
     * @return [IceCandidate] created based on the provided [org.webrtc.IceCandidate].
     */
    fun fromWebRtc(from: WIceCandidate): IceCandidate =
        IceCandidate(from.sdpMid, from.sdpMLineIndex, from.sdp)
  }

  /**
   * Converts this [IceCandidate] to an [org.webrtc.IceCandidate].
   *
   * @return [org.webrtc.IceCandidate] created based on this [IceCandidate].
   */
  fun intoWebRtc(): WIceCandidate {
    return WIceCandidate(sdpMid, sdpMLineIndex, sdp)
  }

  /** Converts this [IceCandidate] into a [Map] which can be returned to the Flutter side. */
  fun asFlutterResult(): Map<String, Any> =
      mapOf("sdpMid" to sdpMid, "sdpMLineIndex" to sdpMLineIndex, "candidate" to sdp)
}
