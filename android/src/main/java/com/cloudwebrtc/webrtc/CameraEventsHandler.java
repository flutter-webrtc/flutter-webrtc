package com.cloudwebrtc.webrtc;

import android.util.Log;

import com.cloudwebrtc.webrtc.video.VideoCapturerInfo;

import org.webrtc.CameraVideoCapturer;

class CameraEventsHandler implements CameraVideoCapturer.CameraEventsHandler {
    public enum CameraState {
        NEW,
        OPENING,
        OPENED,
        CLOSED,
        DISCONNECTED,
        ERROR,
        FREEZED
    }
    private final static String TAG = FlutterWebRTCPlugin.TAG;
    private CameraState state = CameraState.NEW;

    public void waitForCameraOpen() {
        Log.d(TAG, "CameraEventsHandler.waitForCameraOpen");
        while (state != CameraState.OPENED && state != CameraState.ERROR) {
            try {
                Thread.sleep(1);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }

    public void waitForCameraClosed() {
        Log.d(TAG, "CameraEventsHandler.waitForCameraClosed");
        while (state != CameraState.CLOSED && state != CameraState.ERROR) {
            try {
                Thread.sleep(1);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }

    // Camera error handler - invoked when camera can not be opened
    // or any camera exception happens on camera thread.
    @Override
    public void onCameraError(String errorDescription) {
        Log.d(TAG, String.format("CameraEventsHandler.onCameraError: errorDescription=%s", errorDescription));
        state = CameraState.ERROR;
    }

    // Called when camera is disconnected.
    @Override
    public void onCameraDisconnected() {
        Log.d(TAG, "CameraEventsHandler.onCameraDisconnected");
        state = CameraState.DISCONNECTED;
    }

    // Invoked when camera stops receiving frames
    @Override
    public void onCameraFreezed(String errorDescription) {
        Log.d(TAG, String.format("CameraEventsHandler.onCameraFreezed: errorDescription=%s", errorDescription));
        state = CameraState.FREEZED;
    }

    // Callback invoked when camera is opening.
    @Override
    public void onCameraOpening(String cameraName) {
        Log.d(TAG, String.format("CameraEventsHandler.onCameraOpening: cameraName=%s", cameraName));
        state = CameraState.OPENING;
    }

    // The capturer this handler belongs to, set before capture starts.
    volatile VideoCapturerInfo info;

    // Callback invoked when first camera frame is available after camera is opened.
    @Override
    public void onFirstFrameAvailable() {
        Log.d(TAG, "CameraEventsHandler.onFirstFrameAvailable");
        state = CameraState.OPENED;
        FlutterWebRTCPlugin plugin = FlutterWebRTCPlugin.sharedSingleton;
        FlutterWebRTCPlugin.CameraStartedListener listener = plugin == null ? null : plugin.cameraStartedListener;
        if (listener != null && info != null) listener.onCameraStarted(info);
    }

    // Callback invoked when camera closed.
    @Override
    public void onCameraClosed() {
        Log.d(TAG, "CameraEventsHandler.onFirstFrameAvailable");
        state = CameraState.CLOSED;
    }
}
