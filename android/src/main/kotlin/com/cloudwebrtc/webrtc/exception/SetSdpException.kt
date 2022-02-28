package com.cloudwebrtc.webrtc.exception

/**
 * [Exception] thrown on `PeerConnection.createOffer` or
 * `PeerConnection.createAnswer` action.
 *
 * @param message  Description of the [CreateSdpException].
 */
class SetSdpException(message: String) : Exception(message)
