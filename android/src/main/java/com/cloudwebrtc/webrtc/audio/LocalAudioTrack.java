package com.cloudwebrtc.webrtc.audio;

import android.media.AudioFormat;
import android.os.SystemClock;

import com.cloudwebrtc.webrtc.LocalTrack;

import org.webrtc.AudioTrack;
import org.webrtc.AudioTrackSink;
import org.webrtc.audio.JavaAudioDeviceModule;

import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.List;

/**
 * LocalAudioTrack represents an audio track that is sourced from local audio capture.
 */
public class LocalAudioTrack
        extends LocalTrack implements JavaAudioDeviceModule.SamplesReadyCallback {
    public LocalAudioTrack(AudioTrack audioTrack) {
        super(audioTrack);
    }

    final List<AudioTrackSink> sinks = new ArrayList<>();

    /**
     * Add a sink to receive audio data from this track.
     */
    public void addSink(AudioTrackSink sink) {
        synchronized (sinks) {
            sinks.add(sink);
        }
    }

    /**
     * Remove a sink for this track.
     */
    public void removeSink(AudioTrackSink sink) {
        synchronized (sinks) {
            sinks.remove(sink);
        }
    }

    private int getBytesPerSample(int audioFormat) {
        switch (audioFormat) {
            case AudioFormat.ENCODING_PCM_8BIT:
                return 1;
            case AudioFormat.ENCODING_PCM_16BIT:
            case AudioFormat.ENCODING_IEC61937:
            case AudioFormat.ENCODING_DEFAULT:
                return 2;
            case AudioFormat.ENCODING_PCM_FLOAT:
                return 4;
            default:
                throw new IllegalArgumentException("Bad audio format " + audioFormat);
        }
    }

    @Override
    public void onWebRtcAudioRecordSamplesReady(JavaAudioDeviceModule.AudioSamples audioSamples) {
        int bitsPerSample = getBytesPerSample(audioSamples.getAudioFormat()) * 8;
        int numFrames = audioSamples.getSampleRate() / 100;
        long timestamp = SystemClock.elapsedRealtime();
        synchronized (sinks) {
            for (AudioTrackSink sink : sinks) {
                ByteBuffer byteBuffer = ByteBuffer.wrap(audioSamples.getData());
                sink.onData(byteBuffer, bitsPerSample, audioSamples.getSampleRate(),
                        audioSamples.getChannelCount(), numFrames, timestamp);
            }
        }
    }
}
