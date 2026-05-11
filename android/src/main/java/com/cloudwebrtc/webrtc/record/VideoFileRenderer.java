// Modifications by Signify, Copyright 2025, Signify Holding -  SPDX-License-Identifier: MIT

package com.cloudwebrtc.webrtc.record;

import android.media.MediaCodec;
import android.media.MediaCodecInfo;
import android.media.MediaFormat;
import android.media.MediaMuxer;
import android.os.Build;
import android.os.Handler;
import android.os.HandlerThread;
import android.util.Log;
import android.view.Surface;

import org.webrtc.EglBase;
import org.webrtc.GlRectDrawer;
import org.webrtc.VideoFrame;
import org.webrtc.VideoFrameDrawer;
import org.webrtc.VideoSink;
import org.webrtc.audio.JavaAudioDeviceModule;
import org.webrtc.audio.JavaAudioDeviceModule.SamplesReadyCallback;

import java.io.IOException;
import java.lang.reflect.Method;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.concurrent.CountDownLatch;

class VideoFileRenderer implements VideoSink, SamplesReadyCallback {
    private static final String TAG = "VideoFileRenderer";
    private final HandlerThread renderThread;
    private final Handler renderThreadHandler;
    private final HandlerThread audioThread;
    private final Handler audioThreadHandler;
    private int outputFileWidth = -1;
    private int outputFileHeight = -1;
    private ByteBuffer[] encoderOutputBuffers;
    private ByteBuffer[] audioInputBuffers;
    private ByteBuffer[] audioOutputBuffers;
    private EglBase eglBase;
    private final EglBase.Context sharedContext;
    private VideoFrameDrawer frameDrawer;

    // TODO: these ought to be configurable as well
    private static final String MIME_TYPE = "video/avc";    // H.264 Advanced Video Coding
    private static final int FRAME_RATE = 30;               // 30fps
    private static final int IFRAME_INTERVAL = 5;           // 5 seconds between I-frames

    private final MediaMuxer mediaMuxer;
    private MediaCodec encoder;
    private final MediaCodec.BufferInfo bufferInfo;
    private MediaCodec.BufferInfo audioBufferInfo;
    private int trackIndex = -1;
    private int audioTrackIndex;
    private boolean isRunning = true;
    private GlRectDrawer drawer;
    private Surface surface;
    private MediaCodec audioEncoder;

    VideoFileRenderer(String outputFile, final EglBase.Context sharedContext, boolean withAudio) throws IOException {
        renderThread = new HandlerThread(TAG + "RenderThread");
        renderThread.start();
        renderThreadHandler = new Handler(renderThread.getLooper());
        if (withAudio) {
            audioThread = new HandlerThread(TAG + "AudioThread");
            audioThread.start();
            audioThreadHandler = new Handler(audioThread.getLooper());
        } else {
            audioThread = null;
            audioThreadHandler = null;
        }
        bufferInfo = new MediaCodec.BufferInfo();
        this.sharedContext = sharedContext;

        // Create a MediaMuxer.  We can't add the video track and start() the muxer here,
        // because our MediaFormat doesn't have the Magic Goodies.  These can only be
        // obtained from the encoder after it has started processing data.
        mediaMuxer = new MediaMuxer(outputFile,
                MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4);

        audioTrackIndex = withAudio ? -1 : 0;
    }
    private boolean tryConfigureEncoder(EncoderConfig config) {
        try {
            MediaFormat format = MediaFormat.createVideoFormat(MIME_TYPE, config.width, config.height);
            format.setInteger(MediaFormat.KEY_COLOR_FORMAT, MediaCodecInfo.CodecCapabilities.COLOR_FormatSurface);
            format.setInteger(MediaFormat.KEY_BIT_RATE, config.bitrate);
            format.setInteger(MediaFormat.KEY_FRAME_RATE, FRAME_RATE);
            format.setInteger(MediaFormat.KEY_I_FRAME_INTERVAL, IFRAME_INTERVAL);
            // Use YUV420 semi-planar size (1.5 bytes per pixel) to reduce memory usage
            format.setInteger(MediaFormat.KEY_MAX_INPUT_SIZE, config.width * config.height * 3 / 2);
            format.setInteger(MediaFormat.KEY_PRIORITY, 0);

            Log.d(TAG, "Trying encoder config: " + config);

            encoder = MediaCodec.createEncoderByType(MIME_TYPE);
            String codecName = encoder.getName();
            Log.d(TAG, "Codec name: " + codecName);
            if ("OMX.hisi.video.encoder.avc".equals(codecName)) {
                Log.w(TAG, "hisi h264 encoder does not set 'MediaFormat.KEY_PROFILE'.");
                //format.setInteger(MediaFormat.KEY_PROFILE, config.profile);
            }else{
                format.setInteger(MediaFormat.KEY_PROFILE, config.profile);
            }

            encoder.configure(format, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE);
            // Create input surface *before* starting the encoder
            surface = encoder.createInputSurface();
            Log.d(TAG, "Input surface created successfully: " + surface);
            return true;
        } catch (Exception e) {
            Log.w(TAG, "Failed to configure encoder for config: " + config + ", error: " + e.getMessage());
            if (surface != null) {
                surface.release();
                surface = null;
            }
            if (encoder != null) {
                try {
                    encoder.release();
                } catch (Exception ignored) {
                }
                encoder = null;
            }
            return false;
        }
    }

