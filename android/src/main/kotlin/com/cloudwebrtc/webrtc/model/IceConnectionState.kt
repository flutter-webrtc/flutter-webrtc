package com.cloudwebrtc.webrtc.model

import org.webrtc.PeerConnection.IceConnectionState as WIceConnectionState

/**
 * Representation of an [org.webrtc.PeerConnection.IceConnectionState].
 *
 * @property value  [Int] representation of this enum, expected on the Flutter
 *                  side.
 */
enum class IceConnectionState(val value: Int) {
    /**
     * ICE agent is gathering addresses or is waiting to be given remote
     * candidates through calls to `PeerConnection.addIceCandidate()` (or both).
     */
    NEW(0),

    /**
     * ICE agent has been given one or more remote candidates and is checking
     * pairs of local and remote candidates against one another to try to find a
     * compatible match, but hasn't yet found a pair which will allow the peer
     * connection to be made. It's possible that gathering of candidates is also
     * still underway.
     */
    CHECKING(1),

    /**
     * Usable pairing of local and remote candidates has been found for all
     * components of the connection, and the connection has been established.
     * It's possible that gathering is still underway, and it's also possible
     * that the ICE agent is still checking candidates against one another
     * looking for a better connection to use.
     */
    CONNECTED(2),

    /**
     * ICE agent has finished gathering candidates, has checked all pairs
     * against one another, and has found a connection for all components.
     */
    COMPLETED(3),

    /**
     * ICE candidate has checked all candidates pairs against one another and
     * has failed to find compatible matches for all components of the
     * connection. It's, however, possible that the ICE agent did find
     * compatible connections for some components.
     */
    FAILED(4),

    /**
     * Checks to ensure that components are still connected failed for at least
     * one component of the `PeerConnection`. This is a less stringent test
     * than `FAILED` and may trigger intermittently and resolve just as
     * spontaneously on less reliable networks, or during temporary
     * disconnections. When the problem resolves, the connection may return to
     * the `CONNECTED` state.
     */
    DISCONNECTED(5),

    /**
     * The ICE agent for this `RTCPeerConnection` has shut down and is no longer
     * handling requests.
     */
    CLOSED(6);

    companion object {
        /**
         * Converts the provided [org.webrtc.PeerConnection.IceConnectionState]
         * into an [IceConnectionState].
         *
         * @return  [IceConnectionState] created based on the provided
         *          [org.webrtc.PeerConnection.IceConnectionState].
         */
        fun fromWebRtc(from: WIceConnectionState): IceConnectionState {
            return when (from) {
                WIceConnectionState.NEW -> NEW
                WIceConnectionState.CHECKING -> CHECKING
                WIceConnectionState.CONNECTED -> CONNECTED
                WIceConnectionState.COMPLETED -> COMPLETED
                WIceConnectionState.FAILED -> FAILED
                WIceConnectionState.DISCONNECTED -> DISCONNECTED
                WIceConnectionState.CLOSED -> CLOSED
            }
        }
    }
}
