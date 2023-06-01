package com.cloudwebrtc.webrtc.utils;

import com.cloudwebrtc.webrtc.utils.VideoFrameTransform;

public class ExportFrame{
    public boolean enabledExportFrame;
    public int frameCount;
    public VideoFrameTransform.RTCVideoFrameFormat format;
    public ExportFrame(boolean enabledExportFrame, int frameCount, VideoFrameTransform.RTCVideoFrameFormat format){
        this.enabledExportFrame = enabledExportFrame;
        this.frameCount = frameCount;
        this.format = format;
    }
}