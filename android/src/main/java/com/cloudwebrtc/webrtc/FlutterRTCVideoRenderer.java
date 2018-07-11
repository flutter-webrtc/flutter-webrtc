package com.cloudwebrtc.webrtc;

import android.content.Context;
import android.util.Log;
import android.graphics.SurfaceTexture;

import com.cloudwebrtc.webrtc.utils.ConstraintsMap;
import com.cloudwebrtc.webrtc.utils.EglUtils;

import java.util.List;

import org.webrtc.EglBase;
import org.webrtc.MediaStream;
import org.webrtc.RendererCommon.RendererEvents;
import org.webrtc.VideoRenderer;
import org.webrtc.VideoTrack;

import io.flutter.plugin.common.EventChannel;

public class FlutterRTCVideoRenderer implements  EventChannel.StreamHandler {

    private static final String TAG = FlutterWebRTCPlugin.TAG;
    private final SurfaceTexture texture;
    private final Context context;
    private int id = -1;

    public void Dispose(){
        //destroy
        if(surfaceTextureRenderer != null) {
            surfaceTextureRenderer.release();
        }
        if(eventChannel != null)
            eventChannel.setStreamHandler(null);

        eventSink = null;
    }

    /**
     * The {@code RendererEvents} which listens to rendering events reported by
     * {@link #surfaceTextureRenderer}.
     */
    private final RendererEvents rendererEvents
        = new RendererEvents() {
            private int _rotation = 0;
            private  int _width = 0, _height = 0;

            @Override
            public void onFirstFrameRendered() {
                ConstraintsMap params = new ConstraintsMap();
                params.putString("event", "didFirstFrameRendered");
                params.putInt("id", id);
                eventSink.success(params.toMap());
            }

            @Override
            public void onFrameResolutionChanged(
                    int videoWidth, int videoHeight,
                    int rotation) {

                if(eventSink != null)
                {
                    if(_width != videoWidth || _height != videoHeight){
                        ConstraintsMap params = new ConstraintsMap();
                        params.putString("event", "didTextureChangeVideoSize");
                        params.putInt("id", id);

                        if(rotation == 90 || rotation == 270){
                            params.putDouble("width", (double) videoHeight);
                            params.putDouble("height", (double) videoWidth);
                        }else {
                            params.putDouble("width", (double) videoWidth);
                            params.putDouble("height", (double) videoHeight);
                        }
                        _width = videoWidth;
                        _height = videoHeight;
                        eventSink.success(params.toMap());
                    }

                    if(_rotation != rotation){
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

    private SurfaceTextureRenderer surfaceTextureRenderer;

    /**
     * The {@code VideoRenderer}, if any, which renders {@link #videoTrack} on
     * this {@code View}.
     */
    private VideoRenderer videoRenderer;

    /**
     * The {@code VideoTrack}, if any, rendered by this {@code FlutterRTCVideoRenderer}.
     */
    private VideoTrack videoTrack;

    EventChannel eventChannel;
    EventChannel.EventSink eventSink;

    public FlutterRTCVideoRenderer(SurfaceTexture texture, Context context) {
        this.surfaceTextureRenderer = new SurfaceTextureRenderer(context, texture);
        this.texture = texture;
        this.context = context;
        this.eventSink = null;
    }

    public void setEventChannel(EventChannel eventChannel){
        this.eventChannel = eventChannel;
    }

    public void setId(int id){
        this.id = id;
    }

    @Override
    public void onListen(Object o, EventChannel.EventSink sink) {
        eventSink = sink;
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
        if (videoRenderer != null) {
            videoTrack.removeRenderer(videoRenderer);
            videoRenderer.dispose();
            videoRenderer = null;
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
            }else{

            }
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

            surfaceTextureRenderer.release();
            surfaceTextureRenderer = new SurfaceTextureRenderer(context, texture);
            surfaceTextureRenderer.init(sharedContext, rendererEvents);

            videoRenderer = new VideoRenderer(surfaceTextureRenderer);
            videoTrack.addRenderer(videoRenderer);
        }
    }
}
