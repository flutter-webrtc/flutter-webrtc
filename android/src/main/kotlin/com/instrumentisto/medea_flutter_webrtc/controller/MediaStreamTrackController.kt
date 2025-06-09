package com.instrumentisto.medea_flutter_webrtc.controller

import com.instrumentisto.medea_flutter_webrtc.proxy.MediaStreamTrackProxy
import com.instrumentisto.medea_flutter_webrtc.utils.AnyThreadSink
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import org.webrtc.MediaStreamTrack

/**
 * Controller of [MediaStreamTrackProxy] functional.
 *
 * @property messenger Messenger used for creating new [MethodChannel]s.
 * @property track Underlying [MediaStreamTrackProxy] to perform [MethodCall]s on.
 */
class MediaStreamTrackController(
    private val messenger: BinaryMessenger,
    val track: MediaStreamTrackProxy
) : EventChannel.StreamHandler, Controller {
  /** [CoroutineScope] for this [MediaStreamTrackController] */
  private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)

  /** Unique ID of the [MethodChannel] of this controller. */
  private val channelId: Long = nextChannelId()

  /** ID of the underlying [MediaStreamTrack]. */
  val id: String = track.id

  /** Channel listened for the [MethodCall]s. */
  private val chan: MethodChannel =
      MethodChannel(messenger, ChannelNameGenerator.name("MediaStreamTrack", channelId))

  /** Event channel to send all the [MediaStreamTrackProxy] events into. */
  private val eventChannel: EventChannel =
      EventChannel(messenger, ChannelNameGenerator.name("MediaStreamTrackEvent", channelId))

  /** Event sink ito send all the [MediaStreamTrackProxy] events into. */
  private var eventSink: AnyThreadSink? = null

  /** [MediaStreamTrackProxy] events observer, sending all the events to the [eventSink]. */
  private var eventObserver: MediaStreamTrackProxy.Companion.EventObserver? = null

  init {
    ControllerRegistry.register(this)

    eventObserver =
        object : MediaStreamTrackProxy.Companion.EventObserver {
          override fun onEnded() {
            eventSink?.success(mapOf("event" to "onEnded"))
          }
        }

    chan.setMethodCallHandler(this)
    eventChannel.setStreamHandler(this)
    track.addEventObserver(eventObserver!!)
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "setEnabled" -> {
        val enabled: Boolean = call.argument("enabled")!!
        track.setEnabled(enabled)
        result.success(null)
      }
      "state" -> {
        result.success(track.state.value)
      }
      "width" -> {
        scope.launch { result.success(track.width()) }
      }
      "height" -> {
        scope.launch { result.success(track.height()) }
      }
      "stop" -> {
        track.stop()
        result.success(null)
      }
      "clone" -> {
        result.success(MediaStreamTrackController(messenger, track.fork()).asFlutterResult())
      }
      "dispose" -> {
        disposeInternal(false)
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
    eventChannel.setStreamHandler(null)
    eventSink?.endOfStream()
    eventSink = null
  }

  override fun dispose() {
    disposeInternal(true)
  }

  /**
   * Converts this [MediaStreamTrackController] to the Flutter's method call result.
   *
   * @return [Map] generated from this controller which can be returned to the Flutter side.
   */
  fun asFlutterResult(): Map<String, Any> =
      listOf(
              Pair("channelId", channelId),
              Pair("id", track.id),
              Pair("kind", track.kind.value),
              Pair("deviceId", track.deviceId),
              Pair("facingMode", track.facingMode?.value))
          .mapNotNull { p -> p.second?.let { Pair(p.first, it) } }
          .toMap()

  /** Releases all the allocated resources. */
  private fun disposeInternal(cancel: Boolean) {
    ControllerRegistry.unregister(this)
    scope.cancel("disposed")
    chan.setMethodCallHandler(null)
    track.stop()
    track.removeEventObserver(eventObserver!!)
    eventObserver = null

    if (cancel) {
      onCancel(null)
    }
  }
}
