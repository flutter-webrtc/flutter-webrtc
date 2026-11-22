package com.cloudwebrtc.webrtc.video;

import android.graphics.Matrix;

import androidx.annotation.Nullable;

import com.cloudwebrtc.webrtc.LocalTrack;

import org.webrtc.TextureBufferImpl;
import org.webrtc.VideoFrame;
import org.webrtc.VideoProcessor;
import org.webrtc.VideoSink;
import org.webrtc.VideoTrack;

import java.util.ArrayList;
import java.util.List;

public class LocalVideoTrack extends LocalTrack implements VideoProcessor {
    public interface ExternalVideoFrameProcessing {
        /**
         * Process a video frame. Called on the capture thread.
         *
         * Do not release {@code frame}. To replace it, return a new frame:
         * the track releases that frame once it has been delivered.
         * @param frame
         * @return The processed video frame, or {@code frame} itself.
         */
        public abstract VideoFrame onFrame(VideoFrame frame);
    }

    public LocalVideoTrack(VideoTrack videoTrack) {
        super(videoTrack);
    }

    List<ExternalVideoFrameProcessing> processors = new ArrayList<>();

    public void addProcessor(ExternalVideoFrameProcessing processor) {
        synchronized (processors) {
            processors.add(processor);
        }
    }

    public void removeProcessor(ExternalVideoFrameProcessing processor) {
        synchronized (processors) {
            processors.remove(processor);
        }
    }

    private VideoSink sink = null;

    @Override
    public void setSink(@Nullable VideoSink videoSink) {
        sink = videoSink;
    }

    @Override
    public void onCapturerStarted(boolean b) {}

    @Override
    public void onCapturerStopped() {}

    /** Bake rotation into the texture transform so source rotation need not convert it to I420. */
    @Nullable
    private static VideoFrame upright(VideoFrame frame) {
        int rotation = frame.getRotation();
        if (rotation == 0 || !(frame.getBuffer() instanceof TextureBufferImpl)) return null;
        TextureBufferImpl buffer = (TextureBufferImpl) frame.getBuffer();
        Matrix turn = new Matrix();
        turn.preTranslate(0.5f, 0.5f);
        turn.preRotate(rotation);
        turn.preTranslate(-0.5f, -0.5f);
        return new VideoFrame(
                buffer.applyTransformMatrix(turn, frame.getRotatedWidth(), frame.getRotatedHeight()),
                0, frame.getTimestampNs());
    }

    @Override
    public void onFrameCaptured(VideoFrame videoFrame) {
        if (sink != null) {
            VideoFrame turned = upright(videoFrame);
            VideoFrame frame = turned != null ? turned : videoFrame;
            synchronized (processors) {
                for (ExternalVideoFrameProcessing processor : processors) {
                    VideoFrame processed = processor.onFrame(frame);
                    // Release a frame made by an earlier processor once it is
                    // replaced. The capturer releases the original frame.
                    if (processed != frame && frame != videoFrame) {
                        frame.release();
                    }
                    frame = processed;
                }
            }
            sink.onFrame(frame);
            if (frame != videoFrame) {
                frame.release();
            }
        }
    }
}
