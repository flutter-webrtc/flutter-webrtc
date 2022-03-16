package com.cloudwebrtc.webrtc.model

import org.webrtc.PeerConnection.SignalingState as WSignalingState

/**
 * Representation of an [org.webrtc.PeerConnection.SignalingState].
 *
 * @property value [Int] representation of this enum which will be expected on the Flutter side.
 */
enum class SignalingState(val value: Int) {
  /** Indicates that there is no ongoing exchange of offer and answer underway. */
  STABLE(0),

  /** Indicates that the local peer has called `RTCPeerConnection.setLocalDescription()`. */
  HAVE_LOCAL_OFFER(1),

  /**
   * Indicates that the offer sent by the remote peer has been applied and an answer has been
   * created.
   */
  HAVE_LOCAL_PRANSWER(2),

  /**
   * Indicates that the remote peer has created an offer and used the signaling server to deliver it
   * to the local peer, which has set the offer as the remote description by calling
   * `PeerConnection.setRemoteDescription()`.
   */
  HAVE_REMOTE_OFFER(3),

  /**
   * Indicates that the provisional answer has been received and successfully applied in response to
   * the offer previously sent and established.
   */
  HAVE_REMOTE_PRANSWER(4),

  /** Indicates that the peer was closed. */
  CLOSED(5);

  companion object {
    /**
     * Converts the provided [org.webrtc.PeerConnection.SignalingState] into a [SignalingState].
     *
     * @return [SignalingState] created based on the provided
     * [org.webrtc.PeerConnection.SignalingState].
     */
    fun fromWebRtc(from: WSignalingState): SignalingState {
      return when (from) {
        WSignalingState.STABLE -> STABLE
        WSignalingState.HAVE_LOCAL_OFFER -> HAVE_LOCAL_OFFER
        WSignalingState.HAVE_LOCAL_PRANSWER -> HAVE_LOCAL_PRANSWER
        WSignalingState.HAVE_REMOTE_OFFER -> HAVE_REMOTE_OFFER
        WSignalingState.HAVE_REMOTE_PRANSWER -> HAVE_REMOTE_PRANSWER
        WSignalingState.CLOSED -> CLOSED
      }
    }
  }
}
