package com.instrumentisto.medea_flutter_webrtc.exception

/**
 * [Exception] thrown on `PeerConnection.createOffer` or `PeerConnection.createAnswer` action.
 *
 * @param message Description of the [CreateSdpException].
 */
class CreateSdpException(message: String) : Exception(message)
