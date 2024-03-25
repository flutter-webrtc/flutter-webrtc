package com.instrumentisto.medea_flutter_webrtc.controller

import com.instrumentisto.medea_flutter_webrtc.TrackRepository
import com.instrumentisto.medea_flutter_webrtc.proxy.RtpSenderProxy
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Controller of [RtpSenderProxy] functional.
 *
 * @param messenger Messenger used for creating new [MethodChannel]s.
 * @property sender Underlying [RtpSenderProxy] to perform [MethodCall]s on.
 */
class RtpSenderController(messenger: BinaryMessenger, private val sender: RtpSenderProxy) :
    MethodChannel.MethodCallHandler, IdentifiableController {
  /** Unique ID of the [MethodChannel] of this controller. */
  private val channelId = nextChannelId()

  /** Channel listened for the [MethodCall]s. */
  private val chan = MethodChannel(messenger, ChannelNameGenerator.name("RtpSender", channelId))

  init {
    chan.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "replaceTrack" -> {
        val trackId: String? = call.argument("trackId")
        val track =
            if (trackId != null) {
              TrackRepository.getTrack(trackId)!!
            } else {
              null
            }
        sender.replaceTrack(track)
        result.success(null)
      }
      "getParameters" -> {
        val encodings =
            sender.getParameters().encodings.map { enc ->
              mapOf(
                  "rid" to enc.rid,
                  "active" to enc.active,
                  "maxBitrate" to enc.maxBitrateBps,
                  "maxFramerate" to enc.maxFramerate,
                  "scaleResolutionDownBy" to enc.scaleResolutionDownBy,
                  "scalabilityMode" to enc.scalabilityMode,
              )
            }

        result.success(mapOf("encodings" to encodings))
      }
      "setParameters" -> {
        val params = sender.getParameters()
        val encodings: List<Map<String, Any>> = call.argument("encodings")!!

        for (e in encodings) {
          val rid = e["rid"] as String
          val enc = params.encodings.find { encoding -> encoding.rid == rid }
          if (enc == null) {
            result.error(
                "SenderException",
                "Could not set parameters: failed to find encoding with rid = $rid",
                null)
            return
          }

          enc.active = e["active"] as Boolean
          enc.maxBitrateBps = e["maxBitrate"] as Int?
          enc.maxFramerate = e["maxFramerate"] as Int?
          enc.scaleResolutionDownBy = e["scaleResolutionDownBy"] as Double?
          enc.scalabilityMode = e["scalabilityMode"] as String?
        }

        if (!sender.setParameters(params)) {
          result.error("SenderException", "Could not set parameters", null)
          return
        }

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
   * @return [Map] generated from this controller which can be returned to the Flutter side.
   */
  fun asFlutterResult(): Map<String, Any> = mapOf("channelId" to channelId)
}
