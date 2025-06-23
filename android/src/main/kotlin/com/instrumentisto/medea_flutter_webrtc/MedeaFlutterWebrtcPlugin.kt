package com.instrumentisto.medea_flutter_webrtc

import android.util.Log
import com.instrumentisto.medea_flutter_webrtc.controller.ControllerRegistry
import com.instrumentisto.medea_flutter_webrtc.controller.MediaDevicesController
import com.instrumentisto.medea_flutter_webrtc.controller.PeerConnectionFactoryController
import com.instrumentisto.medea_flutter_webrtc.controller.VideoRendererFactoryController
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.view.TextureRegistry

private val TAG = MedeaFlutterWebrtcPlugin::class.java.simpleName

class MedeaFlutterWebrtcPlugin : FlutterPlugin, ActivityAware {
  private var peerConnectionFactory: PeerConnectionFactoryController? = null
  private var mediaDevices: MediaDevicesController? = null
  private var videoRendererFactory: VideoRendererFactoryController? = null
  private var messenger: BinaryMessenger? = null
  private var state: State? = null
  private var textureRegistry: TextureRegistry? = null
  private var permissions: Permissions? = null
  private var activityPluginBinding: ActivityPluginBinding? = null

  override fun onAttachedToEngine(registrar: FlutterPlugin.FlutterPluginBinding) {
    Log.i(TAG, "Attached to engine")

    messenger = registrar.binaryMessenger
    state = State(registrar.applicationContext)
    textureRegistry = registrar.textureRegistry
  }

  override fun onDetachedFromEngine(registrar: FlutterPlugin.FlutterPluginBinding) {
    Log.i(TAG, "Detached from engine")

    ControllerRegistry.disposeAll()

    messenger = null
    state = null
    textureRegistry = null
    activityPluginBinding = null
    permissions = null
    mediaDevices = null
    peerConnectionFactory = null
    videoRendererFactory = null
  }

  override fun onAttachedToActivity(registrar: ActivityPluginBinding) {
    Log.i(TAG, "Attached to activity")

    activityPluginBinding = registrar
    permissions = Permissions(activityPluginBinding!!.activity)
    activityPluginBinding!!.addRequestPermissionsResultListener(permissions!!)
    mediaDevices = MediaDevicesController(messenger!!, state!!, permissions!!)
    peerConnectionFactory = PeerConnectionFactoryController(messenger!!, state!!, permissions!!)
    videoRendererFactory = VideoRendererFactoryController(messenger!!, textureRegistry!!)
  }

  override fun onDetachedFromActivityForConfigChanges() {}

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}

  override fun onDetachedFromActivity() {
    Log.i(TAG, "Detached from activity")

    ForegroundCallService.stop(state!!.context, permissions!!)
    activityPluginBinding!!.removeRequestPermissionsResultListener(permissions!!)
    activityPluginBinding = null
  }
}
