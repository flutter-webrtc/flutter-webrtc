package com.cloudwebrtc.webrtc.video.custom;

import androidx.annotation.Nullable;

import org.webrtc.VideoCapturer;

import java.util.Map;

/**
 * A {@link VideoCapturer} supplied by the application to feed externally
 * composited frames (e.g. ARCore camera + overlay) into a local video track.
 * Render into the SurfaceTexture of the SurfaceTextureHelper received in
 * {@link VideoCapturer#initialize} for zero-copy OES texture frames.
 */
public interface CustomVideoCapturer extends VideoCapturer {
    /**
     * Handles an application-defined command routed from Dart via the
     * "customVideoSourceCommand" method channel call. Invoked directly on the
     * method-channel caller thread; off-loading heavy work is the
     * implementer's responsibility.
     *
     * @throws UnsupportedOperationException if the command is not supported.
     */
    @Nullable
    Object handleCommand(String command, Map<String, Object> args) throws Exception;
}
