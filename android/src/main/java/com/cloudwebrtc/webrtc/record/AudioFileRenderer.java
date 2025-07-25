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
import java.util.concurrent.TimeUnit;

class AudioFileRenderer implements SamplesReadyCallback {
    private static final String TAG = "AudioFileRenderer";
    private final HandlerThread audioThread;
    private final Handler audioThreadHandler;
    private ByteBuffer[] audioInputBuffers;
    private ByteBuffer[] audioOutputBuffers;

    private final MediaMuxer mediaMuxer;
    private MediaCodec.BufferInfo audioBufferInfo;
    private int audioTrackIndex = -1;
    private boolean isRunning = true;
    private MediaCodec audioEncoder;
    private boolean audioEncoderStarted = false;
    private volatile boolean muxerStarted = false;

    AudioFileRenderer(String outputFile) throws IOException {
        audioThread = new HandlerThread(TAG + "AudioThread");
        audioThread.start();
        audioThreadHandler = new Handler(audioThread.getLooper());

        // Create a MediaMuxer for audio-only recording
        mediaMuxer = new MediaMuxer(outputFile, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4);
    }

    /**
     * Release all resources. All already posted audio samples will be processed first.
     */
    void release() {
        isRunning = false;
        CountDownLatch latch = new CountDownLatch(1);
        
        audioThreadHandler.post(() -> {
            try {
                // First, stop the encoder if it's running
                if (audioEncoder != null && audioEncoderStarted) {
                    try {
                        // Signal end of stream with timeout
                        int inputBufferIndex = audioEncoder.dequeueInputBuffer(10000); // 10ms timeout
                        if (inputBufferIndex >= 0) {
                            audioEncoder.queueInputBuffer(inputBufferIndex, 0, 0, 0, MediaCodec.BUFFER_FLAG_END_OF_STREAM);
                        }
                        
                        // Drain remaining data
                        drainAudio();
                        
                        audioEncoder.stop();
                        audioEncoderStarted = false;
                    } catch (Exception e) {
                        Log.e(TAG, "Error stopping audio encoder", e);
                    }
                }
                
                // Release encoder
                if (audioEncoder != null) {
                    try {
                        audioEncoder.release();
                    } catch (Exception e) {
                        Log.e(TAG, "Error releasing audio encoder", e);
                    }
                    audioEncoder = null;
                }
                
                // Stop and release muxer only if it was properly started
                try {
                    if (muxerStarted && audioTrackIndex != -1) {
                        mediaMuxer.stop();
                        muxerStarted = false;
                    }
                    mediaMuxer.release();
                } catch (Exception e) {
                    Log.e(TAG, "Error stopping/releasing MediaMuxer", e);
                }
                
            } catch (Exception e) {
                Log.e(TAG, "Error during release", e);
            } finally {
                try {
                    audioThread.quit();
                } catch (Exception e) {
                    Log.e(TAG, "Error quitting audio thread", e);
                }
                latch.countDown();
            }
        });

        try {
            // Wait for cleanup with timeout to prevent ANR
            if (!latch.await(2, java.util.concurrent.TimeUnit.SECONDS)) {
                Log.w(TAG, "Release timed out, proceeding anyway");
            }
        } catch (InterruptedException e) {
            Log.e(TAG, "Release interrupted", e);
            Thread.currentThread().interrupt();
        }
    }

    private long presTime = 0L;

