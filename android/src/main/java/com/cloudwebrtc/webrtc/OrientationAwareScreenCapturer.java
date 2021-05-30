package com.cloudwebrtc.webrtc;

import org.webrtc.ScreenCapturerAndroid;
import org.webrtc.SurfaceTextureHelper;
import org.webrtc.CapturerObserver;
import org.webrtc.VideoFrame;

import android.annotation.TargetApi;
import android.content.Context;
import android.content.Intent;
import android.media.projection.MediaProjection;
import android.util.Log;
import android.view.Surface;
import android.view.WindowManager;


/**
 * An implementation of ScreenCapturerAndroid to capture the screen content while being aware of device orientation
 */
@TargetApi(21)
public class OrientationAwareScreenCapturer
        extends ScreenCapturerAndroid {
    private Context applicationContext;
    private WindowManager windowManager;
    private int width;
    private int height;
    private boolean isPortrait;

    /**
     * Constructs a new Screen Capturer.
     *
     * @param mediaProjectionPermissionResultData the result data of MediaProjection permission
     *                                            activity; the calling app must validate that result code is Activity.RESULT_OK before
     *                                            calling this method.
     * @param mediaProjectionCallback             MediaProjection callback to implement application specific
     *                                            logic in events such as when the user revokes a previously granted capture permission.
     **/
    public OrientationAwareScreenCapturer(Intent mediaProjectionPermissionResultData,
                                          MediaProjection.Callback mediaProjectionCallback) {
        super(mediaProjectionPermissionResultData, mediaProjectionCallback);
    }

    @Override
    public synchronized void initialize(SurfaceTextureHelper surfaceTextureHelper, Context applicationContext, CapturerObserver capturerObserver) {
        super.initialize(surfaceTextureHelper, applicationContext, capturerObserver);
        this.applicationContext = applicationContext;
        Log.d("OrientationAwareSC", "OrientationAwareScreenCapturer: initialized and orientation isPortrait? " + this.isPortrait);
    }

    @Override
    public synchronized void startCapture(int width, int height, int ignoredFramerate) {
        this.windowManager = (WindowManager) applicationContext.getSystemService(
                Context.WINDOW_SERVICE);
        this.isPortrait = isDeviceOrientationPortrait();
        if (this.isPortrait) {
            this.width = width;
            this.height = height;
        } else {
            this.height = width;
            this.width = height;
        }
        super.startCapture(width, height, ignoredFramerate);
    }

    @Override
    public void onFrame(VideoFrame frame) {
        final boolean isOrientationPortrait = isDeviceOrientationPortrait();
        if (isOrientationPortrait != this.isPortrait) {
            this.isPortrait = isOrientationPortrait;

            if (this.isPortrait) {
                super.changeCaptureFormat(this.width, this.height, 15);
            } else {
                super.changeCaptureFormat(this.height, this.width, 15);
            }
        }
        super.onFrame(frame);
    }

    private boolean isDeviceOrientationPortrait() {
        final int surfaceRotation = windowManager.getDefaultDisplay().getRotation();

        return surfaceRotation != Surface.ROTATION_90 && surfaceRotation != Surface.ROTATION_270;
    }

}
