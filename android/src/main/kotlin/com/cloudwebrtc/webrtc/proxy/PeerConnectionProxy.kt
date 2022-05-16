package com.cloudwebrtc.webrtc.proxy

import com.cloudwebrtc.webrtc.exception.AddIceCandidateException
import com.cloudwebrtc.webrtc.exception.CreateSdpException
import com.cloudwebrtc.webrtc.exception.SetSdpException
import com.cloudwebrtc.webrtc.model.*
import com.cloudwebrtc.webrtc.model.IceCandidate
import com.cloudwebrtc.webrtc.model.SessionDescription
import java.util.*
import kotlin.collections.ArrayList
import kotlin.coroutines.Continuation
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine
import org.webrtc.*
import org.webrtc.SessionDescription as WSessionDescription

/**
 * Wrapper around a [PeerConnection].
 *
 * @property id Unique ID of this [PeerConnectionProxy].
 * @param peer Underlying [PeerConnection].
 */
class PeerConnectionProxy(val id: Int, peer: PeerConnection) : Proxy<PeerConnection> {
  /** Actual underlying [PeerConnection]. */
  override var obj: PeerConnection = peer

  /** Candidates, added before a remote description has been set on the underlying peer. */
  private var candidatesBuffer: ArrayList<IceCandidate> = ArrayList()

  /** List of all [RtpSenderProxy]s owned by this [PeerConnectionProxy]. */
  private var senders: HashMap<String, RtpSenderProxy> = HashMap()

  /** List of all [RtpReceiverProxy]s owned by this [PeerConnectionProxy]. */
  private var receivers: HashMap<String, RtpReceiverProxy> = HashMap()

  /** List of all [RtpTransceiverProxy]s owned by this [PeerConnectionProxy]. */
  private var transceivers: TreeMap<Int, RtpTransceiverProxy> = TreeMap()

  /**
   * List of subscribers on [dispose] event.
   *
   * This callbacks will be called on [dispose] method call.
   */
  private var onDisposeSubscribers: MutableList<(Int) -> Unit> = mutableListOf()

  /** List of [EventObserver] for this [PeerConnectionProxy]. */
  private var eventObservers: HashSet<EventObserver> = HashSet()

  init {
    syncWithObject()
  }

  companion object {
    /** Observer of a [PeerConnectionProxy] events. */
    interface EventObserver {
      /**
       * Notifies observer about a new [MediaStreamTrackProxy].
       *
       * @param track Newly added [MediaStreamTrackProxy].
       * @param transceiver [RtpTransceiverProxy] of this [MediaStreamTrackProxy].
       */
      fun onTrack(track: MediaStreamTrackProxy, transceiver: RtpTransceiverProxy)

      /**
       * Notifies observer about an [IceConnectionState] update.
       *
       * @param iceConnectionState New [IceConnectionState] of the [PeerConnectionProxy].
       */
      fun onIceConnectionStateChange(iceConnectionState: IceConnectionState)

      /**
       * Notifies observer about a [SignalingState] update.
       *
       * @param signalingState New [SignalingState] of the [PeerConnectionProxy].
       */
      fun onSignalingStateChange(signalingState: SignalingState)

      /**
       * Notifies observer about a [PeerConnectionState] update.
       *
       * @param peerConnectionState New [PeerConnectionState] of the [PeerConnectionProxy].
       */
      fun onConnectionStateChange(peerConnectionState: PeerConnectionState)

      /**
       * Notifies observer about an [IceGatheringState] update.
       *
       * @param iceGatheringState New [IceGatheringState] of the [PeerConnectionProxy].
       */
      fun onIceGatheringStateChange(iceGatheringState: IceGatheringState)

      /**
       * Notifies observer about a new [IceCandidate].
       *
       * @param candidate Newly added [IceCandidate].
       */
      fun onIceCandidate(candidate: IceCandidate)

      /** Notifies observer about the necessity to perform a new renegotiation process. */
      fun onNegotiationNeeded()
    }

    /**
     * Creates an [SdpObserver] which will resolve the provided [Continuation] on
     * [SdpObserver.onCreateSuccess] or [SdpObserver.onCreateFailure] .
     *
     * @param continuation [Continuation] which will be resumed.
     *
     * @return Newly created [SdpObserver].
     */
    private fun createSdpObserver(continuation: Continuation<SessionDescription>): SdpObserver {
      return object : SdpObserver {
        override fun onCreateSuccess(sdp: WSessionDescription) {
          continuation.resume(SessionDescription.fromWebRtc(sdp))
        }

        override fun onSetSuccess() {
          throw RuntimeException("onSetSuccess function can't be called when creating offer")
        }

        override fun onCreateFailure(msg: String?) {
          var message = msg
          if (message == null) {
            message = ""
          }
          continuation.resumeWithException(CreateSdpException(message))
        }

        override fun onSetFailure(msg: String?) {
          throw RuntimeException("onSetFailure function can't be called when creating offer")
        }
      }
    }

    /**
     * Creates an [SdpObserver] which will resolve the provided [Continuation] on
     * [SdpObserver.onSetSuccess] or [SdpObserver.onSetFailure].
     *
     * @param continuation [Continuation] which will be resumed.
     *
     * @return Newly created [SdpObserver].
     */
    private fun setSdpObserver(continuation: Continuation<Unit>): SdpObserver {
      return object : SdpObserver {
        override fun onCreateSuccess(sdp: org.webrtc.SessionDescription?) {
          throw RuntimeException("onCreateSuccess function can't be called when settings offer")
        }

        override fun onSetSuccess() {
          continuation.resume(Unit)
        }

        override fun onCreateFailure(msg: String?) {
          throw RuntimeException("onCreateFailure function can't be called when settings offer")
        }

        override fun onSetFailure(msg: String?) {
          var message = msg
          if (message == null) {
            message = ""
          }
          continuation.resumeWithException(SetSdpException(message))
        }
      }
    }
  }

