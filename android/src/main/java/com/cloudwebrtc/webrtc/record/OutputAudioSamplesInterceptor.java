package com.cloudwebrtc.webrtc.record;

import org.webrtc.audio.JavaAudioDeviceModule;
import org.webrtc.audio.WebRtcAudioTrackUtils;

public class OutputAudioSamplesInterceptor extends AudioSamplesInterceptor {
    private final JavaAudioDeviceModule audioDeviceModule;

    public OutputAudioSamplesInterceptor(JavaAudioDeviceModule audioDeviceModule) {
        super();
        this.audioDeviceModule = audioDeviceModule;
    }

    @Override
    public void attachCallback(Integer id, JavaAudioDeviceModule.SamplesReadyCallback callback) throws Exception {
        if (callbacks.isEmpty())
            WebRtcAudioTrackUtils.attachOutputCallback(this, audioDeviceModule);
        super.attachCallback(id, callback);
    }

    @Override
    public void detachCallback(Integer id) {
        super.detachCallback(id);
        if (callbacks.isEmpty())
            WebRtcAudioTrackUtils.detachOutputCallback(audioDeviceModule);
    }
}
