package com.cloudwebrtc.webrtc;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * WebrtcPlugin
 */
public class FlutterWebRTCPlugin implements MethodCallHandler {

  private final Registrar registrar;
  private final MethodChannel channel;

  /**
   * The implementation of {@code getUserMedia} extracted into a separate file
   * in order to reduce complexity and to (somewhat) separate concerns.
   */
  private final GetUserMediaImpl getUserMediaImpl;

  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "cloudwebrtc.com/WebRTC.Method");
    channel.setMethodCallHandler(new FlutterWebRTCPlugin(registrar,channel));
  }

  private FlutterWebRTCPlugin(Registrar registrar, MethodChannel channel) {
    this.registrar = registrar;
    this.channel = channel;
    //channel.invokeMethod("onMessage", message.getData());
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else {
      result.notImplemented();
    }
  }
}
