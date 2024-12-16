// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.cloudwebrtc.webrtc.video.camera;

import android.annotation.TargetApi;
import android.graphics.Rect;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CaptureRequest;
import android.hardware.camera2.params.MeteringRectangle;
import android.os.Build;
import android.util.Size;
import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import io.flutter.embedding.engine.systemchannels.PlatformChannel;
import java.util.Arrays;

/**
 * Utility class offering functions to calculate values regarding the camera boundaries.
 *
 * <p>The functions are used to calculate focus and exposure settings.
 */
public final class CameraRegionUtils {

  @NonNull
  public static Size getCameraBoundaries(
      @NonNull CameraCharacteristics cameraCharacteristics, @NonNull CaptureRequest.Builder requestBuilder) {
    if (SdkCapabilityChecker.supportsDistortionCorrection()
        && supportsDistortionCorrection(cameraCharacteristics)) {
      // Get the current distortion correction mode.
      Integer distortionCorrectionMode =
          requestBuilder.get(CaptureRequest.DISTORTION_CORRECTION_MODE);

      // Return the correct boundaries depending on the mode.
      android.graphics.Rect rect;
      if (distortionCorrectionMode == null
          || distortionCorrectionMode == CaptureRequest.DISTORTION_CORRECTION_MODE_OFF) {
        rect = getSensorInfoPreCorrectionActiveArraySize(cameraCharacteristics);
      } else {
        rect = getSensorInfoActiveArraySize(cameraCharacteristics);
      }

      return SizeFactory.create(rect.width(), rect.height());
    } else {
      // No distortion correction support.
      return getSensorInfoPixelArraySize(cameraCharacteristics);
    }
  }

  @TargetApi(Build.VERSION_CODES.P)
  private static boolean supportsDistortionCorrection(CameraCharacteristics cameraCharacteristics) {
    int[] availableDistortionCorrectionModes = getDistortionCorrectionAvailableModes(cameraCharacteristics);
    if (availableDistortionCorrectionModes == null) {
      availableDistortionCorrectionModes = new int[0];
    }
    long nonOffModesSupported =
            Arrays.stream(availableDistortionCorrectionModes)
                    .filter((value) -> value != CaptureRequest.DISTORTION_CORRECTION_MODE_OFF)
                    .count();
    return nonOffModesSupported > 0;
  }

