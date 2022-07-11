package com.cloudwebrtc.webrtc.controller

import com.cloudwebrtc.webrtc.MediaDevices
import com.cloudwebrtc.webrtc.Permissions
import com.cloudwebrtc.webrtc.State
import com.cloudwebrtc.webrtc.exception.GetUserMediaException
import com.cloudwebrtc.webrtc.model.Constraints
import com.cloudwebrtc.webrtc.proxy.MediaStreamTrackProxy
import com.cloudwebrtc.webrtc.proxy.PeerConnectionProxy
import com.cloudwebrtc.webrtc.utils.AnyThreadSink
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

/**
 * Controller of [MediaDevices] functional.
 *
 * @property messenger Messenger used for creating new [MethodChannel]s.
 * @param state State used for creating new [MediaStreamTrackProxy]s.
 */
class MediaDevicesController(
    private val messenger: BinaryMessenger,
    state: State,
    permissions: Permissions
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
  /** Underlying [MediaDevices] to perform [MethodCall]s on. */
  private val mediaDevices = MediaDevices(state, permissions)

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
        GlobalScope.launch(Dispatchers.Main) {
          try {
            result.success(mediaDevices.enumerateDevices().map { it.asFlutterResult() })
          } catch (e: GetUserMediaException) {
            when (e.kind) {
              GetUserMediaException.Kind.Audio ->
                  result.error("GetUserMediaAudioException", e.message, null)
              GetUserMediaException.Kind.Video ->
                  result.error("GetUserMediaVideoException", e.message, null)
            }
          }
        }
      }
      "getUserMedia" -> {
        GlobalScope.launch(Dispatchers.Main) {
          val constraintsArg: Map<String, Any> = call.argument("constraints")!!
          try {
            val tracks = mediaDevices.getUserMedia(Constraints.fromMap(constraintsArg))
            result.success(
                tracks.map { MediaStreamTrackController(messenger, it).asFlutterResult() })
          } catch (e: GetUserMediaException) {
            when (e.kind) {
              GetUserMediaException.Kind.Audio ->
                  result.error("GetUserMediaAudioException", e.message, null)
              GetUserMediaException.Kind.Video ->
                  result.error("GetUserMediaVideoException", e.message, null)
            }
          }
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
