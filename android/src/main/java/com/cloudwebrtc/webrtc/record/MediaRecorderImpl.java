package com.cloudwebrtc.webrtc.record;

import android.support.annotation.Nullable;
import android.util.Log;

import com.cloudwebrtc.webrtc.utils.EglUtils;

import org.webrtc.VideoTrack;

import java.io.File;
import java.io.IOException;

public class MediaRecorderImpl {

    private final Integer id;
    private final VideoTrack videoTrack;
    private final AudioSamplesInterceptor audioInterceptor;
    private VideoFileRenderer videoFileRenderer;

    public MediaRecorderImpl(Integer id, @Nullable VideoTrack videoTrack, @Nullable AudioSamplesInterceptor audioInterceptor) {
        this.id = id;
        this.videoTrack = videoTrack;
        this.audioInterceptor = audioInterceptor;
    }

    public void startRecording(File file) throws IOException {
        //noinspection ResultOfMethodCallIgnored
        file.getParentFile().mkdirs();
        if (videoTrack != null) {
            videoFileRenderer = new VideoFileRenderer(file.getAbsolutePath(), 1280, 720, EglUtils.getRootEglBaseContext());
            videoTrack.addSink(videoFileRenderer);
            if (audioInterceptor != null)
                audioInterceptor.attachCallback(id, videoFileRenderer);
        } else {
            Log.e(TAG, "Video track is null");
            if (audioInterceptor != null) {
                //TODO(rostopira): audio only recording
            }
        }
    }

    public void stopRecording() {
        if (videoTrack != null && videoFileRenderer != null) {
            videoTrack.removeSink(videoFileRenderer);
            videoFileRenderer.release();
        }
        if (audioInterceptor != null)
            audioInterceptor.detachCallback(id);
    }

    private static final String TAG = "MediaRecorderImpl";

}
