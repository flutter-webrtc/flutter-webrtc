package com.cloudwebrtc.webrtc.record;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.ImageFormat;
import android.graphics.Matrix;
import android.graphics.Rect;
import android.graphics.YuvImage;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

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

import com.cloudwebrtc.webrtc.utils.VideoFrameTransform;

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
        VideoFrameTransform.PhotographFormat transformResult = VideoFrameTransform.transform(videoFrame, VideoFrameTransform.RTCVideoFrameFormat.KMJPEG);
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
            Log.d("MyApp", "File path: " + file.getAbsolutePath());
            Bitmap bitmap = BitmapFactory.decodeByteArray(transformResult.data, 0, transformResult.data.length);
            bitmap.compress(Bitmap.CompressFormat.JPEG, 100, outputStream);
            outputStream.close();
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
