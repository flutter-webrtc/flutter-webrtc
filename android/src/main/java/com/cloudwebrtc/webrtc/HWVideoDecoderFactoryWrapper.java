package com.cloudwebrtc.webrtc;

import android.media.MediaCodecInfo;

import androidx.annotation.Nullable;

import org.webrtc.DefaultVideoDecoderFactory;
import org.webrtc.EglBase;
import org.webrtc.HardwareVideoDecoderFactory;
import org.webrtc.PlatformSoftwareVideoDecoderFactory;
import org.webrtc.SoftwareVideoDecoderFactory;
import org.webrtc.VideoCodecInfo;
import org.webrtc.VideoDecoder;
import org.webrtc.VideoDecoderFactory;
import org.webrtc.VideoDecoderFallback;

import java.util.Arrays;
import java.util.LinkedHashSet;

public class HWVideoDecoderFactoryWrapper implements VideoDecoderFactory {
    public HWVideoDecoderFactoryWrapper(@Nullable EglBase.Context eglContext) {
        this.hardwareVideoDecoderFactory = new HardwareVideoDecoderFactory(eglContext);
        this.platformSoftwareVideoDecoderFactory = new PlatformSoftwareVideoDecoderFactory(eglContext);
    }

    private final VideoDecoderFactory hardwareVideoDecoderFactory;
    private final VideoDecoderFactory hardwareVideoDecoderFactoryWithoutEglContext = new HardwareVideoDecoderFactory(null)   ;
    private final VideoDecoderFactory softwareVideoDecoderFactory = new SoftwareVideoDecoderFactory();
    @Nullable
    private final VideoDecoderFactory platformSoftwareVideoDecoderFactory;

    @Nullable
    public VideoDecoder createDecoder(VideoCodecInfo codecType) {
        VideoDecoder softwareDecoder = this.softwareVideoDecoderFactory.createDecoder(codecType);
        VideoDecoder hardwareDecoder = this.hardwareVideoDecoderFactory.createDecoder(codecType);
        if (softwareDecoder == null && this.platformSoftwareVideoDecoderFactory != null) {
            softwareDecoder = this.platformSoftwareVideoDecoderFactory.createDecoder(codecType);
        }

        if(hardwareDecoder != null && disableSurfaceTextureFrame(hardwareDecoder.getImplementationName())) {
            hardwareDecoder.release();
            hardwareDecoder = this.hardwareVideoDecoderFactoryWithoutEglContext.createDecoder(codecType);
        }

        if (hardwareDecoder != null && softwareDecoder != null) {
            return new VideoDecoderFallback(softwareDecoder, hardwareDecoder);
        } else {
            return hardwareDecoder != null ? hardwareDecoder : softwareDecoder;
        }
    }

    private boolean disableSurfaceTextureFrame(String name) {
        if (name.startsWith("OMX.qcom.") || name.startsWith("OMX.hisi.")) {
            return true;
        }
        return false;
    }

    public VideoCodecInfo[] getSupportedCodecs() {
        LinkedHashSet<VideoCodecInfo> supportedCodecInfos = new LinkedHashSet();
        supportedCodecInfos.addAll(Arrays.asList(this.softwareVideoDecoderFactory.getSupportedCodecs()));
        supportedCodecInfos.addAll(Arrays.asList(this.hardwareVideoDecoderFactory.getSupportedCodecs()));
        if (this.platformSoftwareVideoDecoderFactory != null) {
            supportedCodecInfos.addAll(Arrays.asList(this.platformSoftwareVideoDecoderFactory.getSupportedCodecs()));
        }

        return (VideoCodecInfo[])supportedCodecInfos.toArray(new VideoCodecInfo[supportedCodecInfos.size()]);
    }
}
