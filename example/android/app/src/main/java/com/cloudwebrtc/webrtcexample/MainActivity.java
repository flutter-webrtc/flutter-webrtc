package com.cloudwebrtc.webrtcexample;

import android.os.Bundle;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import com.cloudwebrtc.webrtc.FlutterWebRTCPlugin;

public class MainActivity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    FlutterWebRTCPlugin.registerWith(this.registrarFor("com.cloudwebrtc.webrtc.FlutterWebRTCPlugin"));
  }
}
