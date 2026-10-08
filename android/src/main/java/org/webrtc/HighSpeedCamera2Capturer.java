/*
 * Copyright 2026 The livekit-app authors.
 *
 * Licensed under the BSD-style license used by the WebRTC project.
 */
package org.webrtc;

import android.content.Context;
import android.hardware.camera2.CameraManager;
import android.hardware.camera2.params.StreamConfigurationMap;
import android.os.Build;
import android.os.SystemClock;
import android.util.Range;
import android.util.Size;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.atomic.AtomicLong;

/**
 * Camera2 capturer backed by a constrained high-speed capture session.
 *
 * <p>{@link Camera2Capturer} only enumerates normal Camera2 output formats. Many Android devices
 * expose 60fps and above exclusively through {@code getHighSpeedVideoFpsRangesFor}, so requesting
 * 60fps through the normal capturer silently produces 30fps. This capturer keeps WebRTC's existing
 * {@link CameraCapturer} lifecycle while replacing only the session implementation.
 */
public final class HighSpeedCamera2Capturer extends CameraCapturer {
  private final CameraManager cameraManager;

  // Keep the measurement in the native capture path. WebRTC stats only expose frames after the
  // source adapter, so they cannot distinguish Camera2, the SurfaceTexture bridge, and WebRTC.
  private static final AtomicLong sensorFrames = new AtomicLong();
  private static final AtomicLong firstSensorTimestampNs = new AtomicLong();
  private static final AtomicLong lastSensorTimestampNs = new AtomicLong();
  private static final AtomicLong textureFrames = new AtomicLong();
  private static volatile boolean diagnosticsActive;
  private static volatile long diagnosticsStartedNs;
  private static volatile String diagnosticsCameraId = "";
  private static volatile int diagnosticsWidth;
  private static volatile int diagnosticsHeight;
  private static volatile int diagnosticsRangeMin;
  private static volatile int diagnosticsRangeMax;

  public HighSpeedCamera2Capturer(
      Context context, String cameraName, CameraVideoCapturer.CameraEventsHandler eventsHandler) {
    super(cameraName, eventsHandler, new Camera2Enumerator(context));
    cameraManager = (CameraManager) context.getSystemService(Context.CAMERA_SERVICE);
  }

  @Override
  protected void createCameraSession(
      CameraSession.CreateSessionCallback createSessionCallback,
      CameraSession.Events events,
      Context applicationContext,
      SurfaceTextureHelper surfaceTextureHelper,
      String cameraName,
      int width,
      int height,
      int framerate) {
    HighSpeedCamera2Session.create(
        createSessionCallback,
        events,
        applicationContext,
        cameraManager,
        surfaceTextureHelper,
        cameraName,
        width,
        height,
        framerate);
  }

  public static boolean isSupported(
      Context context, String cameraId, int width, int height, int framerate) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M || framerate <= 30) {
      return false;
    }
    try {
      CameraManager manager = (CameraManager) context.getSystemService(Context.CAMERA_SERVICE);
      StreamConfigurationMap map =
          manager
              .getCameraCharacteristics(cameraId)
              .get(android.hardware.camera2.CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP);
      if (map == null || !Arrays.asList(map.getHighSpeedVideoSizes()).contains(new Size(width, height))) {
        return false;
      }
      for (Range<Integer> range : map.getHighSpeedVideoFpsRangesFor(new Size(width, height))) {
        if (range.getUpper() >= framerate && range.getLower() <= framerate) {
          return true;
        }
      }
    } catch (Exception ignored) {
      // The normal Camera2 capturer remains the safe fallback.
    }
    return false;
  }

  static void beginDiagnostics(
      String cameraId, int width, int height, Range<Integer> fpsRange) {
    diagnosticsCameraId = cameraId;
    diagnosticsWidth = width;
    diagnosticsHeight = height;
    diagnosticsRangeMin = fpsRange.getLower();
    diagnosticsRangeMax = fpsRange.getUpper();
    sensorFrames.set(0);
    firstSensorTimestampNs.set(0);
    lastSensorTimestampNs.set(0);
    textureFrames.set(0);
    diagnosticsStartedNs = SystemClock.elapsedRealtimeNanos();
    diagnosticsActive = true;
  }

  static void recordSensorFrame(long sensorTimestampNs) {
    if (diagnosticsActive) {
      sensorFrames.incrementAndGet();
      if (sensorTimestampNs > 0) {
        firstSensorTimestampNs.compareAndSet(0, sensorTimestampNs);
        lastSensorTimestampNs.set(sensorTimestampNs);
      }
    }
  }

  static void recordTextureFrame() {
    if (diagnosticsActive) {
      textureFrames.incrementAndGet();
    }
  }

  static void endDiagnostics() {
    diagnosticsActive = false;
  }

  /** Returns native capture counters for the app's live pipeline diagnostics. */
  public static Map<String, Object> getDiagnostics() {
    Map<String, Object> result = new HashMap<>();
    boolean active = diagnosticsActive;
    long elapsedNs = active
        ? Math.max(1L, SystemClock.elapsedRealtimeNanos() - diagnosticsStartedNs)
        : 0L;
    long sensorCount = sensorFrames.get();
    long textureCount = textureFrames.get();
    long firstSensorNs = firstSensorTimestampNs.get();
    long lastSensorNs = lastSensorTimestampNs.get();
    long sensorSpanNs = Math.max(0L, lastSensorNs - firstSensorNs);
    double sensorClockFps = sensorCount > 1 && sensorSpanNs > 0
        ? (sensorCount - 1) * 1_000_000_000.0 / sensorSpanNs
        : 0.0;
    result.put("active", active);
    result.put("cameraId", diagnosticsCameraId);
    result.put("width", diagnosticsWidth);
    result.put("height", diagnosticsHeight);
    result.put("rangeMin", diagnosticsRangeMin);
    result.put("rangeMax", diagnosticsRangeMax);
    result.put("elapsedMs", elapsedNs / 1_000_000L);
    result.put("sensorFrames", sensorCount);
    result.put("textureFrames", textureCount);
    result.put("sensorFps", active ? sensorClockFps : 0.0);
    result.put(
        "sensorCallbackFps", active ? sensorCount * 1_000_000_000.0 / elapsedNs : 0.0);
    result.put("textureFps", active ? textureCount * 1_000_000_000.0 / elapsedNs : 0.0);
    return result;
  }
}
