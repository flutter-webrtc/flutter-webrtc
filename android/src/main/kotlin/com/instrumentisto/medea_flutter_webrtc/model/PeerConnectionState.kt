package com.instrumentisto.medea_flutter_webrtc.model

import org.webrtc.PeerConnection.PeerConnectionState as WPeerConnectionState

/**
 * Representation of an [org.webrtc.PeerConnection.PeerConnectionState].
 *
 * @property value [Int] representation of this enum which will be expected on the Flutter side.
 */
enum class PeerConnectionState(val value: Int) {
  /**
   * Indicates that any of the ICE transports or DTLS transports are in the "new" state and none of
   * the transports are in the "connecting", "checking", "failed" or "disconnected" state, or all
   * transports are in the "closed" state, or there are no transports.
   */
  NEW(0),

  /**
   * Indicates that any of the ICE transports or DTLS transports are in the "connecting" or
   * "checking" state and none of them is in the "failed" state.
   */
  CONNECTING(1),

  /**
   * Indicates that all the ICE transports and DTLS transports are in the "connected", "completed"
   * or "closed" state, and at least one of them is in the "connected" or "completed" state.
   */
  CONNECTED(2),

  /**
   * Indicates that any of the ICE transports or DTLS transports are in the "disconnected" state,
   * and none of them are in the "failed", "connecting" or "checking" state.
   */
  DISCONNECTED(3),

  /** Indicates that any of the ICE transports or DTLS transports are in the "failed" state. */
  FAILED(4),

  /** Indicates that the peer connection is closed. */
  CLOSED(5);

  companion object {
    /**
     * Converts the provided [org.webrtc.PeerConnection.PeerConnectionState] into a
     * [PeerConnectionState].
     *
     * @return [PeerConnectionState] created based on the provided
     * [org.webrtc.PeerConnection.PeerConnectionState].
     */
    fun fromWebRtc(from: WPeerConnectionState): PeerConnectionState {
      return when (from) {
        WPeerConnectionState.NEW -> NEW
        WPeerConnectionState.CONNECTING -> CONNECTING
        WPeerConnectionState.CONNECTED -> CONNECTED
        WPeerConnectionState.DISCONNECTED -> DISCONNECTED
        WPeerConnectionState.FAILED -> FAILED
        WPeerConnectionState.CLOSED -> CLOSED
      }
    }
  }
}
