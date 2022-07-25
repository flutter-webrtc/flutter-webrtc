package com.instrumentisto.medea_flutter_webrtc.proxy

import android.media.AudioManager.*
import com.instrumentisto.medea_flutter_webrtc.State
import com.instrumentisto.medea_flutter_webrtc.model.PeerConnectionConfiguration

/**
 * Creator of new [PeerConnectionProxy]s.
 *
 * @property state Global state used for creation.
 */
class PeerConnectionFactoryProxy(val state: State) {
  /** Counter for generating new [PeerConnectionProxy] IDs. */
  private var lastPeerConnectionId: Int = 0

  /**
   * All [PeerObserver]s created by this [PeerConnectionFactoryProxy].
   *
   * [PeerObserver]s will be removed on a [PeerConnectionProxy] dispose.
   */
  private var peerObservers: HashMap<Int, PeerObserver> = HashMap()

  /**
   * Creates a new [PeerConnectionProxy] based on the provided [PeerConnectionConfiguration].
   *
   * @param config Config with which new [PeerConnectionProxy] will be created.
   *
   * @return Newly created [PeerConnectionProxy].
   */
  fun create(config: PeerConnectionConfiguration): PeerConnectionProxy {
    if (peerObservers.isEmpty()) {
      state.getAudioManager().mode = MODE_IN_COMMUNICATION
    }

    val id = nextId()
    val peerObserver = PeerObserver()
    val peer =
        state.getPeerConnectionFactory().createPeerConnection(config.intoWebRtc(), peerObserver)
            ?: throw UnknownError("Creating new PeerConnection was failed because of unknown issue")
    val peerProxy = PeerConnectionProxy(id, peer)
    peerObserver.setPeerConnection(peerProxy)
    peerProxy.onDispose(::removePeerObserver)

    peerObservers[id] = peerObserver

    return peerProxy
  }

  /** Removes the specified [PeerObserver] from the [peerObservers]. */
  private fun removePeerObserver(id: Int) {
    peerObservers.remove(id)
    if (peerObservers.isEmpty()) {
      state.getAudioManager().mode = MODE_NORMAL
    }
  }

  /**
   * Generates a new [PeerConnectionProxy] ID.
   *
   * @return Newly generated [PeerConnectionProxy] ID.
   */
  private fun nextId(): Int {
    return lastPeerConnectionId++
  }
}