  override fun syncWithObject() {
    syncSenders()
    syncReceivers()
    syncTransceivers()
  }

  /**
   * Adds an [EventObserver] for this [PeerConnectionProxy].
   *
   * @param eventObserver [EventObserver] which will be subscribed.
   */
  fun addEventObserver(eventObserver: EventObserver) {
    eventObservers.add(eventObserver)
  }

  /**
   * Removes an [EventObserver] from this [PeerConnectionProxy].
   *
   * @param eventObserver [EventObserver] which will be unsubscribed.
   */
  fun removeEventObserver(eventObserver: EventObserver) {
    eventObservers.remove(eventObserver)
  }

  /**
   * Creates a broadcaster to all the [eventObservers] of this [PeerConnectionProxy].
   *
   * @return [EventObserver] broadcasting calls to all the [eventObservers].
   */
  internal fun observableEventBroadcaster(): EventObserver {
    return object : EventObserver {
      override fun onTrack(track: MediaStreamTrackProxy, transceiver: RtpTransceiverProxy) {
        eventObservers.forEach { it.onTrack(track, transceiver) }
      }

      override fun onIceConnectionStateChange(iceConnectionState: IceConnectionState) {
        eventObservers.forEach { it.onIceConnectionStateChange(iceConnectionState) }
      }

      override fun onSignalingStateChange(signalingState: SignalingState) {
        eventObservers.forEach { it.onSignalingStateChange(signalingState) }
      }

      override fun onConnectionStateChange(peerConnectionState: PeerConnectionState) {
        eventObservers.forEach { it.onConnectionStateChange(peerConnectionState) }
      }

      override fun onIceGatheringStateChange(iceGatheringState: IceGatheringState) {
        eventObservers.forEach { it.onIceGatheringStateChange(iceGatheringState) }
      }

      override fun onIceCandidate(candidate: IceCandidate) {
        eventObservers.forEach { it.onIceCandidate(candidate) }
      }

      override fun onNegotiationNeeded() {
        eventObservers.forEach { it.onNegotiationNeeded() }
      }
    }
  }

  /**
   * Notifies about [RtpReceiverProxy]'s [MediaStreamTrackProxy] being ended.
   *
   * @param endedReceiver [RtpReceiver] being ended.
   */
  fun receiverEnded(endedReceiver: RtpReceiver) {
    val receiver = receivers[endedReceiver.id()]
    receiver?.notifyRemoved()
  }

  /**
   * Disposes the underlying [PeerConnection], [RtpSenderProxy]s, [RtpReceiverProxy] and notifies
   * all [onDispose] subscribers about it.
   */
  fun dispose() {
    obj.dispose()
    for (receiver in receivers.values) {
      receiver.notifyRemoved()
    }
    senders = HashMap()
    receivers = HashMap()
    onDisposeSubscribers.forEach { sub -> sub(id) }
  }

  /**
   * Subscribes to the [dispose] event of this [PeerConnectionProxy].
   *
   * @param f Callback which will be called on [dispose].
   */
  fun onDispose(f: (Int) -> Unit) {
    onDisposeSubscribers.add(f)
  }

  /**
   * Synchronizes and returns all the [RtpTransceiverProxy]s of this [PeerConnectionProxy].
   *
   * @return all [RtpTransceiverProxy]s of this [PeerConnectionProxy].
   */
  fun getTransceivers(): List<RtpTransceiverProxy> {
    syncTransceivers()
    return transceivers.values.toList()
  }

