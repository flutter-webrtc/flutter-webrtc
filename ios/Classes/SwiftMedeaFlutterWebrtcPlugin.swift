import AVFoundation
import Flutter
import UIKit
import WebRTC

/// Representation of a `medea_flutter_webrtc` plugin.
public class SwiftMedeaFlutterWebrtcPlugin: NSObject, FlutterPlugin {
  var messenger: FlutterBinaryMessenger
  var peerConnectionFactory: PeerConnectionFactoryController
  var mediaDevices: MediaDevicesController
  var videoRendererFactory: VideoRendererFactoryController
  var textures: FlutterTextureRegistry
  var state: State

  /// Initializes a new `SwiftMedeaFlutterWebrtcPlugin` with the provided
  /// parameters.
  init(messenger: FlutterBinaryMessenger, textures: FlutterTextureRegistry) {
    // Uncomment the underlying line for `libwebrtc` debug logs:
    // RTCSetMinDebugLogLevel(RTCLoggingSeverity.verbose)
    self.state = State()
    self.messenger = messenger
    self.textures = textures
    self.peerConnectionFactory = PeerConnectionFactoryController(
      messenger: self.messenger, state: self.state
    )
    self.mediaDevices = MediaDevicesController(
      messenger: self.messenger, mediaDevices: MediaDevices(state: self.state)
    )
    self.videoRendererFactory = VideoRendererFactoryController(
      messenger: self.messenger, registry: self.textures
    )
  }

  /// Registers this `SwiftMedeaFlutterWebrtcPlugin` in the provided
  /// `FlutterPluginRegistrar`.
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "medea_flutter_webrtc", binaryMessenger: registrar.messenger()
    )
    let instance = SwiftMedeaFlutterWebrtcPlugin(
      messenger: registrar.messenger(), textures: registrar.textures()
    )
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  /// Handles the provided `FlutterMethodCall`.
  public func handle(_: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
