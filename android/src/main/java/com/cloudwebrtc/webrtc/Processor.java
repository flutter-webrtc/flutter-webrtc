package com.cloudwebrtc.webrtc;
import org.webrtc.VideoFrame;
public interface Processor {
    VideoFrame applyEffect(VideoFrame frame);
}
