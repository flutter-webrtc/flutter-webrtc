package com.cloudwebrtc.webrtc.record;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.ImageFormat;
import android.graphics.Matrix;
import android.graphics.Rect;
import android.graphics.YuvImage;
import android.os.Handler;
import android.os.Looper;

import org.webrtc.VideoFrame;
import org.webrtc.VideoSink;
import org.webrtc.VideoTrack;
import org.webrtc.YuvHelper;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.Arrays;

import io.flutter.plugin.common.MethodChannel;

public class FrameCapturer implements VideoSink {
    private final VideoTrack videoTrack;
    private File file;
    private final MethodChannel.Result callback;
    private boolean gotFrame = false;

    public FrameCapturer(VideoTrack track, File file, MethodChannel.Result callback) {
        videoTrack = track;
        this.file = file;
        this.callback = callback;
        track.addSink(this);
    }

    @Override
    public void onFrame(VideoFrame videoFrame) {
        if (gotFrame)
            return;
        gotFrame = true;
        videoFrame.retain();
        VideoFrame.Buffer buffer = videoFrame.getBuffer();
        VideoFrame.I420Buffer i420Buffer = buffer.toI420();
        ByteBuffer y = i420Buffer.getDataY();
        ByteBuffer u = i420Buffer.getDataU();
        ByteBuffer v = i420Buffer.getDataV();
        int width = i420Buffer.getWidth();
        int height = i420Buffer.getHeight();
        int[] strides = new int[] {
            i420Buffer.getStrideY(),
            i420Buffer.getStrideU(),
            i420Buffer.getStrideV()
        };
        final int chromaWidth = (width + 1) / 2;
        final int chromaHeight = (height + 1) / 2;
        final int minSize = width * height + chromaWidth * chromaHeight * 2;

        ByteBuffer yuvBuffer = ByteBuffer.allocateDirect(minSize);
        // NV21 is the same as NV12, only that V and U are stored in the reverse oder
        // NV21 (YYYYYYYYY:VUVU)
        // NV12 (YYYYYYYYY:UVUV)
        // Therefore we can use the NV12 helper, but swap the U and V input buffers
        YuvHelper.I420ToNV12(y, strides[0], v, strides[2], u, strides[1], yuvBuffer, width, height);

        // For some reason the ByteBuffer may have leading 0. We remove them as
        // otherwise the
        // image will be shifted
        byte[] cleanedArray = Arrays.copyOfRange(yuvBuffer.array(), yuvBuffer.arrayOffset(), minSize);

        YuvImage yuvImage = new YuvImage(
            cleanedArray,
            ImageFormat.NV21,
            width,
            height,
            // We omit the strides here. If they were included, the resulting image would
            // have its colors offset.
            null);
        i420Buffer.release();
        videoFrame.release();
        new Handler(Looper.getMainLooper()).post(() -> {
            videoTrack.removeSink(this);
        });
        try {
            if (!file.exists()) {
                //noinspection ResultOfMethodCallIgnored
                file.getParentFile().mkdirs();
                //noinspection ResultOfMethodCallIgnored
                file.createNewFile();
            }
        } catch (IOException io) {
            callback.error("IOException", io.getLocalizedMessage(), io);
            return;
        }
        try (FileOutputStream outputStream = new FileOutputStream(file)) {
            yuvImage.compressToJpeg(
                new Rect(0, 0, width, height),
                100,
                outputStream
            );
            switch (videoFrame.getRotation()) {
                case 0:
                    break;
                case 90:
                case 180:
                case 270:
                    Bitmap original = BitmapFactory.decodeFile(file.toString());
                    Matrix matrix = new Matrix();
                    matrix.postRotate(videoFrame.getRotation());
                    Bitmap rotated = Bitmap.createBitmap(original, 0, 0, original.getWidth(), original.getHeight(), matrix, true);
                    FileOutputStream rotatedOutputStream = new FileOutputStream(file);
                    rotated.compress(Bitmap.CompressFormat.JPEG, 100, rotatedOutputStream);
                    break;
                default:
                    // Rotation is checked to always be 0, 90, 180 or 270 by VideoFrame
                    throw new RuntimeException("Invalid rotation");
            }
            callback.success(null);
        } catch (IOException io) {
            callback.error("IOException", io.getLocalizedMessage(), io);
        } catch (IllegalArgumentException iae) {
            callback.error("IllegalArgumentException", iae.getLocalizedMessage(), iae);
        } finally {
            file = null;
        }
    }
}
