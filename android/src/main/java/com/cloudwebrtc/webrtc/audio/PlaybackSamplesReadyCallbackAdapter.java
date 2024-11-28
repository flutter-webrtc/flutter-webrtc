package com.cloudwebrtc.webrtc.audio;

import org.webrtc.audio.JavaAudioDeviceModule;

import java.util.ArrayList;
import java.util.List;

public class PlaybackSamplesReadyCallbackAdapter
        implements JavaAudioDeviceModule.PlaybackSamplesReadyCallback {
    public PlaybackSamplesReadyCallbackAdapter() {}

    List<JavaAudioDeviceModule.PlaybackSamplesReadyCallback> callbacks = new ArrayList<>();

    public void addCallback(JavaAudioDeviceModule.PlaybackSamplesReadyCallback callback) {
        synchronized (callbacks) {
            callbacks.add(callback);
        }
    }

    public void removeCallback(JavaAudioDeviceModule.PlaybackSamplesReadyCallback callback) {
        synchronized (callbacks) {
            callbacks.remove(callback);
        }
    }

    @Override
    public void onWebRtcAudioTrackSamplesReady(JavaAudioDeviceModule.AudioSamples audioSamples) {
        for (JavaAudioDeviceModule.PlaybackSamplesReadyCallback callback : callbacks) {
            callback.onWebRtcAudioTrackSamplesReady(audioSamples);
        }
    }
}
