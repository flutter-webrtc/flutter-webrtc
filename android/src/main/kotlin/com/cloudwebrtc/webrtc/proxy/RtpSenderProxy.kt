package com.cloudwebrtc.webrtc.proxy

import com.cloudwebrtc.webrtc.exception.ReplaceSenderTrackException
import org.webrtc.RtpReceiver
import org.webrtc.RtpSender

/**
 * Wrapper around an [RtpSender].
 *
 * @param sender  Actual underlying [RtpSender].
 */
class RtpSenderProxy(sender: RtpSender) : Proxy<RtpSender> {
    /**
     * Actual underlying [RtpReceiver].
     */
    override var obj: RtpSender = sender

    /**
     * [MediaStreamTrackProxy] of this [RtpReceiverProxy].
     */
    private var track: MediaStreamTrackProxy? = null

    init {
        syncWithObject()
    }

    override fun syncWithObject() {
        syncMediaStreamTrack()
    }

    /**
     * Replaces [MediaStreamTrackProxy] of the underlying [RtpSender] with the
     * provided one.
     *
     * @param t  [MediaStreamTrackProxy] which will be set to the underlying
     *           [RtpSender].
     */
    fun replaceTrack(t: MediaStreamTrackProxy?) {
        track = t
        val isSuccessful = obj.setTrack(t?.obj, false)
        if (!isSuccessful) {
            throw ReplaceSenderTrackException()
        }
    }

    /**
     * Synchronizes the [MediaStreamTrackProxy] of this [RtpSenderProxy] with
     * the underlying [RtpSender].
     */
    private fun syncMediaStreamTrack() {
        val newSenderTrack = obj.track()
        if (newSenderTrack == null) {
            track = null
        } else {
            if (track == null) {
                track = MediaStreamTrackProxy(newSenderTrack)
            } else {
                track!!.replace(newSenderTrack)
            }
        }
    }
}
