package com.cloudwebrtc.webrtc;

import android.util.Log;
import android.graphics.SurfaceTexture;
import android.view.Surface;

import com.cloudwebrtc.webrtc.utils.AnyThreadSink;
import com.cloudwebrtc.webrtc.utils.ConstraintsMap;
import com.cloudwebrtc.webrtc.utils.EglUtils;

import java.util.List;

import org.webrtc.EglBase;
import org.webrtc.MediaStream;
import org.webrtc.RendererCommon.RendererEvents;
import org.webrtc.VideoTrack;

import io.flutter.plugin.common.EventChannel;
import io.flutter.view.TextureRegistry;

public class FlutterRTCVideoRenderer implements EventChannel.StreamHandler {

    private static final String TAG = FlutterWebRTCPlugin.TAG;
    private final TextureRegistry.SurfaceProducer producer;
    private int id = -1;
    private String mediaStreamId;

    private String ownerTag;

    public void Dispose() {
        setVideoTrack(null);
        if (surfaceTextureRenderer != null) {
            surfaceTextureRenderer.release();
        }
        if (eventChannel != null)
            eventChannel.setStreamHandler(null);

        eventSink = null;
        producer.release();
    }

    /**
     * The {@code RendererEvents} which listens to rendering events reported by
     * {@link #surfaceTextureRenderer}.
     */
    private RendererEvents rendererEvents;

    private void listenRendererEvents() {
        rendererEvents = new RendererEvents() {
            private int _rotation = -1;
            private int _width = 0, _height = 0;

            @Override
            public void onFirstFrameRendered() {
                ConstraintsMap params = new ConstraintsMap();
                params.putString("event", "didFirstFrameRendered");
                params.putInt("id", id);
                if (eventSink != null) {
                    eventSink.success(params.toMap());
                }
            }

            @Override
            public void onFrameResolutionChanged(
                    int videoWidth, int videoHeight,
                    int rotation) {

                if (eventSink != null) {
                    if (_width != videoWidth || _height != videoHeight) {
                        ConstraintsMap params = new ConstraintsMap();
                        params.putString("event", "didTextureChangeVideoSize");
                        params.putInt("id", id);
                        params.putDouble("width", (double) videoWidth);
                        params.putDouble("height", (double) videoHeight);
                        _width = videoWidth;
                        _height = videoHeight;
                        eventSink.success(params.toMap());
                    }

                    if (_rotation != rotation) {
                        ConstraintsMap params2 = new ConstraintsMap();
                        params2.putString("event", "didTextureChangeRotation");
                        params2.putInt("id", id);
                        params2.putInt("rotation", rotation);
                        _rotation = rotation;
                        eventSink.success(params2.toMap());
                    }
                }
            }
        };
    }

    private final SurfaceTextureRenderer surfaceTextureRenderer;

    /**
     * The {@code VideoTrack}, if any, rendered by this {@code FlutterRTCVideoRenderer}.
     */
    private VideoTrack videoTrack;
    private String videoTrackId;

    EventChannel eventChannel;
    EventChannel.EventSink eventSink;

    public FlutterRTCVideoRenderer(TextureRegistry.SurfaceProducer producer) {
        this.surfaceTextureRenderer = new SurfaceTextureRenderer("");
        listenRendererEvents();
        surfaceTextureRenderer.init(EglUtils.getRootEglBaseContext(), rendererEvents);
        surfaceTextureRenderer.surfaceCreated(producer);

        this.eventSink = null;
        this.producer = producer;
        this.ownerTag = null;
    }

    public void setEventChannel(EventChannel eventChannel) {
        this.eventChannel = eventChannel;
    }

    public void setId(int id) {
        this.id = id;
    }

    @Override
    public void onListen(Object o, EventChannel.EventSink sink) {
        eventSink = new AnyThreadSink(sink);
    }

    @Override
    public void onCancel(Object o) {
        eventSink = null;
    }

    /**
     * Stops rendering {@link #videoTrack} and releases the associated acquired
     * resources (if rendering is in progress).
     */
    private void removeRendererFromVideoTrack() {
        if (videoTrack == null) {
            return;
        }
        try {
            videoTrack.removeSink(surfaceTextureRenderer);
        } catch (IllegalStateException e) {
            Log.w(TAG, "VideoTrack was disposed before its renderer was removed");
        }
    }

