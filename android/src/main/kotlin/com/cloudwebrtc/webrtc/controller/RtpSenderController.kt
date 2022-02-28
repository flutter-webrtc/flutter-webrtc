package com.cloudwebrtc.webrtc.controller

import com.cloudwebrtc.webrtc.TrackRepository
import com.cloudwebrtc.webrtc.proxy.RtpSenderProxy
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Controller of [RtpSenderProxy] functional.
 *
 * @param messenger  Messenger used for creating new [MethodChannel]s.
 * @property sender  Underlying [RtpSenderProxy] to perform [MethodCall]s on.
 */
class RtpSenderController(
    messenger: BinaryMessenger,
    private val sender: RtpSenderProxy
) :
    MethodChannel.MethodCallHandler, IdentifiableController {
    /**
     * Unique ID of the [MethodChannel] of this controller.
     */
    private val channelId = nextChannelId()

    /**
     * Channel listened for the [MethodCall]s.
     */
    private val chan =
        MethodChannel(
            messenger,
            ChannelNameGenerator.name("RtpSender", channelId)
        )

    init {
        chan.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "replaceTrack" -> {
                val trackId: String? = call.argument("trackId")
                val track = if (trackId != null) {
                    TrackRepository.getTrack(trackId)!!
                } else {
                    null
                }
                sender.replaceTrack(track)
                result.success(null)
            }
            "dispose" -> {
                chan.setMethodCallHandler(null)
                result.success(null)
            }
        }
    }

    /**
     * Converts this [RtpSenderController] to the Flutter's method call result.
     *
     * @return  [Map] generated from this controller which can be returned to
     *          the Flutter side.
     */
    fun asFlutterResult(): Map<String, Any> = mapOf("channelId" to channelId)
}
