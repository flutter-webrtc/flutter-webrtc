package com.cloudwebrtc.webrtc.exception

/**
 * [Exception] thrown on `RtpSenderProxy.replaceTrack` request.
 */
class ReplaceSenderTrackException :
        Exception("Failed to replace MediaStreamTrack of the RtpSender")
