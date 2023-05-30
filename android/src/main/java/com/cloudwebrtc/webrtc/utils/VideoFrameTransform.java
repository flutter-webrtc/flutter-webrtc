package com.cloudwebrtc.webrtc.utils;

import android.graphics.Rect;
import android.graphics.YuvImage;
import android.graphics.ImageFormat;
import android.graphics.Bitmap;

import org.webrtc.VideoFrame;
import org.webrtc.YuvHelper;

import java.nio.ByteBuffer;
import java.util.Arrays;
import java.io.ByteArrayOutputStream;

import com.cloudwebrtc.webrtc.utils.RTCVideoFrameFormat;


public class VideoFrameTransform {
    public static byte[] transform(VideoFrame videoFrame, RTCVideoFrameFormat format){
        byte[] result = null;

        switch(format) {
                case kMJPEG:
                    result = videoFrameToJPEG(videoFrame);
                    break;
        }

        return result;
    }

    // public static byte[] JPEGToI420(byte[] jpegData) {
    //     // JPEG to I420
    // }

    // public static byte[] JPEGToRGBA(byte[] jpegData){
    //     // JPEG to RGBA
    // }
    public static byte[] videoFrameToJPEG(VideoFrame videoFrame) {
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
        byte[] cleanedArray = Arrays.copyOfRange(yuvBuffer.array(),
            yuvBuffer.arrayOffset(), minSize);
        YuvImage yuvImage = new YuvImage(
            cleanedArray,
            ImageFormat.NV21,
            width,
            height,
            // We omit the strides here. If they were included, the resulting image would
            // have its colors offset.
            null);
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        yuvImage.compressToJpeg(new Rect(0, 0, width, height), 100, outputStream);
        byte[] jpegData = outputStream.toByteArray();
        i420Buffer.release();
        
        return jpegData;
    }
}