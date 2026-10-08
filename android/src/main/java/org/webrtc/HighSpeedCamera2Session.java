/*
 * Copyright 2026 The livekit-app authors.
 *
 * Licensed under the BSD-style license used by the WebRTC project.
 */
package org.webrtc;

import android.annotation.SuppressLint;
import android.content.Context;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCaptureSession;
import android.hardware.camera2.CaptureResult;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraConstrainedHighSpeedCaptureSession;
import android.hardware.camera2.CameraDevice;
import android.hardware.camera2.CameraManager;
import android.hardware.camera2.CameraMetadata;
import android.hardware.camera2.TotalCaptureResult;
import android.hardware.camera2.CaptureFailure;
import android.hardware.camera2.CaptureRequest;
import android.hardware.camera2.params.StreamConfigurationMap;
import android.os.Handler;
import android.os.HandlerThread;
import android.util.Range;
import android.util.Size;
import android.view.Surface;
import androidx.annotation.Nullable;
import java.util.Arrays;
import java.util.Comparator;

/** A WebRTC CameraSession using Android's constrained high-speed Camera2 path. */
final class HighSpeedCamera2Session implements CameraSession {
  private static final String TAG = "HighSpeedCamera2";

  private enum SessionState {
    RUNNING,
    STOPPED
  }

  private final Handler cameraThreadHandler;
  private final CreateSessionCallback callback;
  private final Events events;
  private final Context applicationContext;
  private final CameraManager cameraManager;
  private final SurfaceTextureHelper surfaceTextureHelper;
  private final String cameraId;
  private final int requestedWidth;
  private final int requestedHeight;
  private final int requestedFramerate;

  private CameraCharacteristics cameraCharacteristics;
  private int cameraOrientation;
  private boolean isCameraFrontFacing;
  private Size captureSize;
  private Range<Integer> captureFpsRange;
  @Nullable private CameraDevice cameraDevice;
  @Nullable private Surface surface;
  @Nullable private CameraCaptureSession captureSession;
  @Nullable private HandlerThread captureCallbackThread;
  private SessionState state = SessionState.RUNNING;
  private boolean firstFrameReported;

  static void create(
      CreateSessionCallback callback,
      Events events,
      Context applicationContext,
      CameraManager cameraManager,
      SurfaceTextureHelper surfaceTextureHelper,
      String cameraId,
      int width,
      int height,
      int framerate) {
    new HighSpeedCamera2Session(
        callback,
        events,
        applicationContext,
        cameraManager,
        surfaceTextureHelper,
        cameraId,
        width,
        height,
        framerate);
  }

  private HighSpeedCamera2Session(
      CreateSessionCallback callback,
      Events events,
      Context applicationContext,
      CameraManager cameraManager,
      SurfaceTextureHelper surfaceTextureHelper,
      String cameraId,
      int width,
      int height,
      int framerate) {
    Logging.d(
        TAG,
        "Create session camera="
            + cameraId
            + " requested="
            + width
            + "x"
            + height
            + "@"
            + framerate);
    this.cameraThreadHandler = surfaceTextureHelper.getHandler();
    this.callback = callback;
    this.events = events;
    this.applicationContext = applicationContext;
    this.cameraManager = cameraManager;
    this.surfaceTextureHelper = surfaceTextureHelper;
    this.cameraId = cameraId;
    this.requestedWidth = width;
    this.requestedHeight = height;
    this.requestedFramerate = framerate;
    start();
  }

  private void start() {
    checkIsOnCameraThread();
    try {
      cameraCharacteristics = cameraManager.getCameraCharacteristics(cameraId);
      cameraOrientation = cameraCharacteristics.get(CameraCharacteristics.SENSOR_ORIENTATION);
      isCameraFrontFacing =
          cameraCharacteristics.get(CameraCharacteristics.LENS_FACING)
              == CameraMetadata.LENS_FACING_FRONT;
      selectCaptureFormat();
      openCamera();
    } catch (CameraAccessException | IllegalArgumentException | NullPointerException error) {
      reportError("Unable to prepare high-speed camera: " + error);
    }
  }

  private void selectCaptureFormat() {
    StreamConfigurationMap map =
        cameraCharacteristics.get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP);
    if (map == null) {
      throw new IllegalArgumentException("Camera has no stream configuration map");
    }

    captureSize =
        Arrays.stream(map.getHighSpeedVideoSizes())
            .filter(
                size ->
                    size.getWidth() == requestedWidth && size.getHeight() == requestedHeight)
            .findFirst()
            .orElseThrow(
                () ->
                    new IllegalArgumentException(
                        "High-speed size not supported: "
                            + requestedWidth
                            + "x"
                            + requestedHeight));

    captureFpsRange =
        Arrays.stream(map.getHighSpeedVideoFpsRangesFor(captureSize))
            .filter(
                range ->
                    range.getLower() <= requestedFramerate
                        && range.getUpper() >= requestedFramerate)
            .min(
                Comparator.<Range<Integer>>comparingInt(
                        range -> range.getUpper() - requestedFramerate)
                    .thenComparingInt(range -> requestedFramerate - range.getLower()))
            .orElseThrow(
                () ->
                    new IllegalArgumentException(
                        "No high-speed FPS range contains " + requestedFramerate));

    Logging.d(
        TAG,
        "Using high-speed format "
            + captureSize.getWidth()
            + "x"
            + captureSize.getHeight()
            + " range="
            + captureFpsRange);
  }

  @SuppressLint("MissingPermission")
  private void openCamera() throws CameraAccessException {
    events.onCameraOpening();
    cameraManager.openCamera(cameraId, new CameraStateCallback(), cameraThreadHandler);
  }

  private final class CameraStateCallback extends CameraDevice.StateCallback {
    @Override
    public void onDisconnected(CameraDevice camera) {
      checkIsOnCameraThread();
      boolean startFailure = captureSession == null && state != SessionState.STOPPED;
      state = SessionState.STOPPED;
      stopInternal();
      if (startFailure) {
        callback.onFailure(FailureType.DISCONNECTED, "High-speed camera disconnected");
      } else {
        events.onCameraDisconnected(HighSpeedCamera2Session.this);
      }
    }

    @Override
    public void onError(CameraDevice camera, int errorCode) {
      checkIsOnCameraThread();
      reportError("CameraDevice error " + errorCode);
    }

    @Override
    public void onOpened(CameraDevice camera) {
      checkIsOnCameraThread();
      cameraDevice = camera;
      surfaceTextureHelper.setTextureSize(captureSize.getWidth(), captureSize.getHeight());
      surface = new Surface(surfaceTextureHelper.getSurfaceTexture());
      try {
        // Deprecated only in favour of SessionConfiguration; it remains the compatible API from
        // Android 6 through current Android releases.
        camera.createConstrainedHighSpeedCaptureSession(
            Arrays.asList(surface), new CaptureSessionCallback(), cameraThreadHandler);
      } catch (CameraAccessException | IllegalArgumentException error) {
        reportError("Failed to create constrained high-speed session: " + error);
      }
    }

    @Override
    public void onClosed(CameraDevice camera) {
      checkIsOnCameraThread();
      events.onCameraClosed(HighSpeedCamera2Session.this);
    }
  }

  private final class CaptureSessionCallback extends CameraCaptureSession.StateCallback {
    @Override
    public void onConfigureFailed(CameraCaptureSession session) {
      checkIsOnCameraThread();
      session.close();
      reportError("Failed to configure constrained high-speed session");
    }

    @Override
    public void onConfigured(CameraCaptureSession session) {
      checkIsOnCameraThread();
      if (!(session instanceof CameraConstrainedHighSpeedCaptureSession)) {
        session.close();
        reportError("Camera returned a non-high-speed session");
        return;
      }
      captureSession = session;
      try {
        CaptureRequest.Builder requestBuilder =
            cameraDevice.createCaptureRequest(CameraDevice.TEMPLATE_RECORD);
        requestBuilder.set(CaptureRequest.CONTROL_AE_TARGET_FPS_RANGE, captureFpsRange);
        requestBuilder.set(CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON);
        requestBuilder.set(CaptureRequest.CONTROL_AE_LOCK, false);
        chooseFocusMode(requestBuilder);
        requestBuilder.addTarget(surface);

        CameraConstrainedHighSpeedCaptureSession highSpeedSession =
            (CameraConstrainedHighSpeedCaptureSession) session;
        HighSpeedCamera2Capturer.beginDiagnostics(
            cameraId,
            captureSize.getWidth(),
            captureSize.getHeight(),
            captureFpsRange);
        // Keep high-rate capture results off the SurfaceTexture/WebRTC GL handler so callbacks
        // cannot starve texture consumption and create camera backpressure.
        captureCallbackThread = new HandlerThread("HighSpeedCameraResults");
        captureCallbackThread.start();
        Handler captureCallbackHandler = new Handler(captureCallbackThread.getLooper());
        highSpeedSession.setRepeatingBurst(
            highSpeedSession.createHighSpeedRequestList(requestBuilder.build()),
            new CameraCaptureCallback(),
            captureCallbackHandler);
      } catch (CameraAccessException | IllegalArgumentException | IllegalStateException error) {
        reportError("Failed to start high-speed request burst: " + error);
        return;
      }

      surfaceTextureHelper.startListening(
          frame -> {
            checkIsOnCameraThread();
            if (state != SessionState.RUNNING) {
              return;
            }
            if (!firstFrameReported) {
              firstFrameReported = true;
              Logging.d(TAG, "First high-speed frame received");
            }
            HighSpeedCamera2Capturer.recordTextureFrame();
            VideoFrame modifiedFrame =
                new VideoFrame(
                    CameraSession.createTextureBufferWithModifiedTransformMatrix(
                        (TextureBufferImpl) frame.getBuffer(),
                        isCameraFrontFacing,
                        -cameraOrientation),
                    getFrameOrientation(),
                    frame.getTimestampNs());
            events.onFrameCaptured(HighSpeedCamera2Session.this, modifiedFrame);
            modifiedFrame.release();
          });
      Logging.d(TAG, "Constrained high-speed camera started successfully");
      callback.onDone(HighSpeedCamera2Session.this);
    }
  }

  private void chooseFocusMode(CaptureRequest.Builder requestBuilder) {
    int[] modes =
        cameraCharacteristics.get(CameraCharacteristics.CONTROL_AF_AVAILABLE_MODES);
    if (modes == null) {
      return;
    }
    for (int mode : modes) {
      if (mode == CaptureRequest.CONTROL_AF_MODE_CONTINUOUS_VIDEO) {
        requestBuilder.set(CaptureRequest.CONTROL_AF_MODE, mode);
        return;
      }
    }
  }

  private static final class CameraCaptureCallback
      extends CameraCaptureSession.CaptureCallback {
    @Override
    public void onCaptureCompleted(
        CameraCaptureSession session, CaptureRequest request, TotalCaptureResult result) {
      Long sensorTimestampNs = result.get(CaptureResult.SENSOR_TIMESTAMP);
      HighSpeedCamera2Capturer.recordSensorFrame(
          sensorTimestampNs == null ? 0L : sensorTimestampNs);
    }

    @Override
    public void onCaptureFailed(
        CameraCaptureSession session, CaptureRequest request, CaptureFailure failure) {
      Logging.w(TAG, "High-speed capture failed: " + failure);
    }
  }

  @Override
  public void stop() {
    checkIsOnCameraThread();
    if (state == SessionState.STOPPED) {
      return;
    }
    state = SessionState.STOPPED;
    stopInternal();
  }

  private void stopInternal() {
    checkIsOnCameraThread();
    HighSpeedCamera2Capturer.endDiagnostics();
    surfaceTextureHelper.stopListening();
    if (captureSession != null) {
      captureSession.close();
      captureSession = null;
    }
    if (captureCallbackThread != null) {
      captureCallbackThread.quitSafely();
      captureCallbackThread = null;
    }
    if (surface != null) {
      surface.release();
      surface = null;
    }
    if (cameraDevice != null) {
      cameraDevice.close();
      cameraDevice = null;
    }
  }

  private void reportError(String error) {
    checkIsOnCameraThread();
    Logging.e(TAG, error);
    boolean startFailure = captureSession == null && state != SessionState.STOPPED;
    state = SessionState.STOPPED;
    stopInternal();
    if (startFailure) {
      callback.onFailure(FailureType.ERROR, error);
    } else {
      events.onCameraError(this, error);
    }
  }

  private int getFrameOrientation() {
    int rotation = CameraSession.getDeviceOrientation(applicationContext);
    if (!isCameraFrontFacing) {
      rotation = 360 - rotation;
    }
    return (cameraOrientation + rotation) % 360;
  }

  private void checkIsOnCameraThread() {
    if (Thread.currentThread() != cameraThreadHandler.getLooper().getThread()) {
      throw new IllegalStateException("Wrong camera thread");
    }
  }
}
