package com.cloudwebrtc.webrtc.proxy

import android.os.Handler
import android.os.Looper
import com.cloudwebrtc.webrtc.model.IceCandidate
import com.cloudwebrtc.webrtc.model.IceConnectionState
import com.cloudwebrtc.webrtc.model.IceGatheringState
import com.cloudwebrtc.webrtc.model.SignalingState
import org.webrtc.*
import org.webrtc.IceCandidate as WIceCandidate

/**
 * Implementor of a [PeerConnection.Observer] notifying a [PeerConnectionProxy]
 * about [PeerConnection] events.
 */
class PeerObserver : PeerConnection.Observer {
    /**
     * [PeerConnectionProxy] being notified about all events.
     */
    private var peer: PeerConnectionProxy? = null

    override fun onSignalingChange(signallingState: PeerConnection.SignalingState?) {
        if (signallingState != null) {
            Handler(Looper.getMainLooper()).post {
                peer?.observableEventBroadcaster()
                    ?.onSignalingStateChange(
                        SignalingState.fromWebRtc(
                                signallingState
                        )
                    )
            }
        }
    }

    override fun onIceConnectionChange(iceConnectionState: PeerConnection.IceConnectionState?) {
        if (iceConnectionState != null) {
            Handler(Looper.getMainLooper()).post {
                peer?.observableEventBroadcaster()
                    ?.onIceConnectionStateChange(
                        IceConnectionState.fromWebRtc(
                                iceConnectionState
                        )
                    )
            }
        }
    }

    override fun onIceGatheringChange(iceGatheringState: PeerConnection.IceGatheringState?) {
        if (iceGatheringState != null) {
            Handler(Looper.getMainLooper()).post {
                peer?.observableEventBroadcaster()
                    ?.onIceGatheringStateChange(
                        IceGatheringState.fromWebRtc(
                                iceGatheringState
                        )
                    )
            }
        }
    }

    override fun onIceCandidate(candidate: WIceCandidate?) {
        if (candidate != null) {
            Handler(Looper.getMainLooper()).post {
                peer?.observableEventBroadcaster()
                    ?.onIceCandidate(IceCandidate.fromWebRtc(candidate))
            }
        }
    }

    override fun onTrack(transceiver: RtpTransceiver?) {
        if (transceiver != null) {
            Handler(Looper.getMainLooper()).post {
                val receiver = transceiver.receiver
                val track = receiver.track()
                if (track != null) {
                    val transceivers = peer?.getTransceivers()!!
                    for (trans in transceivers) {
                        if (trans.getReceiver().id() == receiver.id()) {
                            peer?.observableEventBroadcaster()
                                ?.onTrack(MediaStreamTrackProxy(track), trans)
                        }
                    }
                }
            }
        }
        super.onTrack(transceiver)
    }

    override fun onRenegotiationNeeded() {
        Handler(Looper.getMainLooper()).post {
            peer?.observableEventBroadcaster()?.onNegotiationNeeded()
        }
    }

    override fun onIceConnectionReceivingChange(receiving: Boolean) {}
    override fun onIceCandidatesRemoved(candidates: Array<out WIceCandidate>?) {}
    override fun onAddStream(stream: MediaStream?) {}
    override fun onRemoveStream(stream: MediaStream?) {}
    override fun onDataChannel(chan: DataChannel?) {}

    /**
     * Sets the [PeerConnectionProxy] to be notified about all events.
     */
    fun setPeerConnection(newPeer: PeerConnectionProxy) {
        peer = newPeer
    }
}
