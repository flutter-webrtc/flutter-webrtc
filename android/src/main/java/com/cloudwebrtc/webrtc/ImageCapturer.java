package com.cloudwebrtc.webrtc;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.SystemClock;
import java.nio.ByteBuffer;
import java.util.concurrent.TimeUnit;
import android.util.Base64;
import org.webrtc.SurfaceTextureHelper;
import org.webrtc.VideoCapturer;
import org.webrtc.VideoFrame;
import org.webrtc.JavaI420Buffer;

/**
 * Created by weiweiduan on 2018/4/21.
 */

public  class ImageCapturer implements VideoCapturer {
    static final String TAG = "ImageCapturer";
    CapturerObserver capturerObserver = null;

    @Override
    public void initialize(SurfaceTextureHelper surfaceTextureHelper, Context context, CapturerObserver capturerObserver) {
        this.capturerObserver = capturerObserver;
    }

    @Override
    public void startCapture(int width, int height, int framerate) {

    }

    @Override
    public void stopCapture() throws InterruptedException {

    }

    @Override
    public void changeCaptureFormat(int width, int height, int framerate) {

    }

    public static Bitmap base64ToBitmap(String base64Data) {
        byte[] bytes = Base64.decode(base64Data, Base64.DEFAULT);
        return BitmapFactory.decodeByteArray(bytes, 0, bytes.length);
    }

    public void putImage(String base64_image){
        Bitmap bitmap = base64ToBitmap(base64_image);
        capturerObserver.onFrameCaptured(getVideoFrame(bitmap));
    }

    public VideoFrame getVideoFrame(Bitmap bitmap) {

        int width = bitmap.getWidth();
        int height = bitmap.getHeight();
        final long captureTimeNs = TimeUnit.MILLISECONDS.toNanos(SystemClock.elapsedRealtime());
        final JavaI420Buffer buffer = JavaI420Buffer.allocate(width, height);
        final ByteBuffer dataY = buffer.getDataY();
        final ByteBuffer dataU = buffer.getDataU();
        final ByteBuffer dataV = buffer.getDataV();
        final int chromaHeight = (height + 1) / 2;
        final int sizeY = height * buffer.getStrideY();
        final int sizeU = chromaHeight * buffer.getStrideU();
        final int sizeV = chromaHeight * buffer.getStrideV();


        int[] argb = new int[width * height];
        // Bitmap 获取 argb
        bitmap.getPixels(argb, 0, width, 0, 0, width, height);

        int a, R, G, B, Y, U, V;
        int index = 0;
        for (int j = 0; j < height; j++) {
            for (int i = 0; i < width; i++) {
                a = (argb[index] & 0xff000000) >> 24; //  is not used obviously
                R = (argb[index] & 0xff0000) >> 16;
                G = (argb[index] & 0xff00) >> 8;
                B = (argb[index] & 0xff) >> 0;

                // well known RGB to YUV algorithm
                Y = ( (  66 * R + 129 * G +  25 * B + 128) >> 8) +  16;
                U = ( ( -38 * R -  74 * G + 112 * B + 128) >> 8) + 128;
                V = ( ( 112 * R -  94 * G -  18 * B + 128) >> 8) + 128;

                // I420(YUV420p) -> YYYYYYYY UU VV
                dataY.put((byte) ((Y < 0) ? 0 : ((Y > 255) ? 255 : Y)));
                if (j % 2 == 0 && i % 2 == 0) {
                    dataU.put((byte)((U<0) ? 0 : ((U > 255) ? 255 : U)));
                    dataV.put((byte)((V<0) ? 0 : ((V > 255) ? 255 : V)));
                }
                index ++;
            }
        }

        return new VideoFrame(buffer, 0 /* rotation */, captureTimeNs);
    }

    @Override
    public void dispose() {

    }

    @Override
    public boolean isScreencast() {
        return true;
    }
}
