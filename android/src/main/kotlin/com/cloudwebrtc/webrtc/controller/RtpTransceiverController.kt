package com.cloudwebrtc.webrtc.controller

import com.cloudwebrtc.webrtc.model.RtpTransceiverDirection
import com.cloudwebrtc.webrtc.proxy.RtpTransceiverProxy
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
      "getMid" -> {
        result.success(transceiver.getMid())
      }
      "getDirection" -> {
        result.success(transceiver.getDirection().value)
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
        "sender" to RtpSenderController(messenger, transceiver.getSender()).asFlutterResult(),
        "mid" to transceiver.getMid() as Any?)
  }
}
