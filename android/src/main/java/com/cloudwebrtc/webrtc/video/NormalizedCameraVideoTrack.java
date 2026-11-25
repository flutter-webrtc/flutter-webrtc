package com.cloudwebrtc.webrtc.video;

import android.graphics.Matrix;
import androidx.annotation.Nullable;
import com.cloudwebrtc.webrtc.LocalTrack;
import java.util.Objects;
import org.webrtc.JavaI420Buffer;
import org.webrtc.Size;
import org.webrtc.TextureBufferImpl;
import org.webrtc.VideoFrame;
import org.webrtc.VideoProcessor.FrameAdaptationParameters;
import org.webrtc.VideoTrack;
import org.webrtc.YuvHelper;

/** Bakes frame rotation into the pixels, optionally cropping to a fixed output size. */
public final class NormalizedCameraVideoTrack extends LocalVideoTrack {
    @Nullable private final Size outputSize;

    public NormalizedCameraVideoTrack(VideoTrack track, @Nullable Size outputSize) {
        super(track);
        this.outputSize = outputSize;
    }

    public static final class CameraLayoutConflict extends RuntimeException {
        CameraLayoutConflict() {
            super("Camera is already in use with different orientation normalization settings");
        }
    }

    public static LocalVideoTrack forSharedCamera(VideoTrack track, LocalTrack primary) {
        return primary instanceof NormalizedCameraVideoTrack
                ? new NormalizedCameraVideoTrack(track, ((NormalizedCameraVideoTrack) primary).outputSize)
                : new LocalVideoTrack(track);
    }

    public static void requireCompatibleOutput(LocalTrack primary, boolean normalize, @Nullable Size size) {
        if (primary instanceof NormalizedCameraVideoTrack) {
            if (normalize && Objects.equals(((NormalizedCameraVideoTrack) primary).outputSize, size)) return;
        } else if (!normalize) {
            return;
        }
        throw new CameraLayoutConflict();
    }

    @Override
    public void onFrameCaptured(VideoFrame frame, FrameAdaptationParameters adaptation) {
        // WebRTC's default implementation applies a separate crop/scale before dispatch.
        // Use its pacing decision and translated clock, and crop the original camera FOV once.
        if (!adaptation.drop) deliver(frame, adaptation.timestampNs);
    }

    @Override
    public void onFrameCaptured(VideoFrame frame) {
        deliver(frame, frame.getTimestampNs());
    }

    private void deliver(VideoFrame frame, long timestampNs) {
        VideoFrame output = normalize(frame.getBuffer(), frame.getRotation(), timestampNs);
        try {
            super.onFrameCaptured(output);
        } finally {
            output.release();
        }
    }

    VideoFrame.Buffer prepareBuffer(VideoFrame.Buffer source, int rotation) {
        if (outputSize == null) {
            source.retain();
            return source;
        }
        // Rotate after cropping, so a quarter turn swaps the target's axes here.
        boolean quarterTurn = rotation % 180 != 0;
        int width = quarterTurn ? outputSize.height : outputSize.width;
        int height = quarterTurn ? outputSize.width : outputSize.height;
        if (source.getWidth() == width && source.getHeight() == height) {
            source.retain();
            return source;
        }
        int cropWidth = source.getWidth();
        int cropHeight = source.getHeight();
        if ((long) cropWidth * height > (long) cropHeight * width) {
            cropWidth = (int) ((long) cropHeight * width / height);
        } else {
            cropHeight = (int) ((long) cropWidth * height / width);
        }
        // Keep the crop aligned to the 2×2 chroma grid of 4:2:0 buffers.
        cropWidth = Math.max(1, cropWidth & ~1);
        cropHeight = Math.max(1, cropHeight & ~1);
        int x = (source.getWidth() - cropWidth) / 2 & ~1;
        int y = (source.getHeight() - cropHeight) / 2 & ~1;
        return source.cropAndScale(x, y, cropWidth, cropHeight, width, height);
    }

    private VideoFrame normalize(VideoFrame.Buffer frame, int rotation, long timestampNs) {
        VideoFrame.Buffer cropped = prepareBuffer(frame, rotation);
        if (rotation == 0) return new VideoFrame(cropped, 0, timestampNs);
        boolean quarterTurn = rotation % 180 != 0;
        int width = quarterTurn ? cropped.getHeight() : cropped.getWidth();
        int height = quarterTurn ? cropped.getWidth() : cropped.getHeight();
        try {
            if (cropped instanceof TextureBufferImpl) {
                // Match WebRTC VideoFrameDrawer's sampling-space rotation about texture center.
                // The resulting buffer retains its parent texture all the way through encoding.
                Matrix matrix = new Matrix();
                matrix.setRotate(rotation, 0.5f, 0.5f);
                VideoFrame.Buffer rotated = ((TextureBufferImpl) cropped).applyTransformMatrix(matrix, width, height);
                return new VideoFrame(rotated, 0, timestampNs);
            }
            return new VideoFrame(rotateI420(cropped, rotation, width, height), 0, timestampNs);
        } finally {
            cropped.release();
        }
    }

    private static VideoFrame.I420Buffer rotateI420(VideoFrame.Buffer src, int rotation, int width, int height) {
        VideoFrame.I420Buffer planes = src.toI420();
        try {
            JavaI420Buffer out = JavaI420Buffer.allocate(width, height);
            try {
                YuvHelper.I420Rotate(planes.getDataY(), planes.getStrideY(),
                        planes.getDataU(), planes.getStrideU(), planes.getDataV(), planes.getStrideV(),
                        out.getDataY(), out.getStrideY(), out.getDataU(), out.getStrideU(),
                        out.getDataV(), out.getStrideV(), planes.getWidth(), planes.getHeight(), rotation);
                return out;
            } catch (RuntimeException | Error failure) {
                out.release();
                throw failure;
            }
        } finally {
            planes.release();
        }
    }
}
