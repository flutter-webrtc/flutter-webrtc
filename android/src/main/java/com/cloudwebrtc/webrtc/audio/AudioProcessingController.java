package com.cloudwebrtc.webrtc.audio;

import org.webrtc.ExternalAudioProcessingFactory;

public class AudioProcessingController {
    AudioProcessingAdapter capturePostProcessing = new AudioProcessingAdapter();

    AudioProcessingAdapter renderPreProcessing = new AudioProcessingAdapter();

    public AudioProcessingController(ExternalAudioProcessingFactory externalAudioProcessingFactory) {
        this.externalAudioProcessingFactory = externalAudioProcessingFactory;
        this.externalAudioProcessingFactory.setCapturePostProcessing(capturePostProcessing);
        this.externalAudioProcessingFactory.setRenderPreProcessing(renderPreProcessing);
    }
    ExternalAudioProcessingFactory externalAudioProcessingFactory;
}
