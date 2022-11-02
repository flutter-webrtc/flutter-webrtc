package com.cloudwebrtc.webrtc;

import android.util.Log;

import org.webrtc.PeerConnection;
import org.webrtc.PeerConnectionFactory;
import org.webrtc.VideoFrame;
import org.webrtc.VideoSink;
import org.webrtc.VideoSource;
import org.webrtc.VideoTrack;

import java.util.Collections;

public class TrackFrameCapturer implements VideoSink {

    private final VideoSource subVideoSource;

    private boolean isInit;

    public TrackFrameCapturer(VideoTrack videoTrack, PeerConnection peerConnection, PeerConnectionFactory peerConnectionFactory, String streamId) {
        subVideoSource = peerConnectionFactory.createVideoSource(false);
        VideoTrack subVideoTrack = peerConnectionFactory.createVideoTrack(videoTrack.id(), subVideoSource);
        peerConnection.addTrack(subVideoTrack, Collections.singletonList(streamId));
        videoTrack.addSink(this);
    }

    @Override
    public void onFrame(VideoFrame videoFrame) {
        if (!isInit) {
            subVideoSource.adaptOutputFormat(videoFrame.getRotatedWidth() / 4, videoFrame.getRotatedHeight() / 4, 15);
            isInit = true;
            Log.d("TAG", "sub stream add success");
        }
        subVideoSource.getCapturerObserver().onFrameCaptured(videoFrame);
    }

}
