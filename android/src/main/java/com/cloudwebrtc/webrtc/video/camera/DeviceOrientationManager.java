package com.cloudwebrtc.webrtc.video.camera;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.res.Configuration;
import android.view.Display;
import android.view.Surface;
import android.view.WindowManager;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import io.flutter.embedding.engine.systemchannels.PlatformChannel;
import io.flutter.embedding.engine.systemchannels.PlatformChannel.DeviceOrientation;

/**
 * Support class to help to determine the media orientation based on the orientation of the device.
 */
public class DeviceOrientationManager {

  private static final IntentFilter orientationIntentFilter =
      new IntentFilter(Intent.ACTION_CONFIGURATION_CHANGED);

  private final Activity activity;
  private final int sensorOrientation;
  private PlatformChannel.DeviceOrientation lastOrientation;
  private BroadcastReceiver broadcastReceiver;

  /** Factory method to create a device orientation manager. */
  @NonNull
  public static DeviceOrientationManager create(
      @NonNull Activity activity,
      int sensorOrientation) {
    return new DeviceOrientationManager(activity, sensorOrientation);
  }

  DeviceOrientationManager(
          @NonNull Activity activity,
          int sensorOrientation) {
    this.activity = activity;
    this.sensorOrientation = sensorOrientation;
  }

  public void start() {
    if (broadcastReceiver != null) {
      return;
    }
    broadcastReceiver =
        new BroadcastReceiver() {
          @Override
          public void onReceive(Context context, Intent intent) {
            handleUIOrientationChange();
          }
        };
    activity.registerReceiver(broadcastReceiver, orientationIntentFilter);
    broadcastReceiver.onReceive(activity, null);
  }

  /** Stops listening for orientation updates. */
  public void stop() {
    if (broadcastReceiver == null) {
      return;
    }
    activity.unregisterReceiver(broadcastReceiver);
    broadcastReceiver = null;
  }


  /** @return the last received UI orientation. */
  @Nullable
  public PlatformChannel.DeviceOrientation getLastUIOrientation() {
    return this.lastOrientation;
  }

  /**
   * Handles orientation changes based on change events triggered by the OrientationIntentFilter.
   *
   * <p>This method is visible for testing purposes only and should never be used outside this
   * class.
   */
  @VisibleForTesting
  void handleUIOrientationChange() {
    PlatformChannel.DeviceOrientation orientation = getUIOrientation();
    handleOrientationChange(orientation, lastOrientation);
    lastOrientation = orientation;
  }
  @VisibleForTesting
  static void handleOrientationChange(
      DeviceOrientation newOrientation,
      DeviceOrientation previousOrientation) {
  }

  @SuppressWarnings("deprecation")
  @VisibleForTesting
  PlatformChannel.DeviceOrientation getUIOrientation() {
    final int rotation = getDisplay().getRotation();
    final int orientation = activity.getResources().getConfiguration().orientation;

    switch (orientation) {
      case Configuration.ORIENTATION_PORTRAIT:
        if (rotation == Surface.ROTATION_0 || rotation == Surface.ROTATION_90) {
          return PlatformChannel.DeviceOrientation.PORTRAIT_UP;
        } else {
          return PlatformChannel.DeviceOrientation.PORTRAIT_DOWN;
        }
      case Configuration.ORIENTATION_LANDSCAPE:
        if (rotation == Surface.ROTATION_0 || rotation == Surface.ROTATION_90) {
          return PlatformChannel.DeviceOrientation.LANDSCAPE_LEFT;
        } else {
          return PlatformChannel.DeviceOrientation.LANDSCAPE_RIGHT;
        }
      case Configuration.ORIENTATION_SQUARE:
      case Configuration.ORIENTATION_UNDEFINED:
      default:
        return PlatformChannel.DeviceOrientation.PORTRAIT_UP;
    }
  }

  /**
   * Calculates the sensor orientation based on the supplied angle.
   *
   * <p>This method is visible for testing purposes only and should never be used outside this
   * class.
   *
   * @param angle Orientation angle.
   * @return The sensor orientation based on the supplied angle.
   */
  @VisibleForTesting
  PlatformChannel.DeviceOrientation calculateSensorOrientation(int angle) {
    final int tolerance = 45;
    angle += tolerance;

    // Orientation is 0 in the default orientation mode. This is portrait-mode for phones
    // and landscape for tablets. We have to compensate for this by calculating the default
    // orientation, and apply an offset accordingly.
    int defaultDeviceOrientation = getDeviceDefaultOrientation();
    if (defaultDeviceOrientation == Configuration.ORIENTATION_LANDSCAPE) {
      angle += 90;
    }
    // Determine the orientation
    angle = angle % 360;
    return new PlatformChannel.DeviceOrientation[] {
          PlatformChannel.DeviceOrientation.PORTRAIT_UP,
          PlatformChannel.DeviceOrientation.LANDSCAPE_LEFT,
          PlatformChannel.DeviceOrientation.PORTRAIT_DOWN,
          PlatformChannel.DeviceOrientation.LANDSCAPE_RIGHT,
        }
        [angle / 90];
  }

  /**
   * Gets the default orientation of the device.
   *
   * <p>This method is visible for testing purposes only and should never be used outside this
   * class.
   *
   * @return The default orientation of the device.
   */
  @VisibleForTesting
  int getDeviceDefaultOrientation() {
    Configuration config = activity.getResources().getConfiguration();
    int rotation = getDisplay().getRotation();
    if (((rotation == Surface.ROTATION_0 || rotation == Surface.ROTATION_180)
            && config.orientation == Configuration.ORIENTATION_LANDSCAPE)
        || ((rotation == Surface.ROTATION_90 || rotation == Surface.ROTATION_270)
            && config.orientation == Configuration.ORIENTATION_PORTRAIT)) {
      return Configuration.ORIENTATION_LANDSCAPE;
    } else {
      return Configuration.ORIENTATION_PORTRAIT;
    }
  }

  /**
   * Gets an instance of the Android {@link android.view.Display}.
   *
   * <p>This method is visible for testing purposes only and should never be used outside this
   * class.
   *
   * @return An instance of the Android {@link android.view.Display}.
   */
  @SuppressWarnings("deprecation")
  @VisibleForTesting
  Display getDisplay() {
    return ((WindowManager) activity.getSystemService(Context.WINDOW_SERVICE)).getDefaultDisplay();
  }
}
