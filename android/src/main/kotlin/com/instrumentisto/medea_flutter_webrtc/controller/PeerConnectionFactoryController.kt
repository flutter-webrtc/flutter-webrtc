package com.instrumentisto.medea_flutter_webrtc.controller

import com.instrumentisto.medea_flutter_webrtc.State
import com.instrumentisto.medea_flutter_webrtc.model.IceServer
import com.instrumentisto.medea_flutter_webrtc.model.IceTransportType
import com.instrumentisto.medea_flutter_webrtc.model.PeerConnectionConfiguration
import com.instrumentisto.medea_flutter_webrtc.model.RtpCapabilities
import com.instrumentisto.medea_flutter_webrtc.model.VideoCodec
import com.instrumentisto.medea_flutter_webrtc.model.VideoCodecInfo
import com.instrumentisto.medea_flutter_webrtc.proxy.PeerConnectionFactoryProxy
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.collections.set
import org.webrtc.MediaStreamTrack

/**
 * Controller of creating new [PeerConnectionController]s by a [PeerConnectionFactoryProxy].
 *
 * @property messenger Messenger used for creating new [MethodChannel]s.
 * @param state State used for creating new [PeerConnectionFactoryProxy]s.
 */
class PeerConnectionFactoryController(
    private val messenger: BinaryMessenger,
    private val state: State
) : Controller {
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
      "getRtpSenderCapabilities" -> {
        val kind: Int? = call.argument("kind")
        val capabilities =
            RtpCapabilities.fromWebRtc(
                factory
                    .getPeerConnectionFactory()
                    .getRtpSenderCapabilities(MediaStreamTrack.MediaType.values()[kind!!]))
        result.success(capabilities.asFlutterResult())
      }
      "getRtpReceiverCapabilities" -> {
        val kind: Int? = call.argument("kind")
        val capabilities =
            RtpCapabilities.fromWebRtc(
                factory
                    .getPeerConnectionFactory()
                    .getRtpReceiverCapabilities(MediaStreamTrack.MediaType.values()[kind!!]))
        result.success(capabilities.asFlutterResult())
      }
      "videoEncoders" -> {
        val map = hashMapOf<VideoCodec, VideoCodecInfo>()

        for (c in state.encoder.getSWCodecs().mapNotNull { VideoCodec.valueOfOrNull(it.name) }) {
          map[c] = VideoCodecInfo(c, false)
        }
        for (c in state.encoder.getHWCodecs().mapNotNull { VideoCodec.valueOfOrNull(it.name) }) {
          map[c] = VideoCodecInfo(c, true)
        }

        result.success(map.values.map { it.asFlutterResult() })
      }
      "videoDecoders" -> {
        val map = hashMapOf<VideoCodec, VideoCodecInfo>()

        for (c in state.decoder.getSWCodecs().mapNotNull { VideoCodec.valueOfOrNull(it.name) }) {
          map[c] = VideoCodecInfo(c, false)
        }
        for (c in state.decoder.getHWCodecs().mapNotNull { VideoCodec.valueOfOrNull(it.name) }) {
          map[c] = VideoCodecInfo(c, true)
        }

        result.success(map.values.map { it.asFlutterResult() })
      }
      "dispose" -> {
        dispose()
        result.success(null)
      }
    }
  }

  /** Releases all the allocated resources. */
  override fun dispose() {
    chan.setMethodCallHandler(null)
    factory.dispose()
  }
}
