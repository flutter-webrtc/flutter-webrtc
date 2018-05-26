package com.cloudwebrtc.webrtc;

import android.content.Context;
import android.util.Log;

import java.lang.reflect.Method;
import java.util.List;

import org.webrtc.EglBase;
import org.webrtc.MediaStream;
import org.webrtc.RendererCommon.RendererEvents;
import org.webrtc.VideoRenderer;
import org.webrtc.VideoTrack;

public class FlutterRTCVideoRenderer {

    private static final String TAG = FlutterWebRTCPlugin.TAG;

    static {
        // IS_IN_LAYOUT
        Method isInLayout = null;

        try {
            Method m = FlutterRTCVideoRenderer.class.getMethod("isInLayout");

            if (boolean.class.isAssignableFrom(m.getReturnType())) {
                isInLayout = m;
            }
        } catch (NoSuchMethodException e) {
            // Fall back to the behavior of ViewCompat#isInLayout(View).
        }
    }

    /**
     * The height of the last video frame rendered by
     * {@link #surfaceViewRenderer}.
     */
    private int frameHeight;

    /**
     * The rotation (degree) of the last video frame rendered by
     * {@link #surfaceViewRenderer}.
     */
    private int frameRotation;

    /**
     * The width of the last video frame rendered by
     * {@link #surfaceViewRenderer}.
     */
    private int frameWidth;

    /**
     * The {@code RendererEvents} which listens to rendering events reported by
     * {@link #surfaceViewRenderer}.
     */
    private final RendererEvents rendererEvents
        = new RendererEvents() {
            @Override
            public void onFirstFrameRendered() {
            }

            @Override
            public void onFrameResolutionChanged(
                    int videoWidth, int videoHeight,
                    int rotation) {
                FlutterRTCVideoRenderer.this.onFrameResolutionChanged(
                        videoWidth, videoHeight,
                        rotation);
            }
        };

    private final SurfaceViewRenderer surfaceViewRenderer;

    /**
     * The {@code VideoRenderer}, if any, which renders {@link #videoTrack} on
     * this {@code View}.
     */
    private VideoRenderer videoRenderer;

    /**
     * The {@code VideoTrack}, if any, rendered by this {@code FlutterRTCVideoRenderer}.
     */
    private VideoTrack videoTrack;

    public FlutterRTCVideoRenderer(Context context) {
        surfaceViewRenderer = new SurfaceViewRenderer(context);
    }

    private final SurfaceViewRenderer getSurfaceViewRenderer() {
        return surfaceViewRenderer;
    }

    private void onFrameResolutionChanged(
            int videoWidth, int videoHeight,
            int rotation) {
        boolean changed = false;
        /*
        synchronized (layoutSyncRoot) {
            if (this.frameHeight != videoHeight) {
                this.frameHeight = videoHeight;
                changed = true;
            }
            if (this.frameRotation != rotation) {
                this.frameRotation = rotation;
                changed = true;
            }
            if (this.frameWidth != videoWidth) {
                this.frameWidth = videoWidth;
                changed = true;
            }
        }
        */
    }

    /**
     * Stops rendering {@link #videoTrack} and releases the associated acquired
     * resources (if rendering is in progress).
     */
    private void removeRendererFromVideoTrack() {
        if (videoRenderer != null) {
            videoTrack.removeRenderer(videoRenderer);
            videoRenderer.dispose();
            videoRenderer = null;

            getSurfaceViewRenderer().release();
            /*
            // Since this FlutterRTCVideoRenderer is no longer rendering anything, make sure
            // surfaceViewRenderer displays nothing as well.
            synchronized (layoutSyncRoot) {
                frameHeight = 0;
                frameRotation = 0;
                frameWidth = 0;
            }
            */
        }
    }

    /**
     * Sets the {@code MediaStream} to be rendered by this {@code FlutterRTCVideoRenderer}.
     * The implementation renders the first {@link VideoTrack}, if any, of the
     * specified {@code mediaStream}.
     *
     * @param mediaStream The {@code MediaStream} to be rendered by this
     * {@code FlutterRTCVideoRenderer} or {@code null}.
     */
    public void setStream(MediaStream mediaStream) {
        VideoTrack videoTrack;

        if (mediaStream == null) {
            videoTrack = null;
        } else {
            List<VideoTrack> videoTracks = mediaStream.videoTracks;

            videoTrack = videoTracks.isEmpty() ? null : videoTracks.get(0);
        }

        setVideoTrack(videoTrack);
    }

    /**
     * Sets the {@code VideoTrack} to be rendered by this {@code FlutterRTCVideoRenderer}.
     *
     * @param videoTrack The {@code VideoTrack} to be rendered by this
     * {@code FlutterRTCVideoRenderer} or {@code null}.
     */
    private void setVideoTrack(VideoTrack videoTrack) {
        VideoTrack oldValue = this.videoTrack;

        if (oldValue != videoTrack) {
            if (oldValue != null) {
                removeRendererFromVideoTrack();
            }

            this.videoTrack = videoTrack;

            if (videoTrack != null) {
                tryAddRendererToVideoTrack();
            }
        }
    }

    //@ReactProp(name = "streamURL")
    public void setStreamURL(FlutterRTCVideoRenderer view, String streamURL) {
        MediaStream mediaStream;
        if (streamURL == null) {
            mediaStream = null;
        } else {
            //TODO:
            //ReactContext reactContext = (ReactContext) view.getContext();
            //WebRTCModule module = reactContext.getNativeModule(WebRTCModule.class);
            //mediaStream = module.getStreamForReactTag(streamURL);
        }
        //view.setStream(mediaStream);
    }

    /**
     * Sets the z-order of this {@link FlutterRTCVideoRenderer} in the stacking space of all
     * {@code FlutterRTCVideoRenderer}s. For more details, refer to the documentation of the
     * {@code zOrder} property of the JavaScript counterpart of
     * {@code FlutterRTCVideoRenderer} i.e. {@code RTCView}.
     *
     * @param zOrder The z-order to set on this {@code FlutterRTCVideoRenderer}.
     */
    public void setZOrder(int zOrder) {
        SurfaceViewRenderer surfaceViewRenderer = getSurfaceViewRenderer();

        switch (zOrder) {
        case 0:
            surfaceViewRenderer.setZOrderMediaOverlay(false);
            break;
        case 1:
            surfaceViewRenderer.setZOrderMediaOverlay(true);
            break;
        case 2:
            surfaceViewRenderer.setZOrderOnTop(true);
            break;
        }
    }

    /**
     * Starts rendering {@link #videoTrack} if rendering is not in progress and
     * all preconditions for the start of rendering are met.
     */
    private void tryAddRendererToVideoTrack() {
        if (videoRenderer == null
                && videoTrack != null) {
            EglBase.Context sharedContext = EglUtils.getRootEglBaseContext();

            if (sharedContext == null) {
                // If SurfaceViewRenderer#init() is invoked, it will throw a
                // RuntimeException which will very likely kill the application.
                Log.e(TAG, "Failed to render a VideoTrack!");
                return;
            }

            SurfaceViewRenderer surfaceViewRenderer = getSurfaceViewRenderer();
            surfaceViewRenderer.init(sharedContext, rendererEvents);

            videoRenderer = new VideoRenderer(surfaceViewRenderer);
            videoTrack.addRenderer(videoRenderer);
        }
    }
}
