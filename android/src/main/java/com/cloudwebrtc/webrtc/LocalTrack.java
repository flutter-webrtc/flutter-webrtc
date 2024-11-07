package com.cloudwebrtc.webrtc;

import org.webrtc.MediaStreamTrack;

public class LocalTrack {
    public LocalTrack(MediaStreamTrack track) {
        this.track = track;
    }

    public MediaStreamTrack track;

    public void dispose() {
        track.dispose();
    }

    public boolean enabled() {
        return track.enabled();
    }

    public void setEnabled(boolean enabled) {
        track.setEnabled(enabled);
    }

    public String id() {
        return track.id();
    }

    public String kind() {
        return track.kind();
    }
}
