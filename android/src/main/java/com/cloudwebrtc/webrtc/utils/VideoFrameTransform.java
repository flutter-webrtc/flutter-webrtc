package com.cloudwebrtc.webrtc.utils;

import android.graphics.Rect;
import android.graphics.YuvImage;
import android.graphics.ImageFormat;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.util.Log;

import org.webrtc.VideoFrame;
import org.webrtc.YuvHelper;

import java.nio.ByteBuffer;
import java.util.Arrays;
import java.io.ByteArrayOutputStream;

public class VideoFrameTransform {
    PhotographFormat i420Data;
    int rotation;
    public static enum RTCVideoFrameFormat {
        KI420,
        KRGBA,
        KMJPEG
    }
    public static class PhotographFormat {
        public RTCVideoFrameFormat format;
        public byte[] data;
        public int width;
        public int height;
        public PhotographFormat(byte[] data, int width, int height, RTCVideoFrameFormat format){
            this.data = data;
            this.width = width;
            this.height = height;
            this.format = format;
        }
    }

    VideoFrameTransform(VideoFrame videoFrame){
        i420Data = videoFrameToI420(videoFrame);
        rotation = videoFrame.getRotation();
    }

    public static PhotographFormat transform(VideoFrame videoFrame, RTCVideoFrameFormat format){
        VideoFrameTransform videoFrameTransform = new VideoFrameTransform(videoFrame);
        switch(format) {
                case KI420:
                    return videoFrameTransform.i420Data;
                case KRGBA:
                    return videoFrameTransform.I420ToRGBA();
                case KMJPEG:
                    return videoFrameTransform.I420ToJPEG();
                default:
                    return videoFrameTransform.i420Data;
        }
    }

    PhotographFormat videoFrameToI420(VideoFrame videoFrame) {
        VideoFrame.I420Buffer i420Buffer = videoFrame.getBuffer().toI420();
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
        YuvHelper.I420ToNV12(y, strides[0], v, strides[2], u, strides[1], yuvBuffer,
            width, height);
        byte[] NV12Array = Arrays.copyOfRange(yuvBuffer.array(),
            yuvBuffer.arrayOffset(), minSize);
        i420Buffer.release();

        return new PhotographFormat(NV12Array, width, height, RTCVideoFrameFormat.KI420);
    }
    PhotographFormat I420ToRGBA(){
        PhotographFormat jpegData = I420ToJPEG();
        ByteBuffer buffer = ByteBuffer.allocate(jpegData.width * jpegData.height * 4);
        Bitmap bitmap = BitmapFactory.decodeByteArray(jpegData.data, 0, jpegData.data.length);
        bitmap.copyPixelsToBuffer(buffer);
        byte[] rgbaData = buffer.array();
        return new PhotographFormat(rgbaData, jpegData.width, jpegData.height, RTCVideoFrameFormat.KRGBA);
    }

    PhotographFormat I420ToJPEG() {
        YuvImage yuvImage = new YuvImage(
            i420Data.data,
            ImageFormat.NV21,
            i420Data.width,
            i420Data.height,
            // We omit the strides here. If they were included, the resulting image would
            // have its colors offset.
            null);
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        yuvImage.compressToJpeg(new Rect(0, 0, i420Data.width, i420Data.height), 100, outputStream);
        byte[] jpegData = outputStream.toByteArray();
        // if rotate==90 || rotate==270, switch width and height
        if(rotation == 90 || rotation == 270) {
            byte[] rotatedJpegData = rotateJpeg(jpegData);
            return new PhotographFormat(rotatedJpegData, i420Data.height, i420Data.width, RTCVideoFrameFormat.KMJPEG);
        }
        return new PhotographFormat(jpegData, i420Data.width, i420Data.height, RTCVideoFrameFormat.KMJPEG);
    }

    byte[] rotateJpeg(byte[] jpegData) {
        if(rotation == 0) {
            return jpegData;
        }
        switch (rotation) {
            case 0:
                break;
            case 90:
            case 180:
            case 270:
                Bitmap bitmap = BitmapFactory.decodeByteArray(jpegData, 0, jpegData.length);
                Matrix matrix = new Matrix();
                Bitmap rotatedBitmap;
                matrix.postRotate(rotation);
                rotatedBitmap = Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), matrix, true);
                ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
                rotatedBitmap.compress(Bitmap.CompressFormat.JPEG, 100, outputStream);
                byte[] rotatedJpegData = outputStream.toByteArray();
                return rotatedJpegData;
            default:
                // Rotation is checked to always be 0, 90, 180 or 270 by VideoFrame
                throw new RuntimeException("Invalid rotation");
        }
        return jpegData;
    }
}