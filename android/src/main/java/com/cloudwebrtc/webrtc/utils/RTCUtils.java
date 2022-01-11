/*
 *  Copyright 2014 The WebRTC Project Authors. All rights reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

package com.cloudwebrtc.webrtc.utils;

import android.os.Build;
import android.util.Log;
import androidx.annotation.NonNull;
import java.lang.reflect.Field;
import org.webrtc.AudioTrack;
import org.webrtc.MediaStreamTrack;
import org.webrtc.VideoTrack;

/** RTCUtils provides helper functions for managing thread safety. */
public final class RTCUtils {
  private RTCUtils() {}

  /** Helper method which throws an exception when an assertion has failed. */
  public static void assertIsTrue(boolean condition) {
    if (!condition) {
      throw new AssertionError("Expected condition to be true");
    }
  }

  /** Helper method for building a string of thread information. */
  @NonNull
  public static String getThreadInfo() {
    return "@[name="
        + Thread.currentThread().getName()
        + ", id="
        + Thread.currentThread().getId()
        + "]";
  }

  /**
   * Helper method for cloning MediaStreamTrack by using Java reflection.
   *
   * @param track MediaStreamTrack which should be cloned
   * @return clone of the provided MediaStreamTrack
   */
  @NonNull
  public static MediaStreamTrack cloneMediaStreamTrack(@NonNull MediaStreamTrack track) {
    long nativeTrackAddress;
    try {
      Class<?> trackClass = track.getClass().getSuperclass();
      if (trackClass != MediaStreamTrack.class) {
        throw new IllegalArgumentException(
            "You're trying to clone MediaStreamTrack, but provided object is not child of"
                + " MediaStreamTrack");
      }

      Field nativeTrackField = trackClass.getDeclaredField("nativeTrack");
      nativeTrackField.setAccessible(true);
      nativeTrackAddress = nativeTrackField.getLong(track);
    } catch (@NonNull NoSuchFieldException | IllegalAccessException e) {
      throw new RuntimeException("Failed to get nativeTrack field from MediaStreamTrack: " + e);
    }

    if (track instanceof AudioTrack) {
      return new AudioTrack(nativeTrackAddress);
    } else if (track instanceof VideoTrack) {
      return new VideoTrack(nativeTrackAddress);
    } else {
      throw new RuntimeException("Provided MediaStreamTrack with an unknown kind");
    }
  }

  /** Information about the current build, taken from system properties. */
  public static void logDeviceInfo(String tag) {
    Log.d(
        tag,
        "Android SDK: "
            + Build.VERSION.SDK_INT
            + ", Release: "
            + Build.VERSION.RELEASE
            + ", Brand: "
            + Build.BRAND
            + ", Device: "
            + Build.DEVICE
            + ", Id: "
            + Build.ID
            + ", Hardware: "
            + Build.HARDWARE
            + ", Manufacturer: "
            + Build.MANUFACTURER
            + ", Model: "
            + Build.MODEL
            + ", Product: "
            + Build.PRODUCT);
  }
}
