package com.cloudwebrtc.webrtc.exception

/**
 * [Exception] thrown on `getUserMedia` request.
 *
 * Indicates that all available devices are not suitable based on the provided used `Constraints`.
 */
class OverconstrainedException :
    Exception("getUserMedia failed because device matching provided Constraints is not found")
