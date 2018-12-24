package com.cloudwebrtc.webrtc.record;

import android.annotation.SuppressLint;

import org.webrtc.audio.JavaAudioDeviceModule.SamplesReadyCallback;
import org.webrtc.audio.JavaAudioDeviceModule.AudioSamples;

import java.util.HashMap;

/** JavaAudioDeviceModule allows attaching samples callback only on building
 *  We don't want to instantiate VideoFileRenderer and codecs at this step
 *  It's simple dummy class, it does nothing until samples are necessary */
public class AudioSamplesInterceptor implements SamplesReadyCallback {

    @SuppressLint("UseSparseArrays")
    private HashMap<Integer, SamplesReadyCallback> callbacks = new HashMap<>();
    public int currentAudioFormat = -1;
    public int currentChannelCount = -1;
    public int currentSampleRate = -1;

    @Override
    public void onWebRtcAudioRecordSamplesReady(AudioSamples audioSamples) {
        currentAudioFormat = audioSamples.getAudioFormat();
        currentChannelCount = audioSamples.getChannelCount();
        currentSampleRate = audioSamples.getSampleRate();
        for (SamplesReadyCallback callback : callbacks.values()) {
            callback.onWebRtcAudioRecordSamplesReady(audioSamples);
        }
    }

    public void attachCallback(Integer id, SamplesReadyCallback callback) {
        callbacks.put(id, callback);
    }

    public void detachCallback(Integer id) {
        callbacks.remove(id);
    }

}
