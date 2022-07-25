package com.instrumentisto.medea_flutter_webrtc.model

import org.webrtc.PeerConnection
import org.webrtc.PeerConnection.IceServer as WIceServer
import org.webrtc.PeerConnection.IceTransportsType as WIceTransportType
import org.webrtc.PeerConnection.RTCConfiguration as WRTCConfiguration

/**
 * Representation of a [PeerConnection.IceTransportsType].
 *
 * @property value [Int] representation of this enum which will be expected on the Flutter side.
 */
enum class IceTransportType(val value: Int) {
  /** Offer all types of ICE candidates. */
  ALL(0),

  /**
   * Only advertise relay-type candidates, like TURN servers, to avoid leaking IP addresses of the
   * client.
   */
  RELAY(1),

  /** Gather all ICE candidate types except host candidates. */
  NOHOST(2),

  /** No ICE candidate offered. */
  NONE(3);

  companion object {
    /**
     * Tries to create an [IceTransportType] based on the provided [Int].
     *
     * @param value [Int] value from which [IceTransportType] will be created.
     *
     * @return [IceTransportType] based on the provided [Int].
     */
    fun fromInt(value: Int) = values().first { it.value == value }
  }

  /**
   * Converts this [IceTransportType] into a [PeerConnection.IceTransportsType].
   *
   * @return [PeerConnection.IceTransportsType] based on this [IceTransportType].
   */
  fun intoWebRtc(): WIceTransportType {
    return when (this) {
      ALL -> WIceTransportType.ALL
      RELAY -> WIceTransportType.RELAY
      NOHOST -> WIceTransportType.NOHOST
      NONE -> WIceTransportType.NONE
    }
  }
}

/**
 * Representation of a [PeerConnection.IceServer].
 *
 * @property urls list of URLs of this [IceServer].
 * @property username Username for authentication on this [IceServer].
 * @property password Password for authentication on this [IceServer].
 */
data class IceServer(val urls: List<String>, val username: String?, val password: String?) {
  /**
   * Converts this [IceServer] into a [PeerConnection.IceServer].
   *
   * @return [PeerConnection.IceServer] based on this [IceServer].
   */
  fun intoWebRtc(): WIceServer {
    val iceServerBuilder = WIceServer.builder(urls)
    if (username != null) {
      iceServerBuilder.setUsername(username)
    }
    if (password != null) {
      iceServerBuilder.setPassword(password)
    }
    return iceServerBuilder.createIceServer()
  }
}

/**
 * Representation of a [PeerConnection.RTCConfiguration].
 *
 * @property iceServers List of [IceServer]s, used by the [PeerConnection] created with this
 * [PeerConnectionConfiguration].
 * @property iceTransportType Type of the ICE transport, used by the [PeerConnection] created with
 * this [PeerConnectionConfiguration].
 */
data class PeerConnectionConfiguration(
    val iceServers: List<IceServer>,
    val iceTransportType: IceTransportType
) {
  /**
   * Converts this [PeerConnectionConfiguration] into a [PeerConnection.RTCConfiguration].
   *
   * @return [PeerConnection.RTCConfiguration] based on this [PeerConnectionConfiguration].
   */
  fun intoWebRtc(): WRTCConfiguration {
    val conf = WRTCConfiguration(iceServers.map { server -> server.intoWebRtc() }.toList())
    conf.iceTransportsType = iceTransportType.intoWebRtc()
    conf.sdpSemantics = PeerConnection.SdpSemantics.UNIFIED_PLAN

    return conf
  }
}
