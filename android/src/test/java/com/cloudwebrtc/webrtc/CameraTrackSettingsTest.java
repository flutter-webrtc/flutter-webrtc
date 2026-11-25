package com.cloudwebrtc.webrtc;

import static org.junit.Assert.assertEquals;

import com.cloudwebrtc.webrtc.utils.ConstraintsMap;
import com.cloudwebrtc.webrtc.video.VideoCapturerInfo;
import org.junit.Test;
import org.webrtc.Size;

public final class CameraTrackSettingsTest {
    @Test
    public void reportsTheRequestedOutputDimensionsForANormalizedCamera() {
        VideoCapturerInfo camera = new VideoCapturerInfo();
        camera.width = 640;
        camera.height = 480;
        camera.fps = 15;

        ConstraintsMap settings = GetUserMediaImpl.cameraTrackSettings(
                camera, "front", "user", new Size(1280, 720));
        assertEquals(1280, settings.getInt("width"));
        assertEquals(720, settings.getInt("height"));
        assertEquals(15, settings.getInt("frameRate"));

        ConstraintsMap fallback = GetUserMediaImpl.cameraTrackSettings(camera, "front", "user", null);
        assertEquals(640, fallback.getInt("width"));
        assertEquals(480, fallback.getInt("height"));
    }
}
