package com.cloudwebrtc.webrtc.video.camera;

import android.app.Activity;
import android.graphics.Rect;
import android.hardware.Camera;
import android.hardware.camera2.CameraCaptureSession;
import android.hardware.camera2.CameraDevice;
import android.hardware.camera2.CaptureRequest;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraManager;
import android.hardware.camera2.params.MeteringRectangle;
import android.os.Build;
import android.os.Handler;
import android.util.Log;
import android.util.Range;
import android.util.Size;
import android.view.Surface;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import com.cloudwebrtc.webrtc.GetUserMediaImpl;
import com.cloudwebrtc.webrtc.utils.AnyThreadResult;
import com.cloudwebrtc.webrtc.video.VideoCapturerInfo;

import org.webrtc.Camera1Capturer;
import org.webrtc.Camera2Capturer;
import org.webrtc.CameraEnumerationAndroid;

import java.lang.reflect.Field;
import java.util.List;

import io.flutter.embedding.engine.systemchannels.PlatformChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class CameraUtils {
  private static final String TAG = "CameraUtils";
  Activity activity;
  private GetUserMediaImpl getUserMediaImpl;
  private boolean isTorchOn = false;
  private DeviceOrientationManager deviceOrientationManager;
  public CameraUtils(GetUserMediaImpl getUserMediaImpl, Activity activity) {
    this.getUserMediaImpl = getUserMediaImpl;
    this.activity = activity;
    this.deviceOrientationManager = new DeviceOrientationManager(activity, 0);
    // commented out because you cannot register a reciever when the app is terminated
    // because the activity is null?
    // this causes the call to break if the app is terminated
    // the manager seems to end up at handleOrientationChange which does not do
    // anything at the moment so this should be ok

    // TODO: get a proper fix at some point
    // this.deviceOrientationManager.start();
  }

  public void setFocusMode(MethodCall call, AnyThreadResult result) {
    String trackId = call.argument("trackId");
    String mode = call.argument("mode");
    VideoCapturerInfo info = getUserMediaImpl.getCapturerInfo(trackId);
    if (info == null) {
      resultError("setFocusMode", "Video capturer not found for id: " + trackId, result);
      return;
    }

    if (info.capturer instanceof Camera2Capturer) {
      CameraCaptureSession captureSession;
      CameraDevice cameraDevice;
      CameraEnumerationAndroid.CaptureFormat captureFormat;
      int fpsUnitFactor;
      Surface surface;
      Handler cameraThreadHandler;
      CameraManager manager;

      try {
        Object session =
                getPrivateProperty(
                        Camera2Capturer.class.getSuperclass(), info.capturer, "currentSession");
        manager =
                (CameraManager)
                        getPrivateProperty(Camera2Capturer.class, info.capturer, "cameraManager");
        captureSession =
                (CameraCaptureSession)
                        getPrivateProperty(session.getClass(), session, "captureSession");
        cameraDevice =
                (CameraDevice) getPrivateProperty(session.getClass(), session, "cameraDevice");
        captureFormat =
                (CameraEnumerationAndroid.CaptureFormat) getPrivateProperty(session.getClass(), session, "captureFormat");
        fpsUnitFactor = (int) getPrivateProperty(session.getClass(), session, "fpsUnitFactor");
        surface = (Surface) getPrivateProperty(session.getClass(), session, "surface");
        cameraThreadHandler =
                (Handler) getPrivateProperty(session.getClass(), session, "cameraThreadHandler");
      } catch (NoSuchFieldWithNameException e) {
        // Most likely the upstream Camera2Capturer class have changed
        resultError("setFocusMode", "[FocusMode] Failed to get `" + e.fieldName + "` from `" + e.className + "`", result);
        return;
      }

      try {
        final CaptureRequest.Builder captureRequestBuilder =
                cameraDevice.createCaptureRequest(CameraDevice.TEMPLATE_RECORD);
        switch (mode) {
          case "locked":
            // When locking the auto-focus the camera device should do a one-time focus and afterwards
            // set the auto-focus to idle. This is accomplished by setting the CONTROL_AF_MODE to
            // CONTROL_AF_MODE_AUTO.
            captureRequestBuilder.set(CaptureRequest.CONTROL_AF_MODE, CaptureRequest.CONTROL_AF_MODE_AUTO);
            break;
          case "auto":
            captureRequestBuilder.set(
                    CaptureRequest.CONTROL_AF_MODE,
                    CaptureRequest.CONTROL_AF_MODE_CONTINUOUS_VIDEO);
            break;
          default:
            break;
        }

        captureRequestBuilder.set(
                CaptureRequest.FLASH_MODE,
                isTorchOn ? CaptureRequest.FLASH_MODE_TORCH : CaptureRequest.FLASH_MODE_OFF);

        captureRequestBuilder.set(
                CaptureRequest.CONTROL_AE_TARGET_FPS_RANGE,
                new Range<>(
                        captureFormat.framerate.min / fpsUnitFactor,
                        captureFormat.framerate.max / fpsUnitFactor));

        //captureRequestBuilder.set(CaptureRequest.CONTROL_AE_LOCK, false);
        captureRequestBuilder.addTarget(surface);
        captureSession.setRepeatingRequest(
                captureRequestBuilder.build(), null, cameraThreadHandler);
      } catch (CameraAccessException e) {
        // Should never happen since we are already accessing the camera
        throw new RuntimeException(e);
      }


      result.success(null);
      return;
    }

    if (info.capturer instanceof Camera1Capturer) {
      Camera camera;
      try {
        Object session =
                getPrivateProperty(
                        Camera1Capturer.class.getSuperclass(), info.capturer, "currentSession");
        camera = (Camera) getPrivateProperty(session.getClass(), session, "camera");
      } catch (NoSuchFieldWithNameException e) {
        // Most likely the upstream Camera1Capturer class have changed
        resultError("setFocusMode", "[FocusMode] Failed to get `" + e.fieldName + "` from `" + e.className + "`", result);
        return;
      }

      Camera.Parameters params = camera.getParameters();
      params.setFlashMode(
              isTorchOn ? Camera.Parameters.FLASH_MODE_TORCH : Camera.Parameters.FLASH_MODE_OFF);
      if(!params.getSupportedFocusModes().isEmpty()) {
        switch (mode) {
          case "locked":
            params.setFocusMode(Camera.Parameters.FOCUS_MODE_FIXED);
            break;
          case "auto":
            params.setFocusMode(Camera.Parameters.FOCUS_MODE_AUTO);
            break;
          default:
            break;
        }
        result.success(null);
        return;
      }
    }
    resultError("setFocusMode", "[FocusMode] Video capturer not compatible", result);
  }

  public void setFocusPoint(MethodCall call, Point focusPoint, AnyThreadResult result) {
    String trackId = call.argument("trackId");
    String mode = call.argument("mode");
    VideoCapturerInfo info = getUserMediaImpl.getCapturerInfo(trackId);
    if (info == null) {
      resultError("setFocusMode", "Video capturer not found for id: " + trackId, result);
      return;
    }

    if (info.capturer instanceof Camera2Capturer) {
      CameraCaptureSession captureSession;
      CameraDevice cameraDevice;
      CameraEnumerationAndroid.CaptureFormat captureFormat;
      int fpsUnitFactor;
      Surface surface;
      Handler cameraThreadHandler;
      CameraManager manager;

      try {
        Object session =
                getPrivateProperty(
                        Camera2Capturer.class.getSuperclass(), info.capturer, "currentSession");
        manager =
                (CameraManager)
                        getPrivateProperty(Camera2Capturer.class, info.capturer, "cameraManager");
        captureSession =
                (CameraCaptureSession)
                        getPrivateProperty(session.getClass(), session, "captureSession");
        cameraDevice =
                (CameraDevice) getPrivateProperty(session.getClass(), session, "cameraDevice");
        captureFormat =
                (CameraEnumerationAndroid.CaptureFormat) getPrivateProperty(session.getClass(), session, "captureFormat");
        fpsUnitFactor = (int) getPrivateProperty(session.getClass(), session, "fpsUnitFactor");
        surface = (Surface) getPrivateProperty(session.getClass(), session, "surface");
        cameraThreadHandler =
                (Handler) getPrivateProperty(session.getClass(), session, "cameraThreadHandler");
      } catch (NoSuchFieldWithNameException e) {
        // Most likely the upstream Camera2Capturer class have changed
        resultError("setFocusMode", "[FocusMode] Failed to get `" + e.fieldName + "` from `" + e.className + "`", result);
        return;
      }

      try {
        final CameraCharacteristics cameraCharacteristics = manager.getCameraCharacteristics(cameraDevice.getId());
        final CaptureRequest.Builder captureRequestBuilder =
                cameraDevice.createCaptureRequest(CameraDevice.TEMPLATE_RECORD);
        MeteringRectangle focusRectangle = null;
        Size cameraBoundaries = CameraRegionUtils.getCameraBoundaries(cameraCharacteristics, captureRequestBuilder);
        PlatformChannel.DeviceOrientation orientation = deviceOrientationManager.getLastUIOrientation();
        focusRectangle =
                convertPointToMeteringRectangle(cameraBoundaries, focusPoint.x, focusPoint.y, orientation);

        captureRequestBuilder.set(
                CaptureRequest.CONTROL_AF_REGIONS,
                captureRequestBuilder == null ? null : new MeteringRectangle[] {focusRectangle});
        captureRequestBuilder.addTarget(surface);
        captureSession.setRepeatingRequest(
                captureRequestBuilder.build(), null, cameraThreadHandler);
      } catch (CameraAccessException e) {
        // Should never happen since we are already accessing the camera
        throw new RuntimeException(e);
      }


      result.success(null);
      return;
    }

    if (info.capturer instanceof Camera1Capturer) {
      Camera camera;
      try {
        Object session =
                getPrivateProperty(
                        Camera1Capturer.class.getSuperclass(), info.capturer, "currentSession");
        camera = (Camera) getPrivateProperty(session.getClass(), session, "camera");
      } catch (NoSuchFieldWithNameException e) {
        // Most likely the upstream Camera1Capturer class have changed
        resultError("setFocusMode", "[FocusMode] Failed to get `" + e.fieldName + "` from `" + e.className + "`", result);
        return;
      }

      Camera.Parameters params = camera.getParameters();
      params.setFlashMode(
              isTorchOn ? Camera.Parameters.FLASH_MODE_TORCH : Camera.Parameters.FLASH_MODE_OFF);
      params.setFocusAreas(null);

      result.success(null);
      return;
    }
    resultError("setFocusMode", "[FocusMode] Video capturer not compatible", result);
  }

  public void setExposureMode(MethodCall call, AnyThreadResult result) {}

  public void setExposurePoint(MethodCall call,Point exposurePoint,  AnyThreadResult result) {
    String trackId = call.argument("trackId");
    String mode = call.argument("mode");
    VideoCapturerInfo info = getUserMediaImpl.getCapturerInfo(trackId);
    if (info == null) {
      resultError("setExposurePoint", "Video capturer not found for id: " + trackId, result);
      return;
    }

    if (info.capturer instanceof Camera2Capturer) {
      CameraCaptureSession captureSession;
      CameraDevice cameraDevice;
      CameraEnumerationAndroid.CaptureFormat captureFormat;
      int fpsUnitFactor;
      Surface surface;
      Handler cameraThreadHandler;
      CameraManager manager;

      try {
        Object session =
                getPrivateProperty(
                        Camera2Capturer.class.getSuperclass(), info.capturer, "currentSession");
        manager =
                (CameraManager)
                        getPrivateProperty(Camera2Capturer.class, info.capturer, "cameraManager");
        captureSession =
                (CameraCaptureSession)
                        getPrivateProperty(session.getClass(), session, "captureSession");
        cameraDevice =
                (CameraDevice) getPrivateProperty(session.getClass(), session, "cameraDevice");
        captureFormat =
                (CameraEnumerationAndroid.CaptureFormat) getPrivateProperty(session.getClass(), session, "captureFormat");
        fpsUnitFactor = (int) getPrivateProperty(session.getClass(), session, "fpsUnitFactor");
        surface = (Surface) getPrivateProperty(session.getClass(), session, "surface");
        cameraThreadHandler =
                (Handler) getPrivateProperty(session.getClass(), session, "cameraThreadHandler");
      } catch (NoSuchFieldWithNameException e) {
        // Most likely the upstream Camera2Capturer class have changed
        resultError("setExposurePoint", "[setExposurePoint] Failed to get `" + e.fieldName + "` from `" + e.className + "`", result);
        return;
      }

      try {
        final CameraCharacteristics cameraCharacteristics = manager.getCameraCharacteristics(cameraDevice.getId());
        final CaptureRequest.Builder captureRequestBuilder =
                cameraDevice.createCaptureRequest(CameraDevice.TEMPLATE_RECORD);

        if(CameraRegionUtils.getControlMaxRegionsAutoExposure(cameraCharacteristics) <= 0) {
          resultError("setExposurePoint", "[setExposurePoint] Camera does not support auto exposure", result);
          return;
        }

        MeteringRectangle exposureRectangle = null;
        Size cameraBoundaries = CameraRegionUtils.getCameraBoundaries(cameraCharacteristics, captureRequestBuilder);
        PlatformChannel.DeviceOrientation orientation = deviceOrientationManager.getLastUIOrientation();
        exposureRectangle =
                convertPointToMeteringRectangle(cameraBoundaries, exposurePoint.x, exposurePoint.y, orientation);
        if (exposureRectangle != null) {
          captureRequestBuilder.set(
                  CaptureRequest.CONTROL_AE_REGIONS, new MeteringRectangle[] {exposureRectangle});
        } else {
          MeteringRectangle[] defaultRegions = captureRequestBuilder.get(CaptureRequest.CONTROL_AE_REGIONS);
          captureRequestBuilder.set(CaptureRequest.CONTROL_AE_REGIONS, defaultRegions);
        }

        captureRequestBuilder.addTarget(surface);
        captureSession.setRepeatingRequest(
                captureRequestBuilder.build(), null, cameraThreadHandler);
      } catch (CameraAccessException e) {
        // Should never happen since we are already accessing the camera
        throw new RuntimeException(e);
      }


      result.success(null);
      return;
    }

    if (info.capturer instanceof Camera1Capturer) {
      Camera camera;
      try {
        Object session =
                getPrivateProperty(
                        Camera1Capturer.class.getSuperclass(), info.capturer, "currentSession");
        camera = (Camera) getPrivateProperty(session.getClass(), session, "camera");
      } catch (NoSuchFieldWithNameException e) {
        // Most likely the upstream Camera1Capturer class have changed
        resultError("setFocusMode", "[FocusMode] Failed to get `" + e.fieldName + "` from `" + e.className + "`", result);
        return;
      }

      Camera.Parameters params = camera.getParameters();
      params.setFlashMode(
              isTorchOn ? Camera.Parameters.FLASH_MODE_TORCH : Camera.Parameters.FLASH_MODE_OFF);
      params.setFocusAreas(null);
    }
    resultError("setFocusMode", "[FocusMode] Video capturer not compatible", result);
  }

  public void hasTorch(String trackId, MethodChannel.Result result) {
    VideoCapturerInfo info = getUserMediaImpl.getCapturerInfo(trackId);
    if (info == null) {
      resultError("hasTorch", "Video capturer not found for id: " + trackId, result);
      return;
    }

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP && info.capturer instanceof Camera2Capturer) {
      CameraManager manager;
      CameraDevice cameraDevice;

      try {
        Object session =
                getPrivateProperty(
                        Camera2Capturer.class.getSuperclass(), info.capturer, "currentSession");
        manager =
                (CameraManager)
                        getPrivateProperty(Camera2Capturer.class, info.capturer, "cameraManager");
        cameraDevice =
                (CameraDevice) getPrivateProperty(session.getClass(), session, "cameraDevice");
      } catch (NoSuchFieldWithNameException e) {
        // Most likely the upstream Camera2Capturer class have changed
        resultError("hasTorch", "[TORCH] Failed to get `" + e.fieldName + "` from `" + e.className + "`", result);
        return;
      }

      boolean flashIsAvailable;
      try {
        CameraCharacteristics characteristics =
                manager.getCameraCharacteristics(cameraDevice.getId());
        flashIsAvailable = characteristics.get(CameraCharacteristics.FLASH_INFO_AVAILABLE);
      } catch (CameraAccessException e) {
        // Should never happen since we are already accessing the camera
        throw new RuntimeException(e);
      }

      result.success(flashIsAvailable);
      return;
    }

    if (info.capturer instanceof Camera1Capturer) {
      Camera camera;

      try {
        Object session =
                getPrivateProperty(
                        Camera1Capturer.class.getSuperclass(), info.capturer, "currentSession");
        camera = (Camera) getPrivateProperty(session.getClass(), session, "camera");
      } catch (NoSuchFieldWithNameException e) {
        // Most likely the upstream Camera1Capturer class have changed
        resultError("hasTorch", "[TORCH] Failed to get `" + e.fieldName + "` from `" + e.className + "`", result);
        return;
      }

      Camera.Parameters params = camera.getParameters();
      List<String> supportedModes = params.getSupportedFlashModes();

      result.success(
              supportedModes != null && supportedModes.contains(Camera.Parameters.FLASH_MODE_TORCH));
      return;
    }

    resultError("hasTorch", "[TORCH] Video capturer not compatible", result);
  }

  @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
  public void setZoom(String trackId, double zoomLevel, MethodChannel.Result result) {
    VideoCapturerInfo info = getUserMediaImpl.getCapturerInfo(trackId);
    if (info == null) {
      resultError("setZoom", "Video capturer not found for id: " + trackId, result);
      return;
    }

    if (info.capturer instanceof Camera2Capturer) {
      CameraCaptureSession captureSession;
      CameraDevice cameraDevice;
      CameraEnumerationAndroid.CaptureFormat captureFormat;
      int fpsUnitFactor;
      Surface surface;
      Handler cameraThreadHandler;
      CameraManager manager;

      try {
        Object session =
                getPrivateProperty(
                        Camera2Capturer.class.getSuperclass(), info.capturer, "currentSession");
        manager =
                (CameraManager)
                        getPrivateProperty(Camera2Capturer.class, info.capturer, "cameraManager");
        captureSession =
                (CameraCaptureSession)
                        getPrivateProperty(session.getClass(), session, "captureSession");
        cameraDevice =
                (CameraDevice) getPrivateProperty(session.getClass(), session, "cameraDevice");
        captureFormat =
                (CameraEnumerationAndroid.CaptureFormat) getPrivateProperty(session.getClass(), session, "captureFormat");
        fpsUnitFactor = (int) getPrivateProperty(session.getClass(), session, "fpsUnitFactor");
        surface = (Surface) getPrivateProperty(session.getClass(), session, "surface");
        cameraThreadHandler =
                (Handler) getPrivateProperty(session.getClass(), session, "cameraThreadHandler");
      } catch (NoSuchFieldWithNameException e) {
        // Most likely the upstream Camera2Capturer class have changed
        resultError("setZoom", "[ZOOM] Failed to get `" + e.fieldName + "` from `" + e.className + "`", result);
        return;
      }

      try {
        final CaptureRequest.Builder captureRequestBuilder =
                cameraDevice.createCaptureRequest(CameraDevice.TEMPLATE_RECORD);

        final CameraCharacteristics cameraCharacteristics = manager.getCameraCharacteristics(cameraDevice.getId());
        final Rect rect = cameraCharacteristics.get(CameraCharacteristics.SENSOR_INFO_ACTIVE_ARRAY_SIZE);
        final double maxZoomLevel = cameraCharacteristics.get(CameraCharacteristics.SCALER_AVAILABLE_MAX_DIGITAL_ZOOM);

        final double desiredZoomLevel = Math.max(1.0, Math.min(zoomLevel, maxZoomLevel));

        float ratio = 1.0f / (float)desiredZoomLevel;

        if (rect != null) {
          int croppedWidth = rect.width() - Math.round((float) rect.width() * ratio);
          int croppedHeight = rect.height() - Math.round((float) rect.height() * ratio);
          final Rect desiredRegion = new Rect(croppedWidth / 2, croppedHeight / 2, rect.width() - croppedWidth / 2, rect.height() - croppedHeight / 2);
          captureRequestBuilder.set(CaptureRequest.SCALER_CROP_REGION, desiredRegion);
        }

        captureRequestBuilder.set(
                CaptureRequest.FLASH_MODE,
                isTorchOn ? CaptureRequest.FLASH_MODE_TORCH : CaptureRequest.FLASH_MODE_OFF);
        captureRequestBuilder.set(
                CaptureRequest.CONTROL_AE_TARGET_FPS_RANGE,
                new Range<>(
                        captureFormat.framerate.min / fpsUnitFactor,
                        captureFormat.framerate.max / fpsUnitFactor));
        captureRequestBuilder.set(
                CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON);
        captureRequestBuilder.set(CaptureRequest.CONTROL_AE_LOCK, false);
        captureRequestBuilder.addTarget(surface);
        captureSession.setRepeatingRequest(
                captureRequestBuilder.build(), null, cameraThreadHandler);
      } catch (CameraAccessException e) {
        // Should never happen since we are already accessing the camera
        throw new RuntimeException(e);
      }


      result.success(null);
      return;
    }

    if (info.capturer instanceof Camera1Capturer) {
      Camera camera;
      try {
        Object session =
                getPrivateProperty(
                        Camera1Capturer.class.getSuperclass(), info.capturer, "currentSession");
        camera = (Camera) getPrivateProperty(session.getClass(), session, "camera");
      } catch (NoSuchFieldWithNameException e) {
        // Most likely the upstream Camera1Capturer class have changed
        resultError("setZoom", "[ZOOM] Failed to get `" + e.fieldName + "` from `" + e.className + "`", result);
        return;
      }

      Camera.Parameters params = camera.getParameters();
      params.setFlashMode(
              isTorchOn ? Camera.Parameters.FLASH_MODE_TORCH : Camera.Parameters.FLASH_MODE_OFF);
      if(params.isZoomSupported()) {
        int maxZoom = params.getMaxZoom();
        double desiredZoom = Math.max(0, Math.min(zoomLevel, maxZoom));
        params.setZoom((int)desiredZoom);
        result.success(null);
        return;
      }
    }
    resultError("setZoom", "[ZOOM] Video capturer not compatible", result);
  }

  @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
  public void setTorch(String trackId, boolean torch, MethodChannel.Result result) {
    VideoCapturerInfo info = getUserMediaImpl.getCapturerInfo(trackId);
    if (info == null) {
      resultError("setTorch", "Video capturer not found for id: " + trackId, result);
      return;
    }
    if (info.capturer instanceof Camera2Capturer) {
      CameraCaptureSession captureSession;
      CameraDevice cameraDevice;
      CameraEnumerationAndroid.CaptureFormat captureFormat;
      int fpsUnitFactor;
      Surface surface;
      Handler cameraThreadHandler;

      try {
        Object session =
                getPrivateProperty(
                        Camera2Capturer.class.getSuperclass(), info.capturer, "currentSession");
        CameraManager manager =
                (CameraManager)
                        getPrivateProperty(Camera2Capturer.class, info.capturer, "cameraManager");
        captureSession =
                (CameraCaptureSession)
                        getPrivateProperty(session.getClass(), session, "captureSession");
        cameraDevice =
                (CameraDevice) getPrivateProperty(session.getClass(), session, "cameraDevice");
        captureFormat =
                (CameraEnumerationAndroid.CaptureFormat) getPrivateProperty(session.getClass(), session, "captureFormat");
        fpsUnitFactor = (int) getPrivateProperty(session.getClass(), session, "fpsUnitFactor");
        surface = (Surface) getPrivateProperty(session.getClass(), session, "surface");
        cameraThreadHandler =
                (Handler) getPrivateProperty(session.getClass(), session, "cameraThreadHandler");
      } catch (NoSuchFieldWithNameException e) {
        // Most likely the upstream Camera2Capturer class have changed
        resultError("setTorch", "[TORCH] Failed to get `" + e.fieldName + "` from `" + e.className + "`", result);
        return;
      }

      try {
        final CaptureRequest.Builder captureRequestBuilder =
                cameraDevice.createCaptureRequest(CameraDevice.TEMPLATE_RECORD);
        captureRequestBuilder.set(
                CaptureRequest.FLASH_MODE,
                torch ? CaptureRequest.FLASH_MODE_TORCH : CaptureRequest.FLASH_MODE_OFF);
        captureRequestBuilder.set(
                CaptureRequest.CONTROL_AE_TARGET_FPS_RANGE,
                new Range<>(
                        captureFormat.framerate.min / fpsUnitFactor,
                        captureFormat.framerate.max / fpsUnitFactor));
        captureRequestBuilder.set(
                CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON);
        captureRequestBuilder.set(CaptureRequest.CONTROL_AE_LOCK, false);
        captureRequestBuilder.addTarget(surface);
        captureSession.setRepeatingRequest(
                captureRequestBuilder.build(), null, cameraThreadHandler);
      } catch (CameraAccessException e) {
        // Should never happen since we are already accessing the camera
        throw new RuntimeException(e);
      }

      result.success(null);
      isTorchOn = torch;
      return;
    }

    if (info.capturer instanceof Camera1Capturer) {
      Camera camera;
      try {
        Object session =
                getPrivateProperty(
                        Camera1Capturer.class.getSuperclass(), info.capturer, "currentSession");
        camera = (Camera) getPrivateProperty(session.getClass(), session, "camera");
      } catch (NoSuchFieldWithNameException e) {
        // Most likely the upstream Camera1Capturer class have changed
        resultError("setTorch", "[TORCH] Failed to get `" + e.fieldName + "` from `" + e.className + "`", result);
        return;
      }

      Camera.Parameters params = camera.getParameters();
      params.setFlashMode(
              torch ? Camera.Parameters.FLASH_MODE_TORCH : Camera.Parameters.FLASH_MODE_OFF);
      camera.setParameters(params);

      result.success(null);
      isTorchOn = torch;
      return;
    }
    resultError("setTorch", "[TORCH] Video capturer not compatible", result);
  }


  private class NoSuchFieldWithNameException extends NoSuchFieldException {

    String className;
    String fieldName;

    NoSuchFieldWithNameException(String className, String fieldName, NoSuchFieldException e) {
      super(e.getMessage());
      this.className = className;
      this.fieldName = fieldName;
    }
  }
  static private void resultError(String method, String error, MethodChannel.Result result) {
    String errorMsg = method + "(): " + error;
    result.error(method, errorMsg, null);
    Log.d(TAG, errorMsg);
  }
  private Object getPrivateProperty(Class klass, Object object, String fieldName)
          throws NoSuchFieldWithNameException {
    try {
      Field field = klass.getDeclaredField(fieldName);
      field.setAccessible(true);
      return field.get(object);
    } catch (NoSuchFieldException e) {
      throw new NoSuchFieldWithNameException(klass.getName(), fieldName, e);
    } catch (IllegalAccessException e) {
      // Should never happen since we are calling `setAccessible(true)`
      throw new RuntimeException(e);
    }
  }
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

  static class MeteringRectangleFactory {
    public static MeteringRectangle create(
            int x, int y, int width, int height, int meteringWeight) {
      return new MeteringRectangle(x, y, width, height, meteringWeight);
    }
  }
}

