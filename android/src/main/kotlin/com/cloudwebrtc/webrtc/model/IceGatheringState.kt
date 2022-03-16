package com.cloudwebrtc.webrtc.model

import org.webrtc.PeerConnection.IceGatheringState as WIceGatheringState

/**
 * Representation of an [org.webrtc.PeerConnection.IceGatheringState].
 *
 * @property value [Int] representation of this enum which will be expected on the Flutter side.
 */
enum class IceGatheringState(val value: Int) {
  /** Peer connection was just created and hasn't done any networking yet. */
  NEW(0),

  /** ICE agent is in the process of gathering candidates for the connection. */
  GATHERING(1),

  /**
   * ICE agent has finished gathering candidates. If something happens that requires collecting new
   * candidates, such as a new interface being added or the addition of a new ICE server, the state
   * will revert to `GATHERING` to gather those candidates.
   */
  COMPLETE(2);

  companion object {
    /**
     * Converts the provided [org.webrtc.PeerConnection.IceGatheringState] into an
     * [IceGatheringState].
     *
     * @return [IceGatheringState] created based on the provided
     * [org.webrtc.PeerConnection.IceGatheringState].
     */
    fun fromWebRtc(from: WIceGatheringState): IceGatheringState {
      return when (from) {
        WIceGatheringState.NEW -> NEW
        WIceGatheringState.GATHERING -> GATHERING
        WIceGatheringState.COMPLETE -> COMPLETE
      }
    }
  }
}
