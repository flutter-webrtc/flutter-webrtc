package com.cloudwebrtc.webrtc.record;

import android.annotation.TargetApi;
import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;
import android.os.Build;

import org.webrtc.audio.JavaAudioDeviceModule.AudioSamples;
import org.webrtc.audio.JavaAudioDeviceModule.SamplesReadyCallback;

import java.nio.ByteBuffer;

import androidx.annotation.NonNull;

/**
 * Wrapper around audio track
 * Intercepts write calls and passes it to callback
 * **/
public final class AudioTrackInterceptor extends AudioTrack {
    final public AudioTrack originalTrack;
    final private SamplesReadyCallback callback;

    public AudioTrackInterceptor(@NonNull AudioTrack originalTrack, @NonNull SamplesReadyCallback callback) {
        // That just random params, we don't care about object that will be created
        super(
            AudioManager.STREAM_VOICE_CALL,
            44200,
            AudioFormat.CHANNEL_OUT_MONO,
            AudioFormat.ENCODING_PCM_16BIT,
            128,
            AudioTrack.MODE_STREAM
        );
        this.originalTrack = originalTrack;
        this.callback = callback;
    }

    @Override
    public int write(@NonNull byte[] audioData, int offsetInBytes, int sizeInBytes) {
        callback.onWebRtcAudioRecordSamplesReady(new AudioSamples(
            originalTrack.getAudioFormat(),
            originalTrack.getChannelCount(),
            originalTrack.getSampleRate(),
            audioData
        ));
        return originalTrack.write(audioData, offsetInBytes, sizeInBytes);
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    @Override
    public int write(@NonNull ByteBuffer audioData, int sizeInBytes, int writeMode) {
        byte[] trimmed = new byte[sizeInBytes];
        int position = audioData.position();
        audioData.get(trimmed, 0, sizeInBytes);
        audioData.position(position);
        callback.onWebRtcAudioRecordSamplesReady(new AudioSamples(
            originalTrack.getAudioFormat(),
            originalTrack.getChannelCount(),
            originalTrack.getSampleRate(),
            trimmed
        ));
        return originalTrack.write(audioData, sizeInBytes, writeMode);
    }

    /**
     * Override all required calls to mimic original track
     * https://webrtc.googlesource.com/src/+/master/sdk/android/src/java/org/webrtc/audio/WebRtcAudioTrack.java
     * **/

    @Override
    public int getPlayState() {
        return originalTrack.getPlayState();
    }

    @Override
    public void play() throws IllegalStateException {
        originalTrack.play();
    }

    @Override
    public void stop() throws IllegalStateException {
        originalTrack.stop();
    }

    @TargetApi(Build.VERSION_CODES.N)
    @Override
    public int getUnderrunCount() {
        return originalTrack.getUnderrunCount();
    }

    @TargetApi(Build.VERSION_CODES.N)
    @Override
    public int getBufferCapacityInFrames() {
        return originalTrack.getBufferCapacityInFrames();
    }

    @TargetApi(Build.VERSION_CODES.M)
    @Override
    public int getBufferSizeInFrames() {
        return originalTrack.getBufferSizeInFrames();
    }

    @Override
    public void release() {
        originalTrack.release();
    }

    @Override
    public int getPlaybackHeadPosition() {
        return originalTrack.getPlaybackHeadPosition();
    }
}
