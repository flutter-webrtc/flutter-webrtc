package com.instrumentisto.medea_flutter_webrtc.proxy

import org.webrtc.RtpReceiver

/**
 * Wrapper around an [RtpReceiver].
 *
 * @param receiver Underlying [RtpReceiver].
 */
class RtpReceiverProxy(receiver: RtpReceiver) : Proxy<RtpReceiver>(receiver) {
  /** [MediaStreamTrackProxy] of this [RtpReceiverProxy]. */
  val track: MediaStreamTrackProxy = MediaStreamTrackProxy(obj.track()!!)

  /** Unique ID of the underlying [RtpReceiver]. */
  val id: String = obj.id()

  init {
    track.replace(obj.track()!!)
    addOnSyncListener { track.replace(obj.track()!!) }
  }

  /** Calls [notifyRemoved] and sets the [track] disposed. */
  fun setDisposed() {
    notifyRemoved()
    track.setDisposed()
  }

  /**
   * Notifies [RtpReceiverProxy] about its [MediaStreamTrackProxy] being removed from the receiver.
   */
  fun notifyRemoved() {
    track.stop()
    track.observableEventBroadcaster().onEnded()
  }
}
