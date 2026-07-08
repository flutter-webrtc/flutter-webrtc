package com.cloudwebrtc.webrtc;

import org.webrtc.VideoTrack;
import org.webrtc.PeerConnectionFactory;

public interface VideoTrackFactory {
    VideoTrack videoTrackNamed(String name, PeerConnectionFactory factory);
}
