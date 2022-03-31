package com.cloudwebrtc.webrtc.controller

import com.cloudwebrtc.webrtc.State
import com.cloudwebrtc.webrtc.model.IceServer
import com.cloudwebrtc.webrtc.model.IceTransportType
import com.cloudwebrtc.webrtc.model.PeerConnectionConfiguration
import com.cloudwebrtc.webrtc.proxy.PeerConnectionFactoryProxy
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Controller of creating new [PeerConnectionController]s by a [PeerConnectionFactoryProxy].
 *
 * @property messenger Messenger used for creating new [MethodChannel]s.
 * @param state State used for creating new [PeerConnectionFactoryProxy]s.
 */
class PeerConnectionFactoryController(private val messenger: BinaryMessenger, state: State) :
    MethodChannel.MethodCallHandler {
  /** Factory creating new [PeerConnectionController]s. */
  private val factory: PeerConnectionFactoryProxy = PeerConnectionFactoryProxy(state)

  /** Channel listened for the [MethodCall]s. */
  private val chan = MethodChannel(messenger, ChannelNameGenerator.name("PeerConnectionFactory", 0))

  init {
    chan.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "create" -> {
        val iceTransportTypeArg: Int = call.argument("iceTransportType") ?: 0
        val iceTransportType = IceTransportType.fromInt(iceTransportTypeArg)

        val iceServersArg: List<Map<String, Any>> = call.argument("iceServers") ?: listOf()
        val iceServers: List<IceServer> =
            iceServersArg.map { serv ->
              val urlsArg = serv["urls"] as? List<*>
              val urls = urlsArg?.mapNotNull { it as? String }
              val username = serv["username"] as? String
              val password = serv["password"] as? String

              IceServer(urls ?: listOf(), username, password)
            }

        val newPeer = factory.create(PeerConnectionConfiguration(iceServers, iceTransportType))
        val peerController = PeerConnectionController(messenger, newPeer)
        result.success(peerController.asFlutterResult())
      }
      "dispose" -> {
        chan.setMethodCallHandler(null)
        result.success(null)
      }
    }
  }
}
