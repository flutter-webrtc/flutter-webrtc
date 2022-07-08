package com.cloudwebrtc.webrtc.proxy

import org.webrtc.RtpReceiver

/**
 * Wrapper around an [RtpReceiver].
 *
 * @param receiver Underlying [RtpReceiver].
 */
class RtpReceiverProxy(receiver: RtpReceiver) : Proxy<RtpReceiver>(receiver) {
  /** [MediaStreamTrackProxy] of this [RtpReceiverProxy]. */
  private var track: MediaStreamTrackProxy = MediaStreamTrackProxy(obj.track()!!)

  init {
    track.replace(obj.track()!!)
    addOnSyncListener { track.replace(obj.track()!!) }
  }

  /** @return Unique ID of the underlying [RtpReceiver]. */
  fun id(): String {
    return obj.id()
  }

  /** @return [MediaStreamTrackProxy] of this [RtpReceiverProxy]. */
  fun getTrack(): MediaStreamTrackProxy {
    return track
  }

  /**
   * Notifies [RtpReceiverProxy] about its [MediaStreamTrackProxy] being removed from the receiver.
   */
  fun notifyRemoved() {
    track.stop()
    track.observableEventBroadcaster().onEnded()
  }
}
