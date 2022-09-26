package org.webrtc;

public class SimulcastVideoEncoder extends WrappedNativeVideoEncoder {

    static native long nativeCreateEncoder(VideoEncoderFactory primary, VideoEncoderFactory fallback, VideoCodecInfo info);

    VideoEncoderFactory primary;
    VideoEncoderFactory fallback;
    VideoCodecInfo info;

    public SimulcastVideoEncoder(VideoEncoderFactory primary, VideoEncoderFactory fallback, VideoCodecInfo info) {
        this.primary = primary;
        this.fallback = fallback;
        this.info = info;
    }

    @Override
    public long createNativeVideoEncoder() {
        return nativeCreateEncoder(primary, fallback, info);
    }

    @Override
    public boolean isHardwareEncoder() {
        return false;
    }

}

