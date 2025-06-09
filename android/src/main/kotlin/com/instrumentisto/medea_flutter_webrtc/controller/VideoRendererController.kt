package com.instrumentisto.medea_flutter_webrtc.controller

import com.instrumentisto.medea_flutter_webrtc.FlutterRtcVideoRenderer
import com.instrumentisto.medea_flutter_webrtc.TrackRepository
import com.instrumentisto.medea_flutter_webrtc.proxy.VideoTrackProxy
import com.instrumentisto.medea_flutter_webrtc.utils.AnyThreadSink
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Controller of [FlutterRtcVideoRenderer].
 *
 * @param messenger Messenger used for creating new [MethodChannel]s.
 * @property videoRenderer Underlying [FlutterRtcVideoRenderer] to perform [MethodCall]s on.
 */
class VideoRendererController(
    messenger: BinaryMessenger,
    private val videoRenderer: FlutterRtcVideoRenderer,
) : EventChannel.StreamHandler, Controller {
  /** Unique ID of the [MethodChannel] of this controller. */
  private val channelId: Long = nextChannelId()

  /** Channel listened for the [MethodCall]s. */
  private val chan: MethodChannel =
      MethodChannel(messenger, ChannelNameGenerator.name("VideoRenderer", channelId))

  /** Event channel into which all [FlutterRtcVideoRenderer] events are sent. */
  private val eventChannel: EventChannel =
      EventChannel(messenger, ChannelNameGenerator.name("VideoRendererEvent", channelId))

  /** Event sink into which all [FlutterRtcVideoRenderer] events are sent. */
  private var eventSink: AnyThreadSink? = null

  init {
    chan.setMethodCallHandler(this)
    eventChannel.setStreamHandler(this)
    ControllerRegistry.register(this)

    videoRenderer.setEventListener(
        object : FlutterRtcVideoRenderer.Companion.EventListener {
          override fun onFirstFrameRendered(id: Long) {
            eventSink?.success(mapOf("event" to "onFirstFrameRendered", "id" to id))
          }

          override fun onTextureChangeVideoSize(id: Long, height: Int, width: Int, rotation: Int) {
            eventSink?.success(
                mapOf(
                    "event" to "onTextureChange",
                    "id" to id,
                    "width" to width,
                    "height" to height,
                    "rotation" to rotation))
          }
        })
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "setSrcObject" -> {
        val trackId: String? = call.argument("trackId")

        if (trackId == null) {
          videoRenderer.setVideoTrack(null)
        } else {
          val track = TrackRepository.getTrack(trackId)!!
          val videoTrack = VideoTrackProxy(track)
          videoRenderer.setVideoTrack(videoTrack)
        }

        result.success(null)
      }
      "dispose" -> {
        dispose()
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

  /**
   * Converts this [VideoRendererController] to the Flutter's method call result.
   *
   * @return [Map] generated from this controller which can be returned to the Flutter side.
   */
  fun asFlutterResult(): Map<String, Any> =
      mapOf("channelId" to channelId, "textureId" to videoRenderer.textureId())

  override fun dispose() {
    ControllerRegistry.unregister(this)
    chan.setMethodCallHandler(null)
    onCancel(null)
    videoRenderer.dispose()
  }
}
