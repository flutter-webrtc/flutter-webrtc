package com.cloudwebrtc.webrtc.proxy

import com.cloudwebrtc.webrtc.model.RtpTransceiverDirection
import org.webrtc.RtpTransceiver

/** Wrapper around an [RtpTransceiver]. */
class RtpTransceiverProxy(override var obj: RtpTransceiver) : Proxy<RtpTransceiver> {
  /** [RtpSenderProxy] of this [RtpTransceiverProxy]. */
  private lateinit var sender: RtpSenderProxy

  /** [RtpReceiverProxy] of this [RtpTransceiverProxy]. */
  private lateinit var receiver: RtpReceiverProxy

  init {
    syncWithObject()
  }

  override fun syncWithObject() {
    syncSender()
    syncReceiver()
  }

  /** @return [RtpSenderProxy] of this [RtpTransceiverProxy]. */
  fun getSender(): RtpSenderProxy {
    return sender
  }

  /** @return [RtpReceiverProxy] of this [RtpTransceiverProxy]. */
  fun getReceiver(): RtpReceiverProxy {
    return receiver
  }

  /** Sets [RtpTransceiverDirection] of the underlying [RtpTransceiver]. */
  fun setDirection(direction: RtpTransceiverDirection) {
    obj.direction = direction.intoWebRtc()
  }

  /** @return mID of the underlying [RtpTransceiver]. */
  fun getMid(): String? {
    return obj.mid
  }

  /** @return Preferred [RtpTransceiverDirection] of the underlying [RtpTransceiver]. */
  fun getDirection(): RtpTransceiverDirection {
    return RtpTransceiverDirection.fromWebRtc(obj)
  }

  /** Stops the underlying [RtpTransceiver]. */
  fun stop() {
    receiver.notifyRemoved()
    obj.stop()
  }

  /**
   * Synchronizes the [RtpSenderProxy] of this [RtpTransceiverProxy] with the underlying
   * [RtpTransceiver].
   */
  private fun syncSender() {
    val newSender = obj.sender
    if (this::sender.isInitialized) {
      sender.replace(newSender)
    } else {
      sender = RtpSenderProxy(newSender)
    }
  }

  /**
   * Synchronizes the [RtpReceiverProxy] of this [RtpTransceiverProxy] with the underlying
   * [RtpTransceiver].
   */
  private fun syncReceiver() {
    val newReceiver = obj.receiver
    if (this::receiver.isInitialized) {
      receiver.replace(newReceiver)
    } else {
      receiver = RtpReceiverProxy(newReceiver)
    }
  }
}