    private void drainAudio() {
        if (audioBufferInfo == null)
            audioBufferInfo = new MediaCodec.BufferInfo();
            
        while (isRunning && audioEncoder != null) {
            int encoderStatus = audioEncoder.dequeueOutputBuffer(audioBufferInfo, 100); // 100ms timeout
            if (encoderStatus == MediaCodec.INFO_TRY_AGAIN_LATER) {
                break;
            } else if (encoderStatus == MediaCodec.INFO_OUTPUT_BUFFERS_CHANGED) {
                audioOutputBuffers = audioEncoder.getOutputBuffers();
                Log.w(TAG, "audio encoder output buffers changed");
            } else if (encoderStatus == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) {
                MediaFormat newFormat = audioEncoder.getOutputFormat();
                Log.i(TAG, "audio encoder output format changed: " + newFormat);
                
                if (audioTrackIndex == -1) {
                    audioTrackIndex = mediaMuxer.addTrack(newFormat);
                    if (audioTrackIndex != -1 && !muxerStarted) {
                        mediaMuxer.start();
                        muxerStarted = true;
                        Log.i(TAG, "MediaMuxer started for audio recording");
                    }
                }
                if (!muxerStarted)
                    break;
            } else if (encoderStatus < 0) {
                Log.e(TAG, "unexpected result from audio encoder.dequeueOutputBuffer: " + encoderStatus);
            } else { // encoderStatus >= 0
                try {
                    ByteBuffer encodedData = audioOutputBuffers[encoderStatus];
                    if (encodedData == null) {
                        Log.e(TAG, "audio encoderOutputBuffer " + encoderStatus + " was null");
                        break;
                    }
                    
                    // Adjust ByteBuffer values to match BufferInfo
                    encodedData.position(audioBufferInfo.offset);
                    encodedData.limit(audioBufferInfo.offset + audioBufferInfo.size);
                    
                    if (muxerStarted && audioTrackIndex != -1) {
                        mediaMuxer.writeSampleData(audioTrackIndex, encodedData, audioBufferInfo);
                    }
                    
                    audioEncoder.releaseOutputBuffer(encoderStatus, false);
                    
                    if ((audioBufferInfo.flags & MediaCodec.BUFFER_FLAG_END_OF_STREAM) != 0) {
                        Log.i(TAG, "End of audio stream reached");
                        break;
                    }
                } catch (Exception e) {
                    Log.e(TAG, "Error processing audio data", e);
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
            try {
                // Check if we're still running before processing
                if (!isRunning) {
                    return;
                }
                
                // Initialize audio encoder if not already done
                if (audioEncoder == null) {
                    initializeAudioEncoder(audioSamples);
                }
                
                if (audioEncoder == null || !audioEncoderStarted) {
                    Log.e(TAG, "Failed to initialize audio encoder or encoder not started");
                    return;
                }
                
                // Get input buffer and write audio data
                int bufferIndex = audioEncoder.dequeueInputBuffer(100); // 100ms timeout
                if (bufferIndex >= 0) {
                    ByteBuffer buffer = audioInputBuffers[bufferIndex];
                    buffer.clear();
                    
                    byte[] data = audioSamples.getData();
                    if (data.length <= buffer.remaining()) {
                        buffer.put(data);
                        
                        // Calculate presentation time (microseconds)
                        // Assuming 16-bit samples: data.length bytes / 2 bytes per sample / sample rate * 1000000
                        long frameTime = (long) data.length * 1000000L / (2 * audioSamples.getSampleRate() * audioSamples.getChannelCount());
                        
                        audioEncoder.queueInputBuffer(bufferIndex, 0, data.length, presTime, 0);
                        presTime += frameTime;
                    } else {
                        Log.w(TAG, "Audio data too large for buffer: " + data.length + " bytes, buffer capacity: " + buffer.remaining());
                        audioEncoder.queueInputBuffer(bufferIndex, 0, 0, presTime, 0);
                    }
                } else {
                    Log.w(TAG, "No input buffer available for audio data");
                }
                
                // Drain encoded audio data only if still running
                if (isRunning) {
                    drainAudio();
                }
                
            } catch (Exception e) {
                Log.e(TAG, "Error processing audio samples", e);
            }
        });
    }
    
    private void initializeAudioEncoder(JavaAudioDeviceModule.AudioSamples audioSamples) {
        try {
            audioEncoder = MediaCodec.createEncoderByType("audio/mp4a-latm");
            
            MediaFormat format = new MediaFormat();
            format.setString(MediaFormat.KEY_MIME, "audio/mp4a-latm");
            format.setInteger(MediaFormat.KEY_CHANNEL_COUNT, audioSamples.getChannelCount());
            format.setInteger(MediaFormat.KEY_SAMPLE_RATE, audioSamples.getSampleRate());
            format.setInteger(MediaFormat.KEY_BIT_RATE, 128 * 1024); // 128 kbps
            format.setInteger(MediaFormat.KEY_AAC_PROFILE, MediaCodecInfo.CodecProfileLevel.AACObjectLC);
            
            Log.i(TAG, "Configuring audio encoder with format: " + format);
            
            audioEncoder.configure(format, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE);
            audioEncoder.start();
            
            audioInputBuffers = audioEncoder.getInputBuffers();
            audioOutputBuffers = audioEncoder.getOutputBuffers();
            audioEncoderStarted = true;
            
            Log.i(TAG, "Audio encoder initialized successfully");
            
        } catch (IOException e) {
            Log.e(TAG, "Failed to create audio encoder", e);
            audioEncoder = null;
        }
    }
}
