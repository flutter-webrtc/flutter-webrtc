package com.instrumentisto.medea_flutter_webrtc.proxy

import com.instrumentisto.medea_flutter_webrtc.model.CodecCapability
import com.instrumentisto.medea_flutter_webrtc.model.RtpTransceiverDirection
import org.webrtc.RtpTransceiver

/** Wrapper around an [RtpTransceiver]. */
class RtpTransceiverProxy(obj: RtpTransceiver) : Proxy<RtpTransceiver>(obj) {
  /** [RtpSenderProxy] of this [RtpTransceiverProxy]. */
  lateinit var sender: RtpSenderProxy
    private set

  /** [RtpReceiverProxy] of this [RtpTransceiverProxy]. */
  lateinit var receiver: RtpReceiverProxy
    private set

  /** Disposed state of the [obj]. */
  private var disposed: Boolean = false

  /** mID of the underlying [RtpTransceiver]. */
  var mid: String? = null
    get() {
      if (!disposed) {
        field = obj.mid
      }
      return field
    }
    private set

  /** [RtpTransceiver]'s preferred directionality. */
  var direction: RtpTransceiverDirection = RtpTransceiverDirection.fromWebRtc(obj)
    get() {
      field =
          if (disposed) {
            RtpTransceiverDirection.STOPPED
          } else {
            RtpTransceiverDirection.fromWebRtc(obj)
          }
      return field
    }
    private set

  init {
    syncSender()
    syncReceiver()
    addOnSyncListener {
      syncSender()
      syncReceiver()
    }
  }

  /** Sets [disposed] to `true` for the [obj], [receiver] and [sender]. */
  fun setDisposed() {
    disposed = true
    receiver.setDisposed()
    sender.setDisposed()
  }

  /** Sets [RtpTransceiverDirection] of the underlying [RtpTransceiver]. */
  fun setDirection(direction: RtpTransceiverDirection) {
    if (disposed) {
      return
    }

    obj.direction = direction.intoWebRtc()
  }

  /** Changes the preferred [RtpTransceiver] codecs to the providded [List<CodecCapability>]. */
  fun setCodecPreferences(codecs: List<CodecCapability>) {
    var webrtcCodecs =
        codecs.map {
          var capability = org.webrtc.RtpCapabilities.CodecCapability()
          capability.clockRate = it.clockRate
          capability.name = it.name
          capability.kind = it.kind.intoWebRtc()
          capability.clockRate = it.clockRate
          capability.numChannels = it.numChannels
          capability.mimeType = it.mimeType
          capability.parameters = it.parameters
          capability.preferredPayloadType = it.preferredPayloadType

          capability
        }

    obj.setCodecPreferences(webrtcCodecs)
  }

  /** Sets receive of the underlying [RtpTransceiver]. */
  fun setRecv(recv: Boolean) {
    if (disposed) {
      return
    }

    val currentDirection = RtpTransceiverDirection.fromWebRtc(obj)
    val newDirection =
        if (recv) {
          when (currentDirection) {
            RtpTransceiverDirection.INACTIVE -> RtpTransceiverDirection.RECV_ONLY
            RtpTransceiverDirection.RECV_ONLY -> RtpTransceiverDirection.RECV_ONLY
            RtpTransceiverDirection.SEND_RECV -> RtpTransceiverDirection.SEND_RECV
            RtpTransceiverDirection.SEND_ONLY -> RtpTransceiverDirection.SEND_RECV
            RtpTransceiverDirection.STOPPED -> RtpTransceiverDirection.STOPPED
          }
        } else {
          when (currentDirection) {
            RtpTransceiverDirection.INACTIVE -> RtpTransceiverDirection.INACTIVE
            RtpTransceiverDirection.RECV_ONLY -> RtpTransceiverDirection.INACTIVE
            RtpTransceiverDirection.SEND_RECV -> RtpTransceiverDirection.SEND_ONLY
            RtpTransceiverDirection.SEND_ONLY -> RtpTransceiverDirection.SEND_ONLY
            RtpTransceiverDirection.STOPPED -> RtpTransceiverDirection.STOPPED
          }
        }
    if (newDirection != RtpTransceiverDirection.STOPPED) {
      setDirection(newDirection)
    }
  }

  /** Sets send of the underlying [RtpTransceiver]. */
  fun setSend(send: Boolean) {
    if (disposed) {
      return
    }

    val currentDirection = RtpTransceiverDirection.fromWebRtc(obj)
    val newDirection =
        if (send) {
          when (currentDirection) {
            RtpTransceiverDirection.INACTIVE -> RtpTransceiverDirection.SEND_ONLY
            RtpTransceiverDirection.SEND_ONLY -> RtpTransceiverDirection.SEND_ONLY
            RtpTransceiverDirection.SEND_RECV -> RtpTransceiverDirection.SEND_RECV
            RtpTransceiverDirection.RECV_ONLY -> RtpTransceiverDirection.SEND_RECV
            RtpTransceiverDirection.STOPPED -> RtpTransceiverDirection.STOPPED
          }
        } else {
          when (currentDirection) {
            RtpTransceiverDirection.INACTIVE -> RtpTransceiverDirection.INACTIVE
            RtpTransceiverDirection.SEND_ONLY -> RtpTransceiverDirection.INACTIVE
            RtpTransceiverDirection.SEND_RECV -> RtpTransceiverDirection.RECV_ONLY
            RtpTransceiverDirection.RECV_ONLY -> RtpTransceiverDirection.RECV_ONLY
            RtpTransceiverDirection.STOPPED -> RtpTransceiverDirection.STOPPED
          }
        }
    if (newDirection != RtpTransceiverDirection.STOPPED) {
      setDirection(newDirection)
    }
  }

  /** Stops the underlying [RtpTransceiver]. */
  fun stop() {
    receiver.notifyRemoved()
    if (!disposed) {
      obj.stop()
    }
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