    private boolean startEncoder() {
        try {
            encoder.start();
            encoderOutputBuffers = encoder.getOutputBuffers();
            Log.d(TAG, "Encoder started successfully");
            return true;
        } catch (Exception e) {
            Log.w(TAG, "Failed to start encoder: " + e.getMessage());
            if (surface != null) {
                surface.release();
                surface = null;
            }
            if (encoder != null) {
                try {
                    encoder.release();
                } catch (Exception ignored) {
                }
                encoder = null;
            }
            return false;
        }
    }

    private List<EncoderConfig> getSupportedConfigurations(int frameWidth, int frameHeight) {
        
        int[] bitrates = {6000000, 4000000, 2000000, 1000000};
        int[] profiles = {
                MediaCodecInfo.CodecProfileLevel.AVCProfileBaseline,
                MediaCodecInfo.CodecProfileLevel.AVCProfileMain,
                MediaCodecInfo.CodecProfileLevel.AVCProfileHigh
        };
        List<int[]> resolutions = new ArrayList<>();
        resolutions.add(new int[]{frameWidth, frameHeight});
        for (int[] res : Arrays.asList(
                new int[]{1920, 1080},
                new int[]{1280, 720},
                new int[]{854, 480},
                new int[]{640, 360},
                new int[]{426, 240})) {
            // only add resolutions bellow the original stream resolution
            if (res[0] <= frameWidth && res[1] <= frameHeight) {
                resolutions.add(res);
            }
        }

        List<EncoderConfig> configs = new ArrayList<>();
        for (int[] res : resolutions) {
            for (int bitrate : bitrates) {
                for (int profile : profiles) {
                    configs.add(new EncoderConfig(res[0], res[1], bitrate, profile));
                }
            }
        }

        // Sort: prioritize higher resolutions, higher bitrates, Baseline profile
        Collections.sort(configs, new Comparator<EncoderConfig>() {
            @Override
            public int compare(EncoderConfig c1, EncoderConfig c2) {
                int resCompare = Integer.compare(c2.width * c2.height, c1.width * c1.height);
                if (resCompare != 0) return resCompare;
                int bitrateCompare = Integer.compare(c2.bitrate, c1.bitrate);
                if (bitrateCompare != 0) return bitrateCompare;
                return Integer.compare(c1.profile, c2.profile); // Baseline first
            }
        });

        return configs;
    }

    private boolean isProfileSupported(MediaCodecInfo codecInfo, String mimeType, int profile) {
        try {
            MediaCodecInfo.CodecCapabilities caps = codecInfo.getCapabilitiesForType(mimeType);
            for (MediaCodecInfo.CodecProfileLevel pl : caps.profileLevels) {
                if (pl.profile == profile) {
                    return true;
                }
            }
        } catch (Exception e) {
            Log.w(TAG, "Failed to check profile support: " + e.getMessage());
        }
        return false;
    }


    private void initVideoEncoder(int frameWidth, int frameHeight) {
        if (encoder != null) {
            encoder.stop();
            encoder.release();
            encoder = null;
        }
        if (surface != null) {
            surface.release();
            surface = null;
        }

        // Check codec capabilities
        MediaCodecInfo codecInfo = null;
        try {
            MediaCodec codec = MediaCodec.createEncoderByType(MIME_TYPE);
            codecInfo = codec.getCodecInfo();
            codec.release();
        } catch (Exception e) {
            Log.e(TAG, "Failed to get codec info: " + e.getMessage());
        }

        List<EncoderConfig> configs = getSupportedConfigurations(frameWidth, frameHeight);

        for (EncoderConfig config : configs) {
            // Skip unsupported configurations
            if (codecInfo != null) {
                MediaCodecInfo.VideoCapabilities videoCaps = codecInfo.getCapabilitiesForType(MIME_TYPE).getVideoCapabilities();
                if (!videoCaps.isSizeSupported(config.width, config.height)) {
                    Log.d(TAG, "Skipping unsupported resolution: " + config);
                    continue;
                }
                if (!videoCaps.getBitrateRange().contains(config.bitrate)) {
                    Log.d(TAG, "Skipping unsupported bitrate: " + config);
                    continue;
                }
                if (!isProfileSupported(codecInfo, MIME_TYPE, config.profile)) {
                    Log.d(TAG, "Skipping unsupported profile: " + config);
                    continue;
                }
            }

            if (tryConfigureEncoder(config) && startEncoder()) {
                outputFileWidth = config.width;
                outputFileHeight = config.height;
                CountDownLatch latch = new CountDownLatch(1);
                renderThreadHandler.post(() -> {
                    try {
                        eglBase = EglBase.create(sharedContext, EglBase.CONFIG_RECORDABLE);
                        Log.d(TAG, "EGL context created");
                        eglBase.createSurface(surface);
                        eglBase.makeCurrent();
                        drawer = new GlRectDrawer();
                        encoderStarted = true;
                        encoderInitializing = false;
                        Log.d(TAG, "Encoder surface setup complete: " + surface);
                    } catch (Exception e) {
                        Log.e(TAG, "Failed to setup EGL surface: " + e.getMessage());
                    } finally {
                        latch.countDown();
                    }
                });
                try {
                    latch.await();
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    Log.e(TAG, "Interrupted while awaiting EGL setup: " + e.getMessage());
                }
                if (encoderStarted) {
                    return;
                }
            }
        }

        Log.e(TAG, "Failed to configure and start encoder with any supported configuration.");
    }
    @Override
    public void onFrame(VideoFrame frame) {
        frame.retain();
        if (outputFileWidth == -1 && !encoderInitializing) {
            encoderInitializing = true;
            int frameWidth = frame.getRotatedWidth();
            int frameHeight = frame.getRotatedHeight();
            initVideoEncoder(frameWidth, frameHeight);
        }
        renderThreadHandler.post(() -> renderFrameOnRenderThread(frame));
    }

    private void renderFrameOnRenderThread(VideoFrame frame) {
        if (drawer == null) {
            Log.e(TAG, "drawer is null — skipping frame render");
            frame.release();
            return;
        }

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
    // Start Signify modification
    void release() {
        isRunning = false;
        CountDownLatch latch = new CountDownLatch(audioThreadHandler  != null ? 2 : 1);
        if (audioThreadHandler != null) {
            audioThreadHandler.post(() -> {
                try{
                    if (audioEncoder != null) {
                        audioEncoder.stop();
                        audioEncoder.release();
                    }
                    audioThread.quit();
                } finally {
                    latch.countDown();
                }
            });
        }

        renderThreadHandler.post(() -> {
            try {
                if (encoder != null) {
                    encoder.stop();
                    encoder.release();
                }
                if (eglBase != null) {
                    eglBase.release();
                    eglBase = null;
                }
                if (muxerStarted) {
                    mediaMuxer.stop();
                    mediaMuxer.release();
                    muxerStarted = false;
                }
                renderThread.quit();
            } finally {
                latch.countDown();
            }
        });

        try {
            latch.await();
        } catch (InterruptedException e) {
            Log.e(TAG, "Release interrupted", e);
            Thread.currentThread().interrupt();
        }
    }
    // End Signify modification
    private boolean encoderInitializing = false;
    private boolean encoderStarted = false;
    private volatile boolean muxerStarted = false;
    private long videoFrameStart = 0;

    private void drainEncoder() {
        while (true) {
            int encoderStatus = encoder.dequeueOutputBuffer(bufferInfo, 10000);
            if (encoderStatus == MediaCodec.INFO_TRY_AGAIN_LATER) {
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
                // Start Signify modification
                if (trackIndex != -1 && audioTrackIndex != -1 && !muxerStarted) {
                // End Signify modification
                    mediaMuxer.start();
                    muxerStarted = true;
                }
                if (!muxerStarted)
                    break;
            } else if (encoderStatus < 0) {
                Log.e(TAG, "unexpected result fr om encoder.dequeueOutputBuffer: " + encoderStatus);
            } else { // encoderStatus >= 0
                try {
                    ByteBuffer encodedData = encoderOutputBuffers[encoderStatus];
                    if (encodedData == null) {
                        Log.e(TAG, "encoderOutputBuffer " + encoderStatus + " was null");
                        break;
                    }
                    // It's usually necessary to adjust the ByteBuffer values to match BufferInfo.
                    encodedData.position(bufferInfo.offset);
                    encodedData.limit(bufferInfo.offset + bufferInfo.size);
                    if (videoFrameStart == 0 && bufferInfo.presentationTimeUs != 0) {
                        videoFrameStart = bufferInfo.presentationTimeUs;
                    }
                    bufferInfo.presentationTimeUs -= videoFrameStart;
                    if (muxerStarted)
                        mediaMuxer.writeSampleData(trackIndex, encodedData, bufferInfo);
                    isRunning = isRunning && (bufferInfo.flags & MediaCodec.BUFFER_FLAG_END_OF_STREAM) == 0;
                    encoder.releaseOutputBuffer(encoderStatus, false);
                    if ((bufferInfo.flags & MediaCodec.BUFFER_FLAG_END_OF_STREAM) != 0) {
                        break;
                    }
                } catch (Exception e) {
                    Log.wtf(TAG, e);
                    break;
                }
            }
        }
    }

    private long presTime = 0L;



    private void drainAudio() {
        if (audioBufferInfo == null)
            audioBufferInfo = new MediaCodec.BufferInfo();

        while (true) {
            int encoderStatus = audioEncoder.dequeueOutputBuffer(audioBufferInfo, 1000);

            if (encoderStatus == MediaCodec.INFO_TRY_AGAIN_LATER) {
                break;
            } else if (encoderStatus == MediaCodec.INFO_OUTPUT_BUFFERS_CHANGED) {
                // not expected for an encoder
                audioOutputBuffers = audioEncoder.getOutputBuffers();
                Log.w(TAG, "encoder output buffers changed");
            } else if (encoderStatus == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) {
                // not expected for an encoder
                MediaFormat newFormat = audioEncoder.getOutputFormat();

                Log.w(TAG, "encoder output format changed: " + newFormat);
                audioTrackIndex = mediaMuxer.addTrack(newFormat);
                // Start Signify modification
                if (trackIndex != -1 && audioTrackIndex != -1 && !muxerStarted) {
                // End Signify modification
                    mediaMuxer.start();
                    muxerStarted = true;
                }
                if (!muxerStarted)
                    break;
            } else if (encoderStatus < 0) {
                Log.e(TAG, "unexpected result from encoder.dequeueOutputBuffer: " + encoderStatus);
            } else { // encoderStatus >= 0

                try {
                    ByteBuffer encodedData = audioOutputBuffers[encoderStatus];
                    if (encodedData == null) {
                        Log.e(TAG, "encoderOutputBuffer " + encoderStatus + " was null");
                        break;
                    }

                    // It's usually necessary to adjust the ByteBuffer values to match BufferInfo.
                    encodedData.position(audioBufferInfo.offset);
                    encodedData.limit(audioBufferInfo.offset + audioBufferInfo.size);

                    if (muxerStarted)
                        mediaMuxer.writeSampleData(audioTrackIndex, encodedData, audioBufferInfo);

                    isRunning = isRunning && (audioBufferInfo.flags & MediaCodec.BUFFER_FLAG_END_OF_STREAM) == 0;
                    audioEncoder.releaseOutputBuffer(encoderStatus, false);

                    if ((audioBufferInfo.flags & MediaCodec.BUFFER_FLAG_END_OF_STREAM) != 0) {
                        break;
                    }

                } catch (Exception e) {
                    Log.wtf(TAG, e);
                    break;
                }
            }
        }
    }

    @Override
    public void onWebRtcAudioRecordSamplesReady(JavaAudioDeviceModule.AudioSamples audioSamples) {
        if (!isRunning)
            return;
        audioThreadHandler.post(() -> {
            if (audioEncoder == null) try {
                audioEncoder = MediaCodec.createEncoderByType("audio/mp4a-latm");
                MediaFormat format = new MediaFormat();
                format.setString(MediaFormat.KEY_MIME, "audio/mp4a-latm");
                format.setInteger(MediaFormat.KEY_CHANNEL_COUNT, audioSamples.getChannelCount());
                format.setInteger(MediaFormat.KEY_SAMPLE_RATE, audioSamples.getSampleRate());
                format.setInteger(MediaFormat.KEY_BIT_RATE, 64 * 1024);
                format.setInteger(MediaFormat.KEY_AAC_PROFILE, MediaCodecInfo.CodecProfileLevel.AACObjectLC);
                audioEncoder.configure(format, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE);
                audioEncoder.start();
                audioInputBuffers = audioEncoder.getInputBuffers();
                audioOutputBuffers = audioEncoder.getOutputBuffers();
            } catch (IOException exception) {
                Log.wtf(TAG, exception);
            }

            int bufferIndex = audioEncoder.dequeueInputBuffer(0);
            if (bufferIndex >= 0) {
                ByteBuffer buffer = audioInputBuffers[bufferIndex];
                buffer.clear();
                byte[] data = audioSamples.getData();
                buffer.put(data);
                audioEncoder.queueInputBuffer(bufferIndex, 0, data.length, presTime, 0);
                presTime += data.length * 125 / 12; // 1000000 microseconds / 48000hz / 2 bytes
            }
            drainAudio();
        });
    }

}
