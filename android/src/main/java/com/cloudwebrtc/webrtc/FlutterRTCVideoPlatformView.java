package com.cloudwebrtc.webrtc;

import android.content.Context;
import android.util.Log;
import android.view.View;

import com.cloudwebrtc.webrtc.utils.AnyThreadSink;
import com.cloudwebrtc.webrtc.utils.ConstraintsMap;
import com.cloudwebrtc.webrtc.utils.EglUtils;

import java.util.List;

import org.webrtc.EglBase;
import org.webrtc.MediaStream;
import org.webrtc.RendererCommon;
import org.webrtc.SurfaceViewRenderer;
import org.webrtc.VideoTrack;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.platform.PlatformView;

public class FlutterRTCVideoPlatformView implements PlatformView, EventChannel.StreamHandler {
    private static final String TAG = FlutterWebRTCPlugin.TAG;

    private final long viewId;
    private final MethodCallHandlerImpl methodCallHandler;
    private final SurfaceViewRenderer renderer;
    private final EventChannel eventChannel;
    private boolean rendererInitialized = false;
    private boolean disposed = false;
    private boolean firstFrameRendered = false;
    private int videoWidth = 0;
    private int videoHeight = 0;
    private int rotation = -1;
    private MediaStream mediaStream;
    private String ownerTag;
    private VideoTrack videoTrack;
    private EventChannel.EventSink eventSink;

    private final RendererCommon.RendererEvents rendererEvents =
            new RendererCommon.RendererEvents() {
                @Override
                public void onFirstFrameRendered() {
                    sendFirstFrameRenderedIfNeeded();
                }

                @Override
                public void onFrameResolutionChanged(
                        int videoWidth,
                        int videoHeight,
                        int rotation) {
                    if (FlutterRTCVideoPlatformView.this.videoWidth != videoWidth ||
                            FlutterRTCVideoPlatformView.this.videoHeight != videoHeight) {
                        ConstraintsMap params = new ConstraintsMap();
                        params.putString("event", "didPlatformViewChangeVideoSize");
                        params.putInt("id", (int) viewId);
                        params.putDouble("width", (double) videoWidth);
                        params.putDouble("height", (double) videoHeight);
                        FlutterRTCVideoPlatformView.this.videoWidth = videoWidth;
                        FlutterRTCVideoPlatformView.this.videoHeight = videoHeight;
                        sendEvent(params);
                    }

                    if (FlutterRTCVideoPlatformView.this.rotation != rotation) {
                        ConstraintsMap params = new ConstraintsMap();
                        params.putString("event", "didPlatformViewChangeRotation");
                        params.putInt("id", (int) viewId);
                        params.putInt("rotation", rotation);
                        FlutterRTCVideoPlatformView.this.rotation = rotation;
                        sendEvent(params);
                    }

                    sendFirstFrameRenderedIfNeeded();
                }
            };

    public FlutterRTCVideoPlatformView(
            Context context,
            BinaryMessenger messenger,
            long viewId,
            MethodCallHandlerImpl methodCallHandler) {
        this.viewId = viewId;
        this.methodCallHandler = methodCallHandler;
        this.renderer = new SurfaceViewRenderer(context);
        this.eventChannel = new EventChannel(
                messenger,
                "FlutterWebRTC/PlatformViewId" + viewId);
        eventChannel.setStreamHandler(this);

        initializeRenderer();
    }

    @Override
    public View getView() {
        return renderer;
    }

    @Override
    public void dispose() {
        if (disposed) {
            return;
        }
        disposed = true;
        setVideoTrack(null);
        eventChannel.setStreamHandler(null);
        eventSink = null;
        if (rendererInitialized) {
            renderer.release();
            rendererInitialized = false;
        }
        methodCallHandler.unregisterPlatformView(viewId, this);
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink sink) {
        eventSink = new AnyThreadSink(sink);
    }

    @Override
    public void onCancel(Object arguments) {
        eventSink = null;
    }

    public void setStream(MediaStream mediaStream, String ownerTag) {
        VideoTrack videoTrack;
        this.mediaStream = mediaStream;
        this.ownerTag = ownerTag;
        if (mediaStream == null) {
            videoTrack = null;
        } else {
            List<VideoTrack> videoTracks = mediaStream.videoTracks;
            videoTrack = videoTracks.isEmpty() ? null : videoTracks.get(0);
        }

        setVideoTrack(videoTrack);
    }

    public void setStream(MediaStream mediaStream, String trackId, String ownerTag) {
        VideoTrack videoTrack;
        this.mediaStream = mediaStream;
        this.ownerTag = ownerTag;
        if (mediaStream == null) {
            videoTrack = null;
        } else {
            List<VideoTrack> videoTracks = mediaStream.videoTracks;
            videoTrack = videoTracks.isEmpty() ? null : videoTracks.get(0);

            for (VideoTrack track : videoTracks) {
                if (track.id().equals(trackId)) {
                    videoTrack = track;
                }
            }
        }

        setVideoTrack(videoTrack);
    }

    public void setVideoTrack(VideoTrack videoTrack) {
        VideoTrack oldValue = this.videoTrack;
        if (oldValue == videoTrack) {
            return;
        }

        if (oldValue != null) {
            oldValue.removeSink(renderer);
        }

        this.videoTrack = videoTrack;
        resetVideoState();

        if (videoTrack == null) {
            return;
        }

        if (!restartRenderer()) {
            Log.e(TAG, "Failed to render a VideoTrack: platform renderer is not initialized");
            return;
        }

        videoTrack.addSink(renderer);
    }

    public boolean checkMediaStream(String id, String ownerTag) {
        if (id == null || mediaStream == null || ownerTag == null || !ownerTag.equals(this.ownerTag)) {
            return false;
        }
        return id.equals(mediaStream.getId());
    }

    public boolean checkVideoTrack(String id, String ownerTag) {
        if (id == null || videoTrack == null || ownerTag == null || !ownerTag.equals(this.ownerTag)) {
            return false;
        }
        return id.equals(videoTrack.id());
    }

    private void resetVideoState() {
        firstFrameRendered = false;
        videoWidth = 0;
        videoHeight = 0;
        rotation = -1;
    }

    private boolean restartRenderer() {
        if (rendererInitialized) {
            renderer.release();
            rendererInitialized = false;
        }
        return initializeRenderer();
    }

    private boolean initializeRenderer() {
        EglBase.Context sharedContext = EglUtils.getRootEglBaseContext();
        if (sharedContext == null) {
            Log.e(TAG, "Failed to initialize FlutterRTCVideoPlatformView: no EGL context");
            return false;
        }

        renderer.init(sharedContext, rendererEvents);
        renderer.setScalingType(RendererCommon.ScalingType.SCALE_ASPECT_FILL);
        renderer.setEnableHardwareScaler(false);
        rendererInitialized = true;
        return true;
    }

    private void sendFirstFrameRenderedIfNeeded() {
        if (firstFrameRendered) {
            return;
        }
        firstFrameRendered = true;
        ConstraintsMap params = new ConstraintsMap();
        params.putString("event", "didFirstFrameRendered");
        params.putInt("id", (int) viewId);
        sendEvent(params);
    }

    private void sendEvent(ConstraintsMap params) {
        if (eventSink != null) {
            eventSink.success(params.toMap());
        }
    }
}
