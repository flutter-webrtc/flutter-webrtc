package com.cloudwebrtc.flutterflutterexample.flutter_webrtc_example;

import android.content.res.Configuration;

import androidx.annotation.NonNull;

import com.cloudwebrtc.webrtc.FlutterWebRTCPlugin;

import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
    @Override
    public void onUserLeaveHint() {
        super.onUserLeaveHint();
        FlutterWebRTCPlugin.onUserLeaveHint();
    }

    @Override
    public void onPictureInPictureModeChanged(boolean isInPictureInPictureMode,
                                              @NonNull Configuration newConfig) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig);
        FlutterWebRTCPlugin.onPictureInPictureModeChanged(isInPictureInPictureMode);
    }
}
