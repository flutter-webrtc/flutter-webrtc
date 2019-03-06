package org.webrtc.audio;

import android.media.AudioTrack;
import android.util.Log;

import com.cloudwebrtc.webrtc.record.AudioTrackInterceptor;

import org.webrtc.audio.JavaAudioDeviceModule.SamplesReadyCallback;

import java.lang.reflect.Field;

/**
 * Awful hack
 * It must be in this package, because WebRtcAudioTrack is package-private
 * **/
public abstract class WebRtcAudioTrackUtils {

    static private final String TAG = "WebRtcAudioTrackUtils";

    public static void attachOutputCallback(
            SamplesReadyCallback callback,
            JavaAudioDeviceModule audioDeviceModule
    ) throws NoSuchFieldException, IllegalAccessException, NullPointerException {
        Field audioOutputField = audioDeviceModule.getClass().getDeclaredField("audioOutput");
        audioOutputField.setAccessible(true);
        WebRtcAudioTrack audioOutput = (WebRtcAudioTrack) audioOutputField.get(audioDeviceModule);
        Log.w(TAG, "Here is a little hedgehog 🦔");
        Field audioTrackField = audioOutput.getClass().getDeclaredField("audioTrack");
        audioTrackField.setAccessible(true);
        AudioTrack audioTrack = (AudioTrack) audioTrackField.get(audioOutput);
        Log.w(TAG, "He is hiding in a forest 🌲🦔🌲");
        AudioTrackInterceptor interceptor = new AudioTrackInterceptor(audioTrack, callback);
        audioTrackField.set(audioOutput, interceptor);
        Log.w(TAG, "Little hedgie in the forest 🌲🌲🌲 but you can't see him");
    }

    public static void detachOutputCallback(JavaAudioDeviceModule audioDeviceModule) {
        try {
            Log.w(TAG, "Where did the hedgie gone? Let's find him");
            Field audioOutputField = audioDeviceModule.getClass().getDeclaredField("audioOutput");
            audioOutputField.setAccessible(true);
            WebRtcAudioTrack audioOutput = (WebRtcAudioTrack) audioOutputField.get(audioDeviceModule);
            Field audioTrackField = audioOutput.getClass().getDeclaredField("audioTrack");
            audioTrackField.setAccessible(true);
            AudioTrack audioTrack = (AudioTrack) audioTrackField.get(audioOutput);
            if (audioTrack instanceof AudioTrackInterceptor) {
                AudioTrackInterceptor interceptor = (AudioTrackInterceptor) audioTrack;
                audioTrackField.set(audioOutput, interceptor.originalTrack);
                Log.w(TAG, "Here he is 🦔");
            } else {
                Log.w(TAG, "Hedgie is lost 😢");
            }
        } catch (Exception e) {
            Log.w(TAG, "Failed to detach callback", e);
        }
    }

}
