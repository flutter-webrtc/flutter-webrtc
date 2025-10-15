package com.cloudwebrtc.webrtc.record;

import androidx.annotation.Nullable;
import android.util.Log;

import com.cloudwebrtc.webrtc.utils.EglUtils;

import org.webrtc.VideoTrack;

import java.io.File;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class MediaRecorderImpl {

    private final Integer id;
    private final VideoTrack videoTrack;
    private final AudioSamplesInterceptor audioInterceptor;
    private VideoFileRenderer videoFileRenderer;
    private AudioFileRenderer audioFileRenderer;
    private boolean isRunning = false;
    private File recordFile;

    public MediaRecorderImpl(Integer id, @Nullable VideoTrack videoTrack,
            @Nullable AudioSamplesInterceptor audioInterceptor) {
        this.id = id;
        this.videoTrack = videoTrack;
        this.audioInterceptor = audioInterceptor;
    }

    public void startRecording(File file) throws Exception {
        recordFile = file;
        if (isRunning)
            return;
        isRunning = true;
        // noinspection ResultOfMethodCallIgnored
        file.getParentFile().mkdirs();
        if (videoTrack != null) {
            videoFileRenderer = new VideoFileRenderer(
                    file.getAbsolutePath(),
                    EglUtils.getRootEglBaseContext(),
                    audioInterceptor != null);
            videoTrack.addSink(videoFileRenderer);
            if (audioInterceptor != null)
                audioInterceptor.attachCallback(id, videoFileRenderer);
        } else {
            Log.d(TAG, "Video track is null - checking for audio-only recording");
            if (audioInterceptor != null) {
                // Audio-only recording implementation
                audioFileRenderer = new AudioFileRenderer(file.getAbsolutePath());
                audioInterceptor.attachCallback(id, audioFileRenderer);
            } else {
                throw new Exception("Both video track and audio interceptor are null - cannot record");
            }
        }
    }

    public File getRecordFile() {
        return recordFile;
    }

    private final ExecutorService releaseExecutor = Executors.newSingleThreadExecutor();

    public void stopRecording(Runnable onStopped) {
        isRunning = false;
        if (audioInterceptor != null)
            audioInterceptor.detachCallback(id);
        if (videoTrack != null && videoFileRenderer != null) {
            videoTrack.removeSink(videoFileRenderer);
            releaseExecutor.submit(() -> {
                videoFileRenderer.release();
                videoFileRenderer = null;
                if (onStopped != null)
                    onStopped.run();
                releaseExecutor.shutdown(); // libera o executor
            });
        } else {
            if (onStopped != null)
                onStopped.run();
            releaseExecutor.shutdown();
        }
        if (audioFileRenderer != null) {
            audioFileRenderer.release();
            audioFileRenderer = null;
        }
    }

    private static final String TAG = "MediaRecorderImpl";

}
