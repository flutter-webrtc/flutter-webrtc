package com.instrumentisto.medea_flutter_webrtc

import com.instrumentisto.medea_flutter_webrtc.controller.MediaDevicesController
import com.instrumentisto.medea_flutter_webrtc.controller.PeerConnectionFactoryController
import com.instrumentisto.medea_flutter_webrtc.controller.VideoRendererFactoryController
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.view.TextureRegistry

class MedeaFlutterWebrtcPlugin : FlutterPlugin, ActivityAware {
  private var peerConnectionFactory: PeerConnectionFactoryController? = null
  private var mediaDevices: MediaDevicesController? = null
  private var videoRendererFactory: VideoRendererFactoryController? = null
  private var messenger: BinaryMessenger? = null
  private var state: State? = null
  private var textureRegistry: TextureRegistry? = null

  override fun onAttachedToEngine(registrar: FlutterPlugin.FlutterPluginBinding) {
    messenger = registrar.binaryMessenger
    state = State(registrar.applicationContext)
    textureRegistry = registrar.textureRegistry
  }

  override fun onDetachedFromEngine(registrar: FlutterPlugin.FlutterPluginBinding) {}

  override fun onAttachedToActivity(registrar: ActivityPluginBinding) {
    val permissions = Permissions(registrar.activity)
    registrar.addRequestPermissionsResultListener(permissions)
    mediaDevices = MediaDevicesController(messenger!!, state!!, permissions)
    peerConnectionFactory = PeerConnectionFactoryController(messenger!!, state!!)
    videoRendererFactory = VideoRendererFactoryController(messenger!!, textureRegistry!!)
  }

  override fun onDetachedFromActivityForConfigChanges() {}

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}

  override fun onDetachedFromActivity() {}
}
