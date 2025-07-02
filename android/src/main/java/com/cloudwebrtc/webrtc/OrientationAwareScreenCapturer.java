package com.cloudwebrtc.webrtc;

import org.webrtc.SurfaceTextureHelper;
import org.webrtc.CapturerObserver;
import org.webrtc.ThreadUtils;
import org.webrtc.VideoCapturer;
import org.webrtc.VideoFrame;
import org.webrtc.VideoSink;

import android.annotation.TargetApi;
import android.content.Context;
import android.content.Intent;
import android.media.projection.MediaProjection;
import android.view.Surface;
import android.view.WindowManager;
import android.app.Activity;
import android.hardware.display.DisplayManager;
import android.util.DisplayMetrics;
import android.hardware.display.VirtualDisplay;
import android.media.projection.MediaProjectionManager;
import android.os.Looper;
import android.os.Handler;
import android.os.Build;
import android.view.Display;

/**
 * An copy of ScreenCapturerAndroid to capture the screen content while being aware of device orientation
 */
@TargetApi(21)
public class OrientationAwareScreenCapturer implements VideoCapturer, VideoSink {
    private static final int DISPLAY_FLAGS =
            DisplayManager.VIRTUAL_DISPLAY_FLAG_PUBLIC | DisplayManager.VIRTUAL_DISPLAY_FLAG_PRESENTATION;
    // DPI for VirtualDisplay, does not seem to matter for us.
    private static final int VIRTUAL_DISPLAY_DPI = 400;
    private final Intent mediaProjectionPermissionResultData;
    private final MediaProjection.Callback mediaProjectionCallback;
    private int width;
    private int height;
    private int oldWidth;
    private int oldHeight;
    private VirtualDisplay virtualDisplay;
    private SurfaceTextureHelper surfaceTextureHelper;
    private CapturerObserver capturerObserver;
    private long numCapturedFrames = 0;
    private MediaProjection mediaProjection;
    private boolean isDisposed = false;
    private MediaProjectionManager mediaProjectionManager;
    private WindowManager windowManager;
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
        this.mediaProjectionPermissionResultData = mediaProjectionPermissionResultData;
        this.mediaProjectionCallback = mediaProjectionCallback;
    }

    public void onFrame(VideoFrame frame) {
        checkNotDisposed();
        this.isPortrait = isDeviceOrientationPortrait();
        final int max = Math.max(this.height, this.width);
        final int min = Math.min(this.height, this.width);
        if (this.isPortrait) {
            changeCaptureFormat(min, max, 15);
        } else {
            changeCaptureFormat(max, min, 15);
        }
        capturerObserver.onFrameCaptured(frame);
    }

    private boolean isDeviceOrientationPortrait() {
        final Display display = windowManager.getDefaultDisplay();
        final DisplayMetrics metrics = new DisplayMetrics();
        display.getRealMetrics(metrics);
        
        return metrics.heightPixels > metrics.widthPixels;
    }


    private void checkNotDisposed() {
        if (isDisposed) {
            throw new RuntimeException("capturer is disposed.");
        }
    }

    public synchronized void initialize(final SurfaceTextureHelper surfaceTextureHelper,
                                        final Context applicationContext, final CapturerObserver capturerObserver) {
        checkNotDisposed();
        if (capturerObserver == null) {
            throw new RuntimeException("capturerObserver not set.");
        }
        this.capturerObserver = capturerObserver;
        if (surfaceTextureHelper == null) {
            throw new RuntimeException("surfaceTextureHelper not set.");
        }
        this.surfaceTextureHelper = surfaceTextureHelper;

        this.windowManager = (WindowManager) applicationContext.getSystemService(
                Context.WINDOW_SERVICE);
        this.mediaProjectionManager = (MediaProjectionManager) applicationContext.getSystemService(
                Context.MEDIA_PROJECTION_SERVICE);
    }

    @Override
    public synchronized void startCapture(
            final int width, final int height, final int ignoredFramerate) {
        //checkNotDisposed();

        this.isPortrait = isDeviceOrientationPortrait();
        if (this.isPortrait) {
            this.width = width;
            this.height = height;
        } else {
            this.height = width;
            this.width = height;
        }

        mediaProjection = mediaProjectionManager.getMediaProjection(
                Activity.RESULT_OK, mediaProjectionPermissionResultData);

        // Let MediaProjection callback use the SurfaceTextureHelper thread.
        mediaProjection.registerCallback(mediaProjectionCallback, surfaceTextureHelper.getHandler());

        createVirtualDisplay();
        capturerObserver.onCapturerStarted(true);
        surfaceTextureHelper.startListening(this);
    }

    @Override
    public synchronized void stopCapture() {
        checkNotDisposed();
        ThreadUtils.invokeAtFrontUninterruptibly(surfaceTextureHelper.getHandler(), new Runnable() {
            @Override
            public void run() {
                surfaceTextureHelper.stopListening();
                capturerObserver.onCapturerStopped();
                if (virtualDisplay != null) {
                    virtualDisplay.release();
                    virtualDisplay = null;
                }
                if (mediaProjection != null) {
                    // Unregister the callback before stopping, otherwise the callback recursively
                    // calls this method.
                    mediaProjection.unregisterCallback(mediaProjectionCallback);
                    mediaProjection.stop();
                    mediaProjection = null;
                }
            }
        });
    }

    @Override
    public synchronized void dispose() {
        isDisposed = true;
    }

    /**
     * Changes output video format. This method can be used to scale the output
     * video, or to change orientation when the captured screen is rotated for example.
     *
     * @param width            new output video width
     * @param height           new output video height
     * @param ignoredFramerate ignored
     */
    @Override
    public synchronized void changeCaptureFormat(
            final int width, final int height, final int ignoredFramerate) {
        checkNotDisposed();
        if (this.oldWidth != width || this.oldHeight != height) {
            this.oldWidth = width;
            this.oldHeight = height;

            if (oldHeight > oldWidth) {
                ThreadUtils.invokeAtFrontUninterruptibly(surfaceTextureHelper.getHandler(), new Runnable() {
                    @Override
                    public void run() {
                        if (virtualDisplay != null && surfaceTextureHelper != null) {
                            virtualDisplay.setSurface(new Surface(surfaceTextureHelper.getSurfaceTexture()));
                            surfaceTextureHelper.setTextureSize(oldWidth, oldHeight);
                            virtualDisplay.resize(oldWidth, oldHeight, VIRTUAL_DISPLAY_DPI);
                        }
                    }
                });
            }

            if (oldWidth > oldHeight) {
                surfaceTextureHelper.setTextureSize(oldWidth, oldHeight);
                virtualDisplay.setSurface(new Surface(surfaceTextureHelper.getSurfaceTexture()));
                final Handler handler = new Handler(Looper.getMainLooper());
                handler.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        ThreadUtils.invokeAtFrontUninterruptibly(surfaceTextureHelper.getHandler(), new Runnable() {
                            @Override
                            public void run() {
                                if (virtualDisplay != null && surfaceTextureHelper != null) {
                                    virtualDisplay.resize(oldWidth, oldHeight, VIRTUAL_DISPLAY_DPI);
                                }
                            }
                        });
                    }
                }, 700);
            }
        }
    }

    private void createVirtualDisplay() {
        surfaceTextureHelper.setTextureSize(width, height);
        surfaceTextureHelper.getSurfaceTexture().setDefaultBufferSize(width, height);
        virtualDisplay = mediaProjection.createVirtualDisplay("WebRTC_ScreenCapture", width, height,
                VIRTUAL_DISPLAY_DPI, DISPLAY_FLAGS, new Surface(surfaceTextureHelper.getSurfaceTexture()),
                null /* callback */, null /* callback handler */);
    }

    @Override
    public boolean isScreencast() {
        return true;
    }

    public long getNumCapturedFrames() {
        return numCapturedFrames;
    }
}