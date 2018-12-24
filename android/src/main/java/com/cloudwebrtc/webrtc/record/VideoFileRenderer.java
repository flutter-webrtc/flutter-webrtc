package com.cloudwebrtc.webrtc.record;

import android.media.MediaCodec;
import android.media.MediaCodecInfo;
import android.media.MediaFormat;
import android.media.MediaMuxer;
import android.os.Handler;
import android.os.HandlerThread;
import android.util.Log;
import android.view.Surface;

import org.webrtc.EglBase;
import org.webrtc.GlRectDrawer;
import org.webrtc.ThreadUtils;
import org.webrtc.VideoFrame;
import org.webrtc.VideoFrameDrawer;
import org.webrtc.VideoSink;
import org.webrtc.audio.JavaAudioDeviceModule;
import org.webrtc.audio.JavaAudioDeviceModule.SamplesReadyCallback;

import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.concurrent.CountDownLatch;

class VideoFileRenderer implements VideoSink, SamplesReadyCallback {
    private static final String TAG = "VideoFileRenderer";
    private final HandlerThread renderThread;
    private final Handler renderThreadHandler;
    private final HandlerThread fileThread;
    private final Handler fileThreadHandler;
    private final FileOutputStream videoOutFile;
    private final String outputFileName;
    private final int outputFileWidth;
    private final int outputFileHeight;
    private final int outputFrameSize;
    private ByteBuffer[] encoderOutputBuffers;
    private final ByteBuffer outputFrameBuffer;
    private EglBase eglBase;
    private int frameCount;

    // TODO: these ought to be configurable as well
    private static final String MIME_TYPE = "video/avc";    // H.264 Advanced Video Coding
    private static final int FRAME_RATE = 30;               // 30fps
    private static final int IFRAME_INTERVAL = 5;           // 5 seconds between I-frames

    private MediaMuxer mediaMuxer;
    private MediaCodec encoder;
    private MediaCodec.BufferInfo bufferInfo;
    private int trackIndex;
    private boolean muxerStarted;
    private boolean isRunning = true;
    private GlRectDrawer drawer;
    private Surface surface;

    VideoFileRenderer(String outputFile, int outputFileWidth, int outputFileHeight,
                             final EglBase.Context sharedContext) throws IOException {
        if ((outputFileWidth % 2) == 1 || (outputFileHeight % 2) == 1) {
            throw new IllegalArgumentException("Does not support uneven width or height");
        }
        this.outputFileName = outputFile;
        this.outputFileWidth = outputFileWidth;
        this.outputFileHeight = outputFileHeight;
        outputFrameSize = outputFileWidth * outputFileHeight * 3 / 2;
        outputFrameBuffer = ByteBuffer.allocateDirect(outputFrameSize);
        videoOutFile = new FileOutputStream(outputFile);
        renderThread = new HandlerThread(TAG + "RenderThread");
        renderThread.start();
        renderThreadHandler = new Handler(renderThread.getLooper());
        fileThread = new HandlerThread(TAG + "FileThread");
        fileThread.start();
        fileThreadHandler = new Handler(fileThread.getLooper());
        bufferInfo = new MediaCodec.BufferInfo();

        MediaFormat format = MediaFormat.createVideoFormat(MIME_TYPE, outputFileWidth, outputFileHeight);

        // Set some properties.  Failing to specify some of these can cause the MediaCodec
        // configure() call to throw an unhelpful exception.
        format.setInteger(MediaFormat.KEY_COLOR_FORMAT,
                MediaCodecInfo.CodecCapabilities.COLOR_FormatSurface);
        format.setInteger(MediaFormat.KEY_BIT_RATE, 6000000);
        format.setInteger(MediaFormat.KEY_FRAME_RATE, FRAME_RATE);
        format.setInteger(MediaFormat.KEY_I_FRAME_INTERVAL, IFRAME_INTERVAL);
        Log.e(TAG, "format: " + format);

        // Create a MediaCodec encoder, and configure it with our format.  Get a Surface
        // we can use for input and wrap it with a class that handles the EGL work.
        encoder = MediaCodec.createEncoderByType(MIME_TYPE);
        MediaCodecInfo info = encoder.getCodecInfo();
        for (String s : info.getSupportedTypes()) {
            Log.e(TAG, "WTF " + s);
        }
        for (int colorFormat : info.getCapabilitiesForType(MIME_TYPE).colorFormats) {
            Log.e(TAG, "COLOR FORMAT SUPPORTED " + String.valueOf(colorFormat));
        }
        encoder.configure(format, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE);
        ThreadUtils.invokeAtFrontUninterruptibly(renderThreadHandler, new Runnable() {
            @Override
            public void run() {
                eglBase = EglBase.create(sharedContext, EglBase.CONFIG_RECORDABLE);
                surface = encoder.createInputSurface();
                eglBase.createSurface(surface);
                eglBase.makeCurrent();
                drawer = new GlRectDrawer();
            }
        });

        // Create a MediaMuxer.  We can't add the video track and start() the muxer here,
        // because our MediaFormat doesn't have the Magic Goodies.  These can only be
        // obtained from the encoder after it has started processing data.
        //
        // We're not actually interested in multiplexing audio.  We just want to convert
        // the raw H.264 elementary stream we get from MediaCodec into a .mp4 file.
        mediaMuxer = new MediaMuxer(outputFile,
                MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4);

        trackIndex = -1;
        muxerStarted = false;
    }

    @Override
    public void onFrame(VideoFrame frame) {
        frame.retain();
        renderThreadHandler.post(() -> renderFrameOnRenderThread(frame));
    }

    private VideoFrameDrawer frameDrawer;

    private void renderFrameOnRenderThread(VideoFrame frame) {
        if (frameDrawer == null) {
            frameDrawer = new VideoFrameDrawer();
        }
        frameDrawer.drawFrame(frame, drawer, null, 0, 0, outputFileWidth, outputFileHeight);
        frame.release();
        drainEncoder();
        eglBase.swapBuffers();
    }

    /**
     * Release all resources. All already posted frames will be rendered first.
     */
    void release() {
        final CountDownLatch cleanupBarrier = new CountDownLatch(1);
        isRunning = false;
        renderThreadHandler.post(() -> {
            eglBase.release();
            renderThread.quit();
            cleanupBarrier.countDown();
        });
        ThreadUtils.awaitUninterruptibly(cleanupBarrier);
        fileThreadHandler.post(() -> {
            mediaMuxer.stop();
            mediaMuxer.release();
            try {
                videoOutFile.close();
                Log.d(TAG,
                        "Video written to disk as " + outputFileName + ". The number of frames is " + frameCount
                                + " and the dimensions of the frames are " + outputFileWidth + "x"
                                + outputFileHeight + ".");
            } catch (IOException e) {
                throw new RuntimeException("Error closing output file", e);
            }
            fileThread.quit();
        });
        try {
            fileThread.join();
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            Log.e(TAG, "Interrupted while waiting for the write to disk to complete.", e);
        }
    }

    private boolean encoderStarted = false;

    private void drainEncoder() {
        if (!encoderStarted) {
            encoder.start();
            encoderOutputBuffers = encoder.getOutputBuffers();
            encoderStarted = true;
            return;
        }
        while (true) {
            int encoderStatus = encoder.dequeueOutputBuffer(bufferInfo, 10000);
            if (encoderStatus == MediaCodec.INFO_TRY_AGAIN_LATER) {
                Log.e(TAG, "no output from encoder available");
                break;
            } else if (encoderStatus == MediaCodec.INFO_OUTPUT_BUFFERS_CHANGED) {
                // not expected for an encoder
                encoderOutputBuffers = encoder.getOutputBuffers();
                Log.e(TAG, "encoder output buffers changed");
            } else if (encoderStatus == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) {
                // not expected for an encoder
                MediaFormat newFormat = encoder.getOutputFormat();

                Log.e(TAG, "encoder output format changed: " + newFormat);
                trackIndex = mediaMuxer.addTrack(newFormat);
                mediaMuxer.start();
            } else if (encoderStatus < 0) {
                Log.e(TAG, "unexpected result fr om encoder.dequeueOutputBuffer: " + encoderStatus);
            } else { // encoderStatus >= 0
                ByteBuffer encodedData = encoderOutputBuffers[encoderStatus];
                if (encodedData == null) {
                    Log.e(TAG, "encoderOutputBuffer " + encoderStatus + " was null");
                }
                // It's usually necessary to adjust the ByteBuffer values to match BufferInfo.
                encodedData.position(bufferInfo.offset);
                encodedData.limit(bufferInfo.offset + bufferInfo.size);
                mediaMuxer.writeSampleData(trackIndex, encodedData, bufferInfo);
                isRunning = isRunning && (bufferInfo.flags & MediaCodec.BUFFER_FLAG_END_OF_STREAM) == 0;
                Log.d(TAG, "passed " + bufferInfo.size + " bytes to file"
                        + (!isRunning ? " (EOS)" : ""));
                encoder.releaseOutputBuffer(encoderStatus, false);
                if ((bufferInfo.flags & MediaCodec.BUFFER_FLAG_END_OF_STREAM) != 0) {
                    break;
                }
            }
        }
    }

    @Override
    public void onWebRtcAudioRecordSamplesReady(JavaAudioDeviceModule.AudioSamples audioSamples) {
        if (trackIndex == -1) {
            Log.e(TAG, "Muxer is not ready for audio");
            return;
        }
    }

}
/**
 package com.cloudwebrtc.webrtc.record;

 import android.media.MediaCodec;
 import android.media.MediaCodecInfo;
 import android.media.MediaCodecList;
 import android.media.MediaFormat;
 import android.media.MediaMuxer;
 import android.os.Handler;
 import android.os.HandlerThread;
 import android.util.Log;
 import android.view.Surface;

 import org.webrtc.EglBase;
 import org.webrtc.ThreadUtils;
 import org.webrtc.VideoFrame;
 import org.webrtc.VideoSink;
 import org.webrtc.YuvConverter;
 import org.webrtc.YuvHelper;

 import java.io.FileOutputStream;
 import java.io.IOException;
 import java.nio.ByteBuffer;
 import java.nio.charset.Charset;
 import java.util.concurrent.CountDownLatch;


 public class VideoFileRenderer implements VideoSink {
 private static final String TAG = "VideoFileRenderer";
 private final HandlerThread renderThread;
 private final Handler renderThreadHandler;
 private final HandlerThread fileThread;
 private final Handler fileThreadHandler;
 private final FileOutputStream videoOutFile;
 private final String outputFileName;
 private final int outputFileWidth;
 private final int outputFileHeight;
 private final int outputFrameSize;
 private final ByteBuffer[] encoderInputBuffers;
 private ByteBuffer[] encoderOutputBuffers;
 private final ByteBuffer outputFrameBuffer;
 private EglBase eglBase;
 private YuvConverter yuvConverter;
 private int frameCount;

 // TODO: these ought to be configurable as well
 private static final String MIME_TYPE = "video/avc";    // H.264 Advanced Video Coding
 private static final int FRAME_RATE = 30;               // 30fps
 private static final int IFRAME_INTERVAL = 5;           // 5 seconds between I-frames

 private MediaMuxer mediaMuxer;
 private MediaCodec encoder;
 private MediaCodec.BufferInfo bufferInfo;
 private int trackIndex;
 private boolean muxerStarted;
 private boolean isRunning = true;

 public VideoFileRenderer(String outputFile, int outputFileWidth, int outputFileHeight,
 final EglBase.Context sharedContext) throws IOException {
 if ((outputFileWidth % 2) == 1 || (outputFileHeight % 2) == 1) {
 throw new IllegalArgumentException("Does not support uneven width or height");
 }
 this.outputFileName = outputFile;
 this.outputFileWidth = outputFileWidth;
 this.outputFileHeight = outputFileHeight;
 outputFrameSize = outputFileWidth * outputFileHeight * 3 / 2;
 outputFrameBuffer = ByteBuffer.allocateDirect(outputFrameSize);
 videoOutFile = new FileOutputStream(outputFile);
 //        videoOutFile.write(
 //                ("YUV4MPEG2 C420 W" + outputFileWidth + " H" + outputFileHeight + " Ip F30:1 A1:1\n")
 //                        .getBytes(Charset.forName("US-ASCII")));
 renderThread = new HandlerThread(TAG + "RenderThread");
 renderThread.start();
 renderThreadHandler = new Handler(renderThread.getLooper());
 fileThread = new HandlerThread(TAG + "FileThread");
 fileThread.start();
 fileThreadHandler = new Handler(fileThread.getLooper());
 ThreadUtils.invokeAtFrontUninterruptibly(renderThreadHandler, new Runnable() {
@Override
public void run() {
eglBase = EglBase.create(sharedContext, EglBase.CONFIG_PIXEL_BUFFER);
eglBase.createDummyPbufferSurface();
eglBase.makeCurrent();
yuvConverter = new YuvConverter();
}
});
 bufferInfo = new MediaCodec.BufferInfo();

 MediaFormat format = MediaFormat.createVideoFormat(MIME_TYPE, outputFileWidth, outputFileHeight);

 // Set some properties.  Failing to specify some of these can cause the MediaCodec
 // configure() call to throw an unhelpful exception.
 format.setInteger(MediaFormat.KEY_COLOR_FORMAT,
 MediaCodecInfo.CodecCapabilities.COLOR_FormatYUV422Planar);
 format.setInteger(MediaFormat.KEY_BIT_RATE, 6000000);
 format.setInteger(MediaFormat.KEY_FRAME_RATE, FRAME_RATE);
 format.setInteger(MediaFormat.KEY_I_FRAME_INTERVAL, IFRAME_INTERVAL);
 Log.e(TAG, "format: " + format);

 // Create a MediaCodec encoder, and configure it with our format.  Get a Surface
 // we can use for input and wrap it with a class that handles the EGL work.
 encoder = MediaCodec.createEncoderByType(MIME_TYPE);
 MediaCodecInfo info = encoder.getCodecInfo();
 for (String s : info.getSupportedTypes()) {
 Log.wtf(TAG, "WTF " + s);
 }
 for (int colorFormat : info.getCapabilitiesForType(MIME_TYPE).colorFormats) {
 Log.wtf(TAG, "COLOR FORMAT SUPPORTED " + String.valueOf(colorFormat));
 }
 MediaCodec codec = MediaCodec.createByCodecName(info.getName());
 encoder.configure(format, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE);
 encoder.start();
 encoderInputBuffers = encoder.getInputBuffers();
 encoderOutputBuffers = encoder.getOutputBuffers();

 // Create a MediaMuxer.  We can't add the video track and start() the muxer here,
 // because our MediaFormat doesn't have the Magic Goodies.  These can only be
 // obtained from the encoder after it has started processing data.
 //
 // We're not actually interested in multiplexing audio.  We just want to convert
 // the raw H.264 elementary stream we get from MediaCodec into a .mp4 file.
 mediaMuxer = new MediaMuxer(outputFile,
 MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4);

 trackIndex = -1;
 muxerStarted = false;

 fileThreadHandler.post(() -> {
 while (isRunning) {
 int encoderStatus = encoder.dequeueOutputBuffer(bufferInfo, 10000);
 if (encoderStatus == MediaCodec.INFO_TRY_AGAIN_LATER) {
 // no output available yet
 Log.d(TAG, "no output from encoder available");
 } else if (encoderStatus == MediaCodec.INFO_OUTPUT_BUFFERS_CHANGED) {
 // not expected for an encoder
 encoderOutputBuffers = encoder.getOutputBuffers();
 Log.d(TAG, "encoder output buffers changed");
 } else if (encoderStatus == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) {
 // not expected for an encoder
 MediaFormat newFormat = encoder.getOutputFormat();

 Log.d(TAG, "encoder output format changed: " + newFormat);
 trackIndex = mediaMuxer.addTrack(newFormat);
 mediaMuxer.start();
 } else if (encoderStatus < 0) {
 Log.e(TAG, "unexpected result from encoder.dequeueOutputBuffer: " + encoderStatus);
 } else { // encoderStatus >= 0
 ByteBuffer encodedData = encoderOutputBuffers[encoderStatus];
 if (encodedData == null) {
 Log.e(TAG, "encoderOutputBuffer " + encoderStatus + " was null");
 }
 // It's usually necessary to adjust the ByteBuffer values to match BufferInfo.
 encodedData.position(bufferInfo.offset);
 encodedData.limit(bufferInfo.offset + bufferInfo.size);
 //                    byte[] data = new byte[bufferInfo.size];
 //                    encodedData.get(data);
 //                    encodedData.position(bufferInfo.offset);
 //                    if (bufferInfo.size == 29) {
 //                      Log.wtf(TAG, "Skip SPS");
 //                    } else try {
 //                        videoOutFile.write(data);
 //                    } catch (IOException ioe) {
 //                        Log.w(TAG, "failed writing debug data to file");
 //                        throw new RuntimeException(ioe);
 //                    }
 mediaMuxer.writeSampleData(trackIndex, encodedData, bufferInfo);
 isRunning = isRunning && (bufferInfo.flags & MediaCodec.BUFFER_FLAG_END_OF_STREAM) == 0;
 Log.d(TAG, "passed " + bufferInfo.size + " bytes to file"
 + (!isRunning ? " (EOS)" : ""));
 encoder.releaseOutputBuffer(encoderStatus, false);
 }
 }
 //            encoder.signalEndOfInputStream();
 encoder.stop();
 encoder.release();
 mediaMuxer.stop();
 mediaMuxer.release();
 });
 }

 @Override
 public void onFrame(VideoFrame frame) {
 frame.retain();
 renderThreadHandler.post(() -> renderFrameOnRenderThread(frame));
 }

 private void renderFrameOnRenderThread(VideoFrame frame) {
 final VideoFrame.Buffer buffer = frame.getBuffer();
 // If the frame is rotated, it will be applied after cropAndScale. Therefore, if the frame is
 // rotated by 90 degrees, swap width and height.
 final int targetWidth = frame.getRotation() % 180 == 0 ? outputFileWidth : outputFileHeight;
 final int targetHeight = frame.getRotation() % 180 == 0 ? outputFileHeight : outputFileWidth;
 final float frameAspectRatio = (float) buffer.getWidth() / (float) buffer.getHeight();
 final float fileAspectRatio = (float) targetWidth / (float) targetHeight;
 // Calculate cropping to equalize the aspect ratio.
 int cropWidth = buffer.getWidth();
 int cropHeight = buffer.getHeight();
 if (fileAspectRatio > frameAspectRatio) {
 cropHeight = (int) (cropHeight * (frameAspectRatio / fileAspectRatio));
 } else {
 cropWidth = (int) (cropWidth * (fileAspectRatio / frameAspectRatio));
 }
 final int cropX = (buffer.getWidth() - cropWidth) / 2;
 final int cropY = (buffer.getHeight() - cropHeight) / 2;
 final VideoFrame.Buffer scaledBuffer =
 buffer.cropAndScale(cropX, cropY, cropWidth, cropHeight, targetWidth, targetHeight);
 frame.release();
 final VideoFrame.I420Buffer i420 = scaledBuffer.toI420();
 scaledBuffer.release();
 //        fileThreadHandler.post(() -> {
 long presTime = computePresentationTime(++frameCount);
 int buffIndex = encoder.dequeueInputBuffer(-1);
 if (buffIndex < 0) {
 i420.release();
 return;
 }
 ByteBuffer encoderBuffer = encoderInputBuffers[buffIndex];
 YuvHelper.I420Rotate(i420.getDataY(), i420.getStrideY(), i420.getDataU(), i420.getStrideU(),
 i420.getDataV(), i420.getStrideV(), encoderBuffer, i420.getWidth(), i420.getHeight(),
 frame.getRotation());
 i420.release();
 //            encoderBuffer.put(outputFrameBuffer);
 encoder.queueInputBuffer(buffIndex, 0, outputFrameSize, presTime, 0);
 //        });
 }

 private static long computePresentationTime(int frameIndex) {
 return 132 + frameIndex * 1000000 / FRAME_RATE;
 }

public void release() {
    final CountDownLatch cleanupBarrier = new CountDownLatch(1);
    isRunning = false;
    renderThreadHandler.post(() -> {
        yuvConverter.release();
        eglBase.release();
        renderThread.quit();
        cleanupBarrier.countDown();
    });
    ThreadUtils.awaitUninterruptibly(cleanupBarrier);
    fileThreadHandler.post(() -> {
        try {
            videoOutFile.close();
            Log.d(TAG,
                    "Video written to disk as " + outputFileName + ". The number of frames is " + frameCount
                            + " and the dimensions of the frames are " + outputFileWidth + "x"
                            + outputFileHeight + ".");
        } catch (IOException e) {
            throw new RuntimeException("Error closing output file", e);
        }
        fileThread.quit();
    });
    try {
        fileThread.join();
    } catch (InterruptedException e) {
        Thread.currentThread().interrupt();
        Log.e(TAG, "Interrupted while waiting for the write to disk to complete.", e);
    }
}

}
 */