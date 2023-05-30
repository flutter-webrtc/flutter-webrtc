package com.cloudwebrtc.webrtc.utils;

import com.cloudwebrtc.webrtc.utils.RTCVideoFrameFormat;

public class ExportFrame{
    public boolean enabledExportFrame;
    public int frameCount;
    public RTCVideoFrameFormat format;
    public ExportFrame(boolean enabledExportFrame, int frameCount, RTCVideoFrameFormat format){
        this.enabledExportFrame = enabledExportFrame;
        this.frameCount = frameCount;
        this.format = format;
    }
}