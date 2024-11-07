package com.cloudwebrtc.webrtc.audio;

import org.webrtc.ExternalAudioProcessingFactory;

public class AudioProcessingController {
    /**
     * This is the audio processing module that will be applied to the audio stream after it is captured from the microphone.
     * This is useful for adding echo cancellation, noise suppression, etc.
     */
    public final AudioProcessingAdapter capturePostProcessing = new AudioProcessingAdapter();
    /**
     * This is the audio processing module that will be applied to the audio stream before it is rendered to the speaker.
     */
    public final AudioProcessingAdapter renderPreProcessing = new AudioProcessingAdapter();

    public ExternalAudioProcessingFactory externalAudioProcessingFactory;

    public AudioProcessingController() {
        this.externalAudioProcessingFactory = new ExternalAudioProcessingFactory();
        this.externalAudioProcessingFactory.setCapturePostProcessing(capturePostProcessing);
        this.externalAudioProcessingFactory.setRenderPreProcessing(renderPreProcessing);
    }
    
}