  /**
   * Creates a new [SessionDescription] offer.
   *
   * @return Newly created [SessionDescription].
   */
  suspend fun createOffer(): SessionDescription {
    return suspendCoroutine { continuation ->
      obj.createOffer(createSdpObserver(continuation), MediaConstraints())
    }
  }

  /**
   * Creates a new [SessionDescription] answer.
   *
   * @return Newly created [SessionDescription].
   */
  suspend fun createAnswer(): SessionDescription {
    return suspendCoroutine { continuation ->
      obj.createAnswer(createSdpObserver(continuation), MediaConstraints())
    }
  }

  /**
   * Sets the provided local [SessionDescription] to the underlying [PeerConnection].
   *
   * @param description SDP to be applied.
   */
  suspend fun setLocalDescription(description: SessionDescription?) {
    suspendCoroutine<Unit> { continuation ->
      if (description == null) {
        obj.setLocalDescription(setSdpObserver(continuation))
      } else {
        obj.setLocalDescription(setSdpObserver(continuation), description.intoWebRtc())
      }
    }
  }

  /**
   * Sets the provided remote [SessionDescription] to the underlying [PeerConnection].
   *
   * @param description SDP to be applied.
   */
  suspend fun setRemoteDescription(description: SessionDescription) {
    suspendCoroutine<Unit> { continuation ->
      obj.setRemoteDescription(setSdpObserver(continuation), description.intoWebRtc())
    }
    while (candidatesBuffer.isNotEmpty()) {
      addIceCandidate(candidatesBuffer.removeAt(0))
    }
  }

  /** Adds a new [IceCandidate] to the underlying [PeerConnection]. */
  suspend fun addIceCandidate(candidate: IceCandidate) {
    suspendCoroutine<Unit> { continuation ->
      if (obj.remoteDescription != null) {
        obj.addIceCandidate(
            candidate.intoWebRtc(),
            object : AddIceObserver {
              override fun onAddSuccess() {
                continuation.resume(Unit)
              }

              override fun onAddFailure(msg: String?) {
                var message = msg
                if (message == null) {
                  message = ""
                }
                continuation.resumeWithException(AddIceCandidateException(message))
              }
            })
      } else {
        candidatesBuffer.add(candidate)
        continuation.resume(Unit)
      }
    }
  }

  /**
   * Creates a new [RtpTransceiverProxy] based on the provided config.
   *
   * @param mediaType Initial [MediaType] of the newly created
   * ```
   *                   [RtpTransceiverProxy].
   * @param init
   * ```
   * Configuration of the newly created [RtpTransceiverProxy].
   *
   * @return Newly created [RtpTransceiverProxy].
   */
  fun addTransceiver(mediaType: MediaType, init: RtpTransceiverInit?): RtpTransceiverProxy {
    obj.addTransceiver(mediaType.intoWebRtc(), init?.intoWebRtc())
    syncTransceivers()
    return transceivers.lastEntry()!!.value
  }

  /** Requests the underlying [PeerConnection] to redo [IceCandidate] gathering. */
  fun restartIce() {
    obj.restartIce()
  }

  /**
   * Synchronizes underlying pointers of old [RtpSenderProxy]s and creates [RtpSenderProxy]s for new
   * [RtpSender]s.
   */
  private fun syncSenders() {
    val peerSenders = obj.senders
    for (peerSender in peerSenders) {
      val peerSenderId = peerSender.id()

      val oldSender = senders[peerSenderId]
      if (oldSender == null) {
        senders[peerSenderId] = RtpSenderProxy(peerSender)
      } else {
        oldSender.replace(peerSender)
      }
    }
  }

  /**
   * Synchronizes underlying pointers of old [RtpReceiverProxy]s and creates [RtpReceiverProxy]s for
   * new [RtpReceiver]s.
   */
  private fun syncReceivers() {
    val peerReceivers = obj.receivers
    for (peerReceiver in peerReceivers) {
      val peerReceiverId = peerReceiver.id()

      val oldReceiver = receivers[peerReceiverId]
      if (oldReceiver == null) {
        receivers[peerReceiverId] = RtpReceiverProxy(peerReceiver)
      } else {
        oldReceiver.replace(peerReceiver)
      }
    }
  }

  /**
   * Synchronizes underlying pointers of old [RtpTransceiverProxy]s and creates
   * [RtpTransceiverProxy]s for new [RtpTransceiver]s.
   */
  private fun syncTransceivers() {
    val peerTransceivers = obj.transceivers.withIndex()

    for ((id, peerTransceiver) in peerTransceivers) {
      val oldTransceiver = transceivers[id]
      if (oldTransceiver == null) {
        transceivers[id] = RtpTransceiverProxy(peerTransceiver)
      } else {
        oldTransceiver.replace(peerTransceiver)
      }
    }
  }
}
