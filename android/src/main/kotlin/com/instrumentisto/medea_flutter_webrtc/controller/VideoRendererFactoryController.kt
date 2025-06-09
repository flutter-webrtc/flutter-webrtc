package com.instrumentisto.medea_flutter_webrtc.controller

import com.instrumentisto.medea_flutter_webrtc.FlutterRtcVideoRenderer
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.TextureRegistry

/**
 * Controller of creating new [FlutterRtcVideoRenderer]s.
 *
 * @property messenger Messenger used for creating new [MethodChannel]s.
 * @property textureRegistry Registry to create new textures with.
 */
class VideoRendererFactoryController(
    private val messenger: BinaryMessenger,
    private val textureRegistry: TextureRegistry
) : Controller {
  /** Channel listened for the [MethodCall]s. */
  private val chan = MethodChannel(messenger, ChannelNameGenerator.name("VideoRendererFactory", 0))

  init {
    chan.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "create" -> {
        val renderer = FlutterRtcVideoRenderer(textureRegistry)
        result.success(VideoRendererController(messenger, renderer).asFlutterResult())
      }
    }
  }

  /** Releases all the allocated resources. */
  override fun dispose() {
    chan.setMethodCallHandler(null)
  }
}
