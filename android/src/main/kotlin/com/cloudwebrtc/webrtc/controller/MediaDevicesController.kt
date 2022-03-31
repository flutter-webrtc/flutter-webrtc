package com.cloudwebrtc.webrtc.controller

import com.cloudwebrtc.webrtc.MediaDevices
import com.cloudwebrtc.webrtc.State
import com.cloudwebrtc.webrtc.exception.OverconstrainedException
import com.cloudwebrtc.webrtc.model.Constraints
import com.cloudwebrtc.webrtc.proxy.MediaStreamTrackProxy
import com.cloudwebrtc.webrtc.proxy.PeerConnectionProxy
import com.cloudwebrtc.webrtc.utils.AnyThreadSink
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Controller of [MediaDevices] functional.
 *
 * @property messenger Messenger used for creating new [MethodChannel]s.
 * @param state State used for creating new [MediaStreamTrackProxy]s.
 */
class MediaDevicesController(private val messenger: BinaryMessenger, state: State) :
    MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
  /** Underlying [MediaDevices] to perform [MethodCall]s on. */
  private val mediaDevices = MediaDevices(state)

  /** Channel listened for [MethodCall]s. */
  private val chan = MethodChannel(messenger, ChannelNameGenerator.name("MediaDevices", 0))

  /** Event channel into which all [PeerConnectionProxy] events are sent. */
  private val eventChannel =
      EventChannel(messenger, ChannelNameGenerator.name("MediaDevicesEvent", 0))

  /** Event sink into which all [PeerConnectionProxy] events are sent. */
  private var eventSink: AnyThreadSink? = null

  /**
   * Observer for the [MediaDevices] events, which will send all the events to the Flutter side via
   * [EventChannel].
   */
  private val eventObserver =
      object : MediaDevices.Companion.EventObserver {
        override fun onDeviceChange() {
          eventSink?.success(mapOf("event" to "onDeviceChange"))
        }
      }

  init {
    chan.setMethodCallHandler(this)
    eventChannel.setStreamHandler(this)
    mediaDevices.addObserver(eventObserver)
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "enumerateDevices" -> {
        result.success(mediaDevices.enumerateDevices().map { it.asFlutterResult() })
      }
      "getUserMedia" -> {
        val constraintsArg: Map<String, Any> = call.argument("constraints")!!
        try {
          val tracks = mediaDevices.getUserMedia(Constraints.fromMap(constraintsArg))
          result.success(tracks.map { MediaStreamTrackController(messenger, it).asFlutterResult() })
        } catch (e: OverconstrainedException) {
          result.error("OverconstrainedError", null, null)
        }
      }
      "setOutputAudioId" -> {
        val deviceId: String = call.argument("deviceId")!!
        mediaDevices.setOutputAudioId(deviceId)
        result.success(null)
      }
    }
  }

  override fun onListen(obj: Any?, sink: EventChannel.EventSink?) {
    if (sink != null) {
      eventSink = AnyThreadSink(sink)
    }
  }

  override fun onCancel(obj: Any?) {
    eventSink = null
  }
}
