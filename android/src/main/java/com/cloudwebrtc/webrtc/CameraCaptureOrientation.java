package com.cloudwebrtc.webrtc;

import android.content.Context;
import android.graphics.Point;
import android.hardware.Camera;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraManager;
import android.os.Build;
import android.util.Log;
import android.view.Display;
import android.view.Surface;
import android.view.WindowManager;
import androidx.annotation.Nullable;
import org.webrtc.Camera1Enumerator;
import org.webrtc.Camera1Helper;
import org.webrtc.CameraEnumerator;
import org.webrtc.CapturerObserver;
import org.webrtc.VideoFrame;

/** Applies the selected device orientation before WebRTC adapts the camera frame. */
final class CameraCaptureOrientation implements CapturerObserver {
  private static final int FOLLOW_DEVICE = -1;
  private final CapturerObserver downstream;
  @Nullable private Mount mount;
  private int deviceDegrees = FOLLOW_DEVICE;
  // Configuration changes on the platform/camera threads; frame delivery only needs one read.
  private volatile int frameDegrees = FOLLOW_DEVICE;

  CameraCaptureOrientation(CapturerObserver downstream) {
    this.downstream = downstream;
  }

  synchronized void setMount(@Nullable Mount mount) {
    this.mount = mount;
    updateFrameDegrees();
  }

  synchronized void setOrientation(@Nullable String orientation, boolean landscapeNative) {
    if (orientation == null) {
      deviceDegrees = FOLLOW_DEVICE;
    } else {
      int fromPortrait;
      switch (orientation) {
        case "portraitUp": fromPortrait = 0; break;
        case "landscapeLeft": fromPortrait = 90; break;
        case "portraitDown": fromPortrait = 180; break;
        case "landscapeRight": fromPortrait = 270; break;
        default: throw new IllegalArgumentException("Unknown camera orientation: " + orientation);
      }
      if (mount == null) throw new IllegalStateException("Camera sensor orientation unavailable");
      // Surface.ROTATION_0 is landscapeLeft on naturally landscape devices.
      deviceDegrees = (fromPortrait + (landscapeNative ? 270 : 0)) % 360;
    }
    updateFrameDegrees();
  }

  private void updateFrameDegrees() {
    // Match Camera1Session/Camera2Session with a fixed device orientation.
    if (deviceDegrees == FOLLOW_DEVICE || mount == null) {
      frameDegrees = FOLLOW_DEVICE;
      return;
    }
    int deviceCorrection = mount.frontFacing ? deviceDegrees : 360 - deviceDegrees;
    frameDegrees = (mount.sensorDegrees + deviceCorrection) % 360;
  }

  @Override
  public void onCapturerStarted(boolean success) {
    downstream.onCapturerStarted(success);
  }

  @Override
  public void onCapturerStopped() {
    downstream.onCapturerStopped();
  }

  @Override
  public void onFrameCaptured(VideoFrame frame) {
    int rotation = frameDegrees;
    if (rotation == FOLLOW_DEVICE || rotation == frame.getRotation()) {
      downstream.onFrameCaptured(frame);
      return;
    }
    VideoFrame.Buffer buffer = frame.getBuffer();
    buffer.retain();
    VideoFrame oriented = new VideoFrame(buffer, rotation, frame.getTimestampNs());
    try {
      downstream.onFrameCaptured(oriented);
    } finally {
      oriented.release();
    }
  }

  @SuppressWarnings("deprecation")
  static boolean isLandscapeNative(Context context) {
    Display display = ((WindowManager) context.getSystemService(Context.WINDOW_SERVICE))
        .getDefaultDisplay();
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      Display.Mode mode = display.getMode();
      return mode.getPhysicalWidth() > mode.getPhysicalHeight();
    }
    Point size = new Point();
    display.getRealSize(size);
    int rotation = display.getRotation();
    boolean quarterTurn = rotation == Surface.ROTATION_90 || rotation == Surface.ROTATION_270;
    return quarterTurn ? size.y > size.x : size.x > size.y;
  }

  static final class Mount {
    final int sensorDegrees;
    final boolean frontFacing;

    Mount(int sensorDegrees, boolean frontFacing) {
      this.sensorDegrees = sensorDegrees;
      this.frontFacing = frontFacing;
    }

    @Nullable
    @SuppressWarnings("deprecation")
    static Mount read(Context context, CameraEnumerator enumerator, String name) {
      try {
        if (enumerator instanceof Camera1Enumerator) {
          Camera.CameraInfo info = new Camera.CameraInfo();
          Camera.getCameraInfo(Camera1Helper.getCameraId(name), info);
          return new Mount(info.orientation, info.facing == Camera.CameraInfo.CAMERA_FACING_FRONT);
        }
        CameraManager manager = (CameraManager) context.getSystemService(Context.CAMERA_SERVICE);
        CameraCharacteristics camera = manager.getCameraCharacteristics(name);
        Integer sensor = camera.get(CameraCharacteristics.SENSOR_ORIENTATION);
        Integer facing = camera.get(CameraCharacteristics.LENS_FACING);
        if (sensor != null && facing != null) {
          return new Mount(sensor, facing == CameraCharacteristics.LENS_FACING_FRONT);
        }
      } catch (CameraAccessException | RuntimeException e) {
        Log.w(GetUserMediaImpl.TAG, "Cannot read camera orientation for " + name, e);
      }
      return null;
    }
  }
}
