// Modifications by Signify, Copyright 2025, Signify Holding -  SPDX-License-Identifier: MIT

package com.cloudwebrtc.webrtc.record;

import android.media.MediaCodec;
import android.media.MediaCodecInfo;
import android.media.MediaFormat;
import android.media.MediaMuxer;
import android.os.Handler;
import android.os.HandlerThread;
import android.util.Log;

import org.webrtc.audio.JavaAudioDeviceModule;
import org.webrtc.audio.JavaAudioDeviceModule.SamplesReadyCallback;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.concurrent.CountDownLatch;

class AudioFileRenderer implements SamplesReadyCallback {
    private static final String TAG = "AudioFileRenderer";
    private final HandlerThread audioThread;
    private final Handler audioThreadHandler;
    private ByteBuffer[] audioInputBuffers;
    private ByteBuffer[] audioOutputBuffers;

    private final MediaMuxer mediaMuxer;
    private MediaCodec audioEncoder;
    private MediaCodec.BufferInfo audioBufferInfo;
    private int audioTrackIndex = -1;
    private boolean isRunning = true;
    private boolean encoderStarted = false;
    private volatile boolean muxerStarted = false;
    private long presTime = 0L;

    AudioFileRenderer(String outputFile) throws IOException {
        audioThread = new HandlerThread(TAG + "AudioThread");
        audioThread.start();
        audioThreadHandler = new Handler(audioThread.getLooper());
        
        audioBufferInfo = new MediaCodec.BufferInfo();

        // Create a MediaMuxer for audio-only recording
        mediaMuxer = new MediaMuxer(outputFile, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4);
    }

    private void initAudioEncoder(JavaAudioDeviceModule.AudioSamples audioSamples) {
        try {
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
            encoderStarted = true;
        } catch (IOException exception) {
            Log.wtf(TAG, exception);
        }
    }

    @Override
    public void onWebRtcAudioRecordSamplesReady(JavaAudioDeviceModule.AudioSamples audioSamples) {
        if (!isRunning)
            return;
        audioThreadHandler.post(() -> {
            if (audioEncoder == null) {
                initAudioEncoder(audioSamples);
            }
            
            if (!encoderStarted) {
                return;
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

    private void drainAudio() {
        while (true) {
            int encoderStatus = audioEncoder.dequeueOutputBuffer(audioBufferInfo, 10000);
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
                if (audioTrackIndex != -1 && !muxerStarted) {
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

    /**
     * Release all resources. All already posted frames will be rendered first.
     */
    void release() {
        isRunning = false;
        CountDownLatch latch = new CountDownLatch(1);
        
        audioThreadHandler.post(() -> {
            try {
                if (audioEncoder != null) {
                    audioEncoder.stop();
                    audioEncoder.release();
                }
                if (muxerStarted) {
                    mediaMuxer.stop();
                    mediaMuxer.release();
                    muxerStarted = false;
                }
                audioThread.quit();
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
}
