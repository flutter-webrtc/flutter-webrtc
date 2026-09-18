package com.cloudwebrtc.webrtc.pip;

import android.app.Activity;
import android.app.PictureInPictureParams;
import android.content.Context;
import android.content.pm.PackageManager;
import android.graphics.Rect;
import android.os.Build;
import android.util.Log;
import android.util.Rational;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import com.cloudwebrtc.webrtc.FlutterWebRTCPlugin;
import com.cloudwebrtc.webrtc.StateProvider;
import com.cloudwebrtc.webrtc.utils.ConstraintsMap;
import com.cloudwebrtc.webrtc.utils.ObjectType;

import java.util.HashMap;
import java.util.Map;

public class PictureInPictureManager {
  private static final String TAG = FlutterWebRTCPlugin.TAG;

  // Limits enforced by PictureInPictureParams.Builder#setAspectRatio.
  private static final double MIN_ASPECT_RATIO = 1.0 / 2.39;
  private static final double MAX_ASPECT_RATIO = 2.39;

  public interface EventSink {
    void send(Map<String, Object> event);
  }

  private final StateProvider stateProvider;
  private final EventSink eventSink;

  private Rational aspectRatio;
  private Rect sourceRect;
  private boolean autoEnter;
  private boolean seamlessResize = true;
  private boolean configured;
  private boolean inPictureInPicture;

  public PictureInPictureManager(@NonNull StateProvider stateProvider, @NonNull EventSink eventSink) {
    this.stateProvider = stateProvider;
    this.eventSink = eventSink;
  }

  public boolean isSupported() {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
      return false;
    }
    Context context = stateProvider.getApplicationContext();
    return context != null
        && context.getPackageManager().hasSystemFeature(PackageManager.FEATURE_PICTURE_IN_PICTURE);
  }

  public void configure(ConstraintsMap args) {
    aspectRatio = null;
    if (args.hasKey("aspectRatio") && args.getType("aspectRatio") == ObjectType.Number) {
      double ratio = Math.max(MIN_ASPECT_RATIO, Math.min(MAX_ASPECT_RATIO, args.getDouble("aspectRatio")));
      aspectRatio = new Rational((int) Math.round(ratio * 1000), 1000);
    }

    sourceRect = null;
    if (args.hasKey("sourceRect") && args.getType("sourceRect") == ObjectType.Map) {
      ConstraintsMap rect = args.getMap("sourceRect");
      double scale = 1.0;
      if (args.hasKey("devicePixelRatio") && args.getType("devicePixelRatio") == ObjectType.Number) {
        scale = args.getDouble("devicePixelRatio");
      }
      sourceRect = new Rect(
          (int) Math.round(rect.getDouble("left") * scale),
          (int) Math.round(rect.getDouble("top") * scale),
          (int) Math.round(rect.getDouble("right") * scale),
          (int) Math.round(rect.getDouble("bottom") * scale));
    }

    autoEnter = args.hasKey("autoEnter") && args.getBoolean("autoEnter");
    seamlessResize = !args.hasKey("seamlessResize") || args.getBoolean("seamlessResize");
    configured = true;
    applyParams();
  }

  public boolean enter() {
    Activity activity = stateProvider.getActivity();
    if (activity == null || !isSupported()) {
      return false;
    }
    try {
      return activity.enterPictureInPictureMode(buildParams());
    } catch (IllegalStateException | IllegalArgumentException e) {
      Log.w(TAG, "enterPictureInPictureMode failed", e);
      return false;
    }
  }

  public boolean isActive() {
    Activity activity = stateProvider.getActivity();
    return Build.VERSION.SDK_INT >= Build.VERSION_CODES.N
        && activity != null
        && activity.isInPictureInPictureMode();
  }

  // Android 12+ enters automatically through setAutoEnterEnabled; older
  // versions only allow entering from Activity#onUserLeaveHint.
  public void onUserLeaveHint() {
    if (configured && autoEnter && Build.VERSION.SDK_INT < Build.VERSION_CODES.S && !isActive()) {
      enter();
    }
  }

  public void onPictureInPictureModeChanged(boolean isInPictureInPictureMode) {
    if (inPictureInPicture == isInPictureInPictureMode) {
      return;
    }
    inPictureInPicture = isInPictureInPictureMode;
    Map<String, Object> event = new HashMap<>();
    event.put("event", "pictureInPictureStateChanged");
    event.put("state", isInPictureInPictureMode ? "started" : "stopped");
    eventSink.send(event);
  }

  public void syncState() {
    onPictureInPictureModeChanged(isActive());
  }

  public void dispose() {
    configured = false;
    autoEnter = false;
    aspectRatio = null;
    sourceRect = null;
    applyParams();
  }

  private void applyParams() {
    Activity activity = stateProvider.getActivity();
    if (activity == null || !isSupported()) {
      return;
    }
    try {
      activity.setPictureInPictureParams(buildParams());
    } catch (IllegalStateException | IllegalArgumentException e) {
      Log.w(TAG, "setPictureInPictureParams failed", e);
    }
  }

  @RequiresApi(Build.VERSION_CODES.O)
  private PictureInPictureParams buildParams() {
    PictureInPictureParams.Builder builder = new PictureInPictureParams.Builder();
    if (aspectRatio != null) {
      builder.setAspectRatio(aspectRatio);
    }
    if (sourceRect != null) {
      builder.setSourceRectHint(sourceRect);
    }
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
      builder.setAutoEnterEnabled(autoEnter);
      builder.setSeamlessResizeEnabled(seamlessResize);
    }
    return builder.build();
  }
}
