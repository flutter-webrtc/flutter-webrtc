package com.cloudwebrtc.webrtc.audio;

import org.webrtc.ExternalAudioProcessingFactory;

import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.List;

public class AudioProcessingAdapter implements ExternalAudioProcessingFactory.AudioProcessing {
    public AudioProcessingAdapter() {
    }
    List<ExternalAudioProcessingFactory.AudioProcessing> audioProcessors = new ArrayList<>();

    public void addProcessor(ExternalAudioProcessingFactory.AudioProcessing audioProcessor) {
        synchronized (audioProcessors) {
            audioProcessors.add(audioProcessor);
        }
    }

    public void removeProcessor(ExternalAudioProcessingFactory.AudioProcessing audioProcessor) {
        synchronized (audioProcessors) {
            audioProcessors.remove(audioProcessor);
        }
    }

    @Override
    public void initialize(int i, int i1) {
        synchronized (audioProcessors) {
            for (ExternalAudioProcessingFactory.AudioProcessing audioProcessor : audioProcessors) {
                audioProcessor.initialize(i, i1);
            }
        }
    }

    @Override
    public void reset(int i) {
        synchronized (audioProcessors) {
            for (ExternalAudioProcessingFactory.AudioProcessing audioProcessor : audioProcessors) {
                audioProcessor.reset(i);
            }
        }
    }

    @Override
    public void process(int i, int i1, ByteBuffer byteBuffer) {
        synchronized (audioProcessors) {
            for (ExternalAudioProcessingFactory.AudioProcessing audioProcessor : audioProcessors) {
                audioProcessor.process(i, i1, byteBuffer);
            }
        }
    }
}
