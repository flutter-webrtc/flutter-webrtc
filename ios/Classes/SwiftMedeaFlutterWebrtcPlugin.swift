import Flutter
import UIKit

public class SwiftMedeaFlutterWebrtcPluginn: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "medea_flutter_webrtc", binaryMessenger: registrar.messenger())
    let instance = SwiftMedeaFlutterWebrtcPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