    /**
     * Sets the {@code MediaStream} to be rendered by this {@code FlutterRTCVideoRenderer}.
     * The implementation renders the first {@link VideoTrack}, if any, of the
     * specified {@code mediaStream}.
     *
     * @param mediaStream The {@code MediaStream} to be rendered by this
     *                    {@code FlutterRTCVideoRenderer} or {@code null}.
     */
    public void setStream(MediaStream mediaStream, String ownerTag) {
        VideoTrack videoTrack;
        this.mediaStreamId = mediaStream == null ? null : mediaStream.getId();
        this.ownerTag = ownerTag;
        if (mediaStream == null) {
            videoTrack = null;
        } else {
            List<VideoTrack> videoTracks = mediaStream.videoTracks;

            videoTrack = videoTracks.isEmpty() ? null : videoTracks.get(0);
        }

        setVideoTrack(videoTrack);
    }
   /**
     * Sets the {@code MediaStream} to be rendered by this {@code FlutterRTCVideoRenderer}.
     * The implementation renders the first {@link VideoTrack}, if any, of the
     * specified trackId
     *
     * @param mediaStream The {@code MediaStream} to be rendered by this
     *                    {@code FlutterRTCVideoRenderer} or {@code null}.
     * @param trackId The {@code trackId} to be rendered by this
     *                    {@code FlutterRTCVideoRenderer} or {@code null}.
     */
    public void setStream(MediaStream mediaStream,String trackId, String ownerTag) {
        VideoTrack videoTrack;
        this.mediaStreamId = mediaStream == null ? null : mediaStream.getId();
        this.ownerTag = ownerTag;
        if (mediaStream == null) {
            videoTrack = null;
        } else {
            List<VideoTrack> videoTracks = mediaStream.videoTracks;

            videoTrack = videoTracks.isEmpty() ? null : videoTracks.get(0);

            for (VideoTrack track : videoTracks){
                if (track.id().equals(trackId)){
                    videoTrack = track;
                }
            }
        }

        setVideoTrack(videoTrack);
    }

    /**
     * Sets a video track already resolved from its owning PeerConnection.
     *
     * The stream id is retained only for renderer lifecycle bookkeeping. The
     * MediaStream wrapper itself may be replaced or disposed by a Unified Plan
     * renegotiation while the logical stream and track ids remain unchanged.
     */
    public void setTrack(
            VideoTrack videoTrack, String mediaStreamId, String ownerTag) {
        this.mediaStreamId = mediaStreamId;
        this.ownerTag = ownerTag;
        setVideoTrack(videoTrack);
    }

    /**
     * Sets the {@code VideoTrack} to be rendered by this {@code FlutterRTCVideoRenderer}.
     *
     * @param videoTrack The {@code VideoTrack} to be rendered by this
     *                   {@code FlutterRTCVideoRenderer} or {@code null}.
     */
    public void setVideoTrack(VideoTrack videoTrack) {
        VideoTrack oldValue = this.videoTrack;

        if (oldValue != videoTrack) {
            if (oldValue != null) {
                removeRendererFromVideoTrack();
            }

            this.videoTrack = videoTrack;
            this.videoTrackId = videoTrack == null ? null : videoTrack.id();

            if (videoTrack != null) {
                try {
                    Log.w(TAG, "FlutterRTCVideoRenderer.setVideoTrack, set video track to " + videoTrack.id());
                    tryAddRendererToVideoTrack();
                } catch (Exception e) {
                    Log.e(TAG, "tryAddRendererToVideoTrack " + e);
                }
            } else {
                Log.w(TAG, "FlutterRTCVideoRenderer.setVideoTrack, set video track to null");
            }
        }
    }

    /**
     * Starts rendering {@link #videoTrack} if rendering is not in progress and
     * all preconditions for the start of rendering are met.
     */
    private void tryAddRendererToVideoTrack() throws Exception {
        if (videoTrack != null) {
            EglBase.Context sharedContext = EglUtils.getRootEglBaseContext();

            if (sharedContext == null) {
                // If SurfaceViewRenderer#init() is invoked, it will throw a
                // RuntimeException which will very likely kill the application.
                Log.e(TAG, "Failed to render a VideoTrack!");
                return;
            }

            surfaceTextureRenderer.release();
            listenRendererEvents();
            surfaceTextureRenderer.init(sharedContext, rendererEvents);
            surfaceTextureRenderer.surfaceCreated(producer);

            videoTrack.addSink(surfaceTextureRenderer);
        }
    }

    public boolean checkMediaStream(String id, String ownerTag) {
        if (null == id || null == mediaStreamId || ownerTag == null || !ownerTag.equals(this.ownerTag)) {
            return false;
        }
        return id.equals(mediaStreamId);
    }

    public boolean checkVideoTrack(String id, String ownerTag) {
        if (null == id || null == videoTrackId || ownerTag == null || !ownerTag.equals(this.ownerTag)) {
            return false;
        }
        return id.equals(videoTrackId);
    }
}
