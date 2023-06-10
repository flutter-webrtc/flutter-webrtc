package com.cloudwebrtc.webrtc.record;

import android.os.Handler;
import android.os.HandlerThread;
import android.util.Log;

import com.naman14.androidlame.AndroidLame;
import com.naman14.androidlame.LameBuilder;

import org.webrtc.audio.JavaAudioDeviceModule;

import java.io.BufferedOutputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Queue;
import java.util.concurrent.ConcurrentLinkedQueue;

import org.webrtc.audio.JavaAudioDeviceModule.SamplesReadyCallback;

public class AudioFileRender implements SamplesReadyCallback {
    private static final String TAG = "AudioFileRenderer";
    private static final int OUTPUT_CHANNEL = 1;
    private static final int OUT_SAMPLE = 8000;

    private static final int OUT_BITRATE = 128;
    private static final int MP3_BUFFER_SIZE = 8192;
    private static final int OUTPUT_STREAM_BUFFER = 8192;

    private Queue<JavaAudioDeviceModule.AudioSamples> sources = new ConcurrentLinkedQueue<>();

    private final HandlerThread captureThread;

    private final Handler captureThreadHandler;

    private String outputFile;
    private BufferedOutputStream outputStream;

    private AndroidLame encoder;
    private byte[] mp3Buffer = new byte[MP3_BUFFER_SIZE];
    private boolean isRunning;


    AudioFileRender(String outputFile) {
        this.outputFile = outputFile;
        captureThread = new HandlerThread(TAG + "RenderThread");
        captureThread.start();
        captureThreadHandler = new Handler(captureThread.getLooper());

        this.init();
        this.startCapture();
    }

    private void init() {
        try {
            outputStream = new BufferedOutputStream(new FileOutputStream(outputFile), OUTPUT_STREAM_BUFFER);
        } catch (FileNotFoundException e) {
            Log.e(TAG, "Write Error: encode error " + e.getMessage());
        }
    }

    private short[] bytesToShorts(byte[] sources) {
        short[] dst = new short[sources.length / 2];
        int j = 0;
        for (int i = 0; i < dst.length; i++) {
            dst[i] = bytesToShort16(sources[j++], sources[j++]);
        }
        return dst;
    }

    private short bytesToShort16(byte lowByte, byte highByte) {
        return (short) ((highByte << 8) | (lowByte & 0xFF));
    }

    private void startCapture() {
        isRunning = true;
        captureThreadHandler.post(new Runnable() {
            @Override
            public void run() {
                JavaAudioDeviceModule.AudioSamples samples = sources.poll();
                if (samples != null) {
                    if (encoder == null) {
                        LameBuilder builder = new LameBuilder()
                                .setInSampleRate(samples.getSampleRate())
                                .setOutChannels(OUTPUT_CHANNEL)
                                .setOutBitrate(OUT_BITRATE)
                                .setOutSampleRate(OUT_SAMPLE);
                        encoder = builder.build();
                    }
                    short[] audioData = bytesToShorts(samples.getData());
                    int bytesEncoded = encoder.encode(audioData, audioData, audioData.length, mp3Buffer);
                    writeToFile(mp3Buffer, bytesEncoded);
                }
                if (isRunning) captureThreadHandler.postDelayed(this, 9);

            }
        });
    }

    private void writeToFile(byte[] content, int len) {
        try {
            if (content == null) {
                mp3Buffer = new byte[MP3_BUFFER_SIZE];
                Log.w(TAG, "Stream content is null, please make sure data!");
                return;
            }
            outputStream.write(content, 0, len);
        } catch (IOException e) {
            Log.e(TAG, "Write Error: encode error " + e.getMessage());
        }
    }

    public void release() {
        isRunning = false;
        captureThreadHandler.post(() -> {
            try {
                if (encoder != null) {
                    int bytesEncoded = encoder.flush(mp3Buffer);
                    writeToFile(mp3Buffer, bytesEncoded);
                    encoder.close();
                }
                outputStream.close();
            } catch (IOException e) {
                Log.e(TAG, "close error: " + e.getMessage());
            }
            // TODO flush to file
            captureThread.quit();
        });
    }


    @Override
    public void onWebRtcAudioRecordSamplesReady(JavaAudioDeviceModule.AudioSamples audioSamples) {
        Log.e(TAG, "hello world");
        // nothing to do
        sources.offer(audioSamples);
    }

}
