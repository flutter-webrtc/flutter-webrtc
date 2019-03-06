package com.cloudwebrtc.webrtc.record;

import androidx.annotation.Nullable;
import android.util.Log;

import com.cloudwebrtc.webrtc.utils.EglUtils;

import org.webrtc.VideoTrack;

import java.io.File;

public class MediaRecorderImpl {

    private final Integer id;
    private final VideoTrack videoTrack;
    private final AudioSamplesInterceptor audioInterceptor;
    private VideoFileRenderer videoFileRenderer;
    private boolean isRunning = false;
    private File recordFile;

    public MediaRecorderImpl(Integer id, @Nullable VideoTrack videoTrack, @Nullable AudioSamplesInterceptor audioInterceptor) {
        this.id = id;
        this.videoTrack = videoTrack;
        this.audioInterceptor = audioInterceptor;
    }

    public void startRecording(File file) throws Exception {
        recordFile = file;
        if (isRunning)
            return;
        isRunning = true;
        //noinspection ResultOfMethodCallIgnored
        file.getParentFile().mkdirs();
        if (videoTrack != null) {
            videoFileRenderer = new VideoFileRenderer(
                file.getAbsolutePath(),
                EglUtils.getRootEglBaseContext(),
                audioInterceptor != null
            );
            videoTrack.addSink(videoFileRenderer);
            if (audioInterceptor != null)
                audioInterceptor.attachCallback(id, videoFileRenderer);
        } else {
            Log.e(TAG, "Video track is null");
            if (audioInterceptor != null) {
                //TODO(rostopira): audio only recording
                throw new Exception("Audio-only recording not implemented yet");
            }
        }
    }

    public File getRecordFile() { return recordFile; }

    public void stopRecording() {
        isRunning = false;
        if (audioInterceptor != null)
            audioInterceptor.detachCallback(id);
        if (videoTrack != null && videoFileRenderer != null) {
            videoTrack.removeSink(videoFileRenderer);
            videoFileRenderer.release();
            videoFileRenderer = null;
        }
    }

    private static final String TAG = "MediaRecorderImpl";

}
