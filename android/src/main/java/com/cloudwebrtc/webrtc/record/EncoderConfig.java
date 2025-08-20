package com.cloudwebrtc.webrtc.record;

class EncoderConfig {
    final int width;
    final int height;
    final int bitrate;
    final int profile;

    EncoderConfig(int width, int height, int bitrate, int profile) {
        this.width = width;
        this.height = height;
        this.bitrate = bitrate;
        this.profile = profile;
    }

    @Override
    public String toString() {
        return width + "x" + height + ", bitrate: " + bitrate + ", profile: " + profile;
    }
}