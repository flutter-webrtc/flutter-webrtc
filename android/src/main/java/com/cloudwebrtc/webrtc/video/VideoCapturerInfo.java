package com.cloudwebrtc.webrtc.video;

import org.webrtc.VideoCapturer;

public class VideoCapturerInfo {
    public VideoCapturer capturer;
    public int width;
    public int height;
    public int fps;
    public boolean isScreenCapture = false;
    public String cameraName;
}