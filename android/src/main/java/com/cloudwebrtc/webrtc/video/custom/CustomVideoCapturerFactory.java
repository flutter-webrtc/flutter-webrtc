package com.cloudwebrtc.webrtc.video.custom;

import android.content.Context;

import java.util.Map;

/**
 * Creates a {@link CustomVideoCapturer} for a registered source type.
 * {@code options} is the (possibly empty) map passed from Dart as-is.
 */
public interface CustomVideoCapturerFactory {
    CustomVideoCapturer create(Context appContext, Map<String, Object> options);
}
