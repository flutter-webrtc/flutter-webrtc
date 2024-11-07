package com.cloudwebrtc.webrtc.video;

import androidx.annotation.Nullable;

import com.cloudwebrtc.webrtc.LocalTrack;

import org.webrtc.VideoFrame;
import org.webrtc.VideoProcessor;
import org.webrtc.VideoSink;
import org.webrtc.VideoTrack;

public class LocalVideoTrack extends LocalTrack implements VideoProcessor {
    public LocalVideoTrack(VideoTrack videoTrack) {
        super(videoTrack);
    }
    
    private VideoSink sink = null;

    @Override
    public void setSink(@Nullable VideoSink videoSink) {
        sink = videoSink;
    }

    @Override
    public void onCapturerStarted(boolean b) {

    }

    @Override
    public void onCapturerStopped() {

    }

    @Override
    public void onFrameCaptured(VideoFrame videoFrame) {
        if (sink != null) {
            sink.onFrame(videoFrame);
        }
    }
}
