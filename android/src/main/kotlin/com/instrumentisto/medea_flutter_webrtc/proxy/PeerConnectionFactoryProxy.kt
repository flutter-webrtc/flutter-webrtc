package com.instrumentisto.medea_flutter_webrtc.proxy

import android.media.AudioManager.*
import com.instrumentisto.medea_flutter_webrtc.ForegroundCallService
import com.instrumentisto.medea_flutter_webrtc.Permissions
import com.instrumentisto.medea_flutter_webrtc.State
import com.instrumentisto.medea_flutter_webrtc.model.PeerConnectionConfiguration
import org.webrtc.PeerConnectionFactory

/**
 * Creator of new [PeerConnectionProxy]s.
 *
 * @property state Global state used for creation.
 */
class PeerConnectionFactoryProxy(private val state: State, private val permissions: Permissions) {
  /** Counter for generating new [PeerConnectionProxy] IDs. */
  private var lastPeerConnectionId: Int = 0

  /**
   * All [PeerObserver]s created by this [PeerConnectionFactoryProxy].
   *
   * [PeerObserver]s will be removed on a [PeerConnectionProxy] dispose.
   */
  private var peerObservers: HashMap<Int, PeerObserver> = HashMap()

  /** Disposed state of this [PeerConnectionFactoryProxy]. */
  private var disposed = false

  /**
   * Creates a new [PeerConnectionProxy] based on the provided [PeerConnectionConfiguration].
   *
   * @param config Config with which new [PeerConnectionProxy] will be created.
   *
   * @return Newly created [PeerConnectionProxy].
   */
  suspend fun create(config: PeerConnectionConfiguration): PeerConnectionProxy {
    val id = nextId()
    val peerObserver = PeerObserver()
    val peer =
        state.getPeerConnectionFactory().createPeerConnection(config.intoWebRtc(), peerObserver)
            ?: throw UnknownError("Creating new PeerConnection was failed because of unknown issue")
    val peerProxy = PeerConnectionProxy(id, peer)
    peerObserver.setPeerConnection(peerProxy)
    peerProxy.onDispose(::removePeerObserver)

    if (peerObservers.isEmpty()) {
      state.getAudioManager().mode = MODE_IN_COMMUNICATION
      ForegroundCallService.start(state.context, permissions)
    }

    peerObservers[id] = peerObserver

    return peerProxy
  }

  /** Returns the underlying [PeerConnectionFactory]. */
  fun getPeerConnectionFactory(): PeerConnectionFactory {
    return state.getPeerConnectionFactory()
  }

  /** Disposes the underlying [PeerConnectionFactory]. */
  fun dispose() {
    if (disposed) return

    state.getPeerConnectionFactory().dispose()
    disposed = true
  }

  /** Removes the specified [PeerObserver] from the [peerObservers]. */
  private fun removePeerObserver(id: Int) {
    peerObservers.remove(id)
    if (peerObservers.isEmpty()) {
      state.getAudioManager().mode = MODE_NORMAL
      ForegroundCallService.stop(state.context, permissions)
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
