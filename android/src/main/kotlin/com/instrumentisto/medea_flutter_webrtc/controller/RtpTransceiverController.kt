package com.instrumentisto.medea_flutter_webrtc.controller

import com.instrumentisto.medea_flutter_webrtc.model.CodecCapability
import com.instrumentisto.medea_flutter_webrtc.model.MediaType
import com.instrumentisto.medea_flutter_webrtc.model.RtpTransceiverDirection
import com.instrumentisto.medea_flutter_webrtc.proxy.RtpTransceiverProxy
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Controller of [RtpTransceiverProxy] functional.
 *
 * @property messenger Messenger used for creating new [MethodChannel]s.
 * @property transceiver Underlying [RtpTransceiverProxy] to perform [MethodCall]s on.
 */
class RtpTransceiverController(
    private val messenger: BinaryMessenger,
    private val transceiver: RtpTransceiverProxy
) : MethodChannel.MethodCallHandler, IdentifiableController {
  /** Unique ID of the [MethodChannel] of this controller. */
  private val channelId = nextChannelId()

  /** Channel listened for the [MethodCall]s. */
  private val chan =
      MethodChannel(messenger, ChannelNameGenerator.name("RtpTransceiver", channelId))

  init {
    chan.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "setDirection" -> {
        val direction = RtpTransceiverDirection.fromInt(call.argument("direction")!!)
        transceiver.setDirection(direction)
        result.success(null)
      }
      "setCodecPreferences" -> {
        val args: List<Map<String, Any>> = call.argument("codecs") ?: listOf()
        val codecs =
            args.map {
              CodecCapability(
                  it["preferredPayloadType"] as Int,
                  it["name"] as String,
                  MediaType.fromInt(it["kind"] as Int),
                  it["clockRate"] as Int,
                  it["numChannels"] as Int?,
                  it["parameters"] as Map<String, String>,
                  it["mimeType"] as String)
            }
        transceiver.setCodecPreferences(codecs)
        result.success(null)
      }
      "setRecv" -> {
        val recv = call.argument<Boolean>("recv")!!
        transceiver.setRecv(recv)
        result.success(null)
      }
      "setSend" -> {
        val send = call.argument<Boolean>("send")!!
        transceiver.setSend(send)
        result.success(null)
      }
      "getMid" -> {
        result.success(transceiver.mid)
      }
      "getDirection" -> {
        result.success(transceiver.direction.value)
      }
      "stop" -> {
        transceiver.stop()
        result.success(null)
      }
      "dispose" -> {
        chan.setMethodCallHandler(null)
        result.success(null)
      }
    }
  }

  /**
   * Converts this [RtpTransceiverController] to the Flutter's method call result.
   *
   * @return [Map] generated from this controller which can be returned to the Flutter side.
   */
  fun asFlutterResult(): Map<String, Any?> {
    return mapOf(
        "channelId" to channelId,
        "sender" to RtpSenderController(messenger, transceiver.sender).asFlutterResult(),
        "mid" to transceiver.mid as Any?)
  }
}
