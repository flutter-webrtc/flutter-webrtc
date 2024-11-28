package com.cloudwebrtc.webrtc.audio;

import org.webrtc.audio.JavaAudioDeviceModule;

import java.util.ArrayList;
import java.util.List;

public class RecordSamplesReadyCallbackAdapter
        implements JavaAudioDeviceModule.SamplesReadyCallback {
    public RecordSamplesReadyCallbackAdapter() {}

    List<JavaAudioDeviceModule.SamplesReadyCallback> callbacks = new ArrayList<>();

    public void addCallback(JavaAudioDeviceModule.SamplesReadyCallback callback) {
        synchronized (callbacks) {
            callbacks.add(callback);
        }
    }

    public void removeCallback(JavaAudioDeviceModule.SamplesReadyCallback callback) {
        synchronized (callbacks) {
            callbacks.remove(callback);
        }
    }

    @Override
    public void onWebRtcAudioRecordSamplesReady(JavaAudioDeviceModule.AudioSamples audioSamples) {
        synchronized (callbacks) {
            for (JavaAudioDeviceModule.SamplesReadyCallback callback : callbacks) {
                callback.onWebRtcAudioRecordSamplesReady(audioSamples);
            }
        }
    }
}