  static public int[] getDistortionCorrectionAvailableModes(CameraCharacteristics cameraCharacteristics) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
      return cameraCharacteristics.get(CameraCharacteristics.DISTORTION_CORRECTION_AVAILABLE_MODES);
    }
    return null;
  }

  public static Rect getSensorInfoActiveArraySize(CameraCharacteristics cameraCharacteristics) {
    return cameraCharacteristics.get(CameraCharacteristics.SENSOR_INFO_ACTIVE_ARRAY_SIZE);
  }

  public static Size getSensorInfoPixelArraySize(CameraCharacteristics cameraCharacteristics) {
    return cameraCharacteristics.get(CameraCharacteristics.SENSOR_INFO_PIXEL_ARRAY_SIZE);
  }

  @NonNull
  public static Rect getSensorInfoPreCorrectionActiveArraySize(CameraCharacteristics cameraCharacteristics) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      return cameraCharacteristics.get(
              CameraCharacteristics.SENSOR_INFO_PRE_CORRECTION_ACTIVE_ARRAY_SIZE);
    }
    return getSensorInfoActiveArraySize(cameraCharacteristics);
  }

  public static Integer getControlMaxRegionsAutoExposure(CameraCharacteristics cameraCharacteristics) {
    return cameraCharacteristics.get(CameraCharacteristics.CONTROL_MAX_REGIONS_AE);
  }

  /**
   * Converts a point into a {@link MeteringRectangle} with the supplied coordinates as the center
   * point.
   *
   * <p>Since the Camera API (due to cross-platform constraints) only accepts a point when
   * configuring a specific focus or exposure area and Android requires a rectangle to configure
   * these settings there is a need to convert the point into a rectangle. This method will create
   * the required rectangle with an arbitrarily size that is a 10th of the current viewport and the
   * coordinates as the center point.
   *
   * @param boundaries - The camera boundaries to calculate the metering rectangle for.
   * @param x x - 1 >= coordinate >= 0.
   * @param y y - 1 >= coordinate >= 0.
   * @return The dimensions of the metering rectangle based on the supplied coordinates and
   *     boundaries.
   */
  @NonNull
  public static MeteringRectangle convertPointToMeteringRectangle(
      @NonNull Size boundaries,
      double x,
      double y,
      @NonNull PlatformChannel.DeviceOrientation orientation) {
    assert (boundaries.getWidth() > 0 && boundaries.getHeight() > 0);
    assert (x >= 0 && x <= 1);
    assert (y >= 0 && y <= 1);
    // Rotate the coordinates to match the device orientation.
    double oldX = x, oldY = y;
    switch (orientation) {
      case PORTRAIT_UP: // 90 ccw.
        y = 1 - oldX;
        x = oldY;
        break;
      case PORTRAIT_DOWN: // 90 cw.
        x = 1 - oldY;
        y = oldX;
        break;
      case LANDSCAPE_LEFT:
        // No rotation required.
        break;
      case LANDSCAPE_RIGHT: // 180.
        x = 1 - x;
        y = 1 - y;
        break;
    }
    // Interpolate the target coordinate.
    int targetX = (int) Math.round(x * ((double) (boundaries.getWidth() - 1)));
    int targetY = (int) Math.round(y * ((double) (boundaries.getHeight() - 1)));
    // Determine the dimensions of the metering rectangle (10th of the viewport).
    int targetWidth = (int) Math.round(((double) boundaries.getWidth()) / 10d);
    int targetHeight = (int) Math.round(((double) boundaries.getHeight()) / 10d);
    // Adjust target coordinate to represent top-left corner of metering rectangle.
    targetX -= targetWidth / 2;
    targetY -= targetHeight / 2;
    // Adjust target coordinate as to not fall out of bounds.
    if (targetX < 0) {
      targetX = 0;
    }
    if (targetY < 0) {
      targetY = 0;
    }
    int maxTargetX = boundaries.getWidth() - 1 - targetWidth;
    int maxTargetY = boundaries.getHeight() - 1 - targetHeight;
    if (targetX > maxTargetX) {
      targetX = maxTargetX;
    }
    if (targetY > maxTargetY) {
      targetY = maxTargetY;
    }
    // Build the metering rectangle.
    return MeteringRectangleFactory.create(targetX, targetY, targetWidth, targetHeight, 1);
  }

  /** Factory class that assists in creating a {@link MeteringRectangle} instance. */
  static class MeteringRectangleFactory {
    /**
     * Creates a new instance of the {@link MeteringRectangle} class.
     *
     * <p>This method is visible for testing purposes only and should never be used outside this *
     * class.
     *
     * @param x coordinate >= 0.
     * @param y coordinate >= 0.
     * @param width width >= 0.
     * @param height height >= 0.
     * @param meteringWeight weight between {@value MeteringRectangle#METERING_WEIGHT_MIN} and
     *     {@value MeteringRectangle#METERING_WEIGHT_MAX} inclusively.
     * @return new instance of the {@link MeteringRectangle} class.
     * @throws IllegalArgumentException if any of the parameters were negative.
     */
    @VisibleForTesting
    public static MeteringRectangle create(
        int x, int y, int width, int height, int meteringWeight) {
      return new MeteringRectangle(x, y, width, height, meteringWeight);
    }
  }

  /** Factory class that assists in creating a {@link Size} instance. */
  static class SizeFactory {
    /**
     * Creates a new instance of the {@link Size} class.
     *
     * <p>This method is visible for testing purposes only and should never be used outside this *
     * class.
     *
     * @param width width >= 0.
     * @param height height >= 0.
     * @return new instance of the {@link Size} class.
     */
    @VisibleForTesting
    public static Size create(int width, int height) {
      return new Size(width, height);
    }
  }
}
