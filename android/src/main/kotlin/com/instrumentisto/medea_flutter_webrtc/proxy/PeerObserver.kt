package com.instrumentisto.medea_flutter_webrtc.proxy

import android.os.Handler
import android.os.Looper
import com.instrumentisto.medea_flutter_webrtc.model.IceCandidate
import com.instrumentisto.medea_flutter_webrtc.model.IceConnectionState
import com.instrumentisto.medea_flutter_webrtc.model.IceGatheringState
import com.instrumentisto.medea_flutter_webrtc.model.PeerConnectionState
import com.instrumentisto.medea_flutter_webrtc.model.SignalingState
import org.webrtc.*
import org.webrtc.IceCandidate as WIceCandidate

/**
 * Implementor of a [PeerConnection.Observer] notifying a [PeerConnectionProxy] about
 * [PeerConnection] events.
 */
class PeerObserver : PeerConnection.Observer {
  /** [PeerConnectionProxy] being notified about all events. */
  private var peer: PeerConnectionProxy? = null

  override fun onSignalingChange(signallingState: PeerConnection.SignalingState?) {
    if (signallingState != null) {
      Handler(Looper.getMainLooper()).post {
        peer?.observableEventBroadcaster()
            ?.onSignalingStateChange(SignalingState.fromWebRtc(signallingState))
      }
    }
  }

  override fun onIceConnectionChange(iceConnectionState: PeerConnection.IceConnectionState?) {
    if (iceConnectionState != null) {
      Handler(Looper.getMainLooper()).post {
        peer?.observableEventBroadcaster()
            ?.onIceConnectionStateChange(IceConnectionState.fromWebRtc(iceConnectionState))
      }
    }
  }

  override fun onConnectionChange(pcState: PeerConnection.PeerConnectionState?) {
    if (pcState != null) {
      Handler(Looper.getMainLooper()).post {
        peer?.observableEventBroadcaster()
            ?.onConnectionStateChange(PeerConnectionState.fromWebRtc(pcState))
      }
    }
  }

  override fun onIceGatheringChange(iceGatheringState: PeerConnection.IceGatheringState?) {
    if (iceGatheringState != null) {
      Handler(Looper.getMainLooper()).post {
        peer?.observableEventBroadcaster()
            ?.onIceGatheringStateChange(IceGatheringState.fromWebRtc(iceGatheringState))
      }
    }
  }

  override fun onIceCandidate(candidate: WIceCandidate?) {
    if (candidate != null) {
      Handler(Looper.getMainLooper()).post {
        peer?.observableEventBroadcaster()?.onIceCandidate(IceCandidate.fromWebRtc(candidate))
      }
    }
  }

  override fun onTrack(transceiver: RtpTransceiver?) {
    if (transceiver != null && peer != null) {
      if (!peer!!.disposed) {
        val receiverId = transceiver.receiver.id()
        Handler(Looper.getMainLooper()).post {
          val transceivers = peer?.getTransceivers()!!
          for (trans in transceivers) {
            if (trans.receiver.id == receiverId) {
              peer?.observableEventBroadcaster()?.onTrack(trans.receiver.track, trans)
              return@post
            }
          }
        }
      }
    }
  }

  override fun onRenegotiationNeeded() {
    Handler(Looper.getMainLooper()).post {
      peer?.observableEventBroadcaster()?.onNegotiationNeeded()
    }
  }

  override fun onRemoveTrack(receiver: RtpReceiver?) {
    if (receiver != null) {
      Handler(Looper.getMainLooper()).post { peer?.receiverEnded(receiver) }
    }
  }

  override fun onIceConnectionReceivingChange(receiving: Boolean) {}
  override fun onIceCandidatesRemoved(candidates: Array<out WIceCandidate>?) {}
  override fun onAddStream(stream: MediaStream?) {}
  override fun onRemoveStream(stream: MediaStream?) {}
  override fun onDataChannel(chan: DataChannel?) {}

  /** Sets the [PeerConnectionProxy] to be notified about all events. */
  fun setPeerConnection(newPeer: PeerConnectionProxy) {
    peer = newPeer
  }
}
