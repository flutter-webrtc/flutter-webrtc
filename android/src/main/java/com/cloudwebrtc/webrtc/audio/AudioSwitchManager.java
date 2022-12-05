package com.cloudwebrtc.webrtc.audio;

import android.annotation.SuppressLint;
import android.content.Context;
import android.media.AudioManager;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.twilio.audioswitch.AudioDevice;
import com.twilio.audioswitch.AudioSwitch;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import kotlin.Unit;
import kotlin.jvm.functions.Function2;

public class AudioSwitchManager {
    @SuppressLint("StaticFieldLeak")
    public static AudioSwitchManager instance;
    @NonNull
    private final Context context;
    @NonNull
    private final AudioManager audioManager;

    public boolean loggingEnabled;
    @NonNull
    public Function2<
            ? super List<? extends AudioDevice>,
            ? super AudioDevice,
            Unit> audioDeviceChangeListener = (devices, currentDevice) -> null;

    @NonNull
    public AudioManager.OnAudioFocusChangeListener audioFocusChangeListener = (i -> {});

    @NonNull
    public List<Class<? extends AudioDevice>> preferredDeviceList;

    // AudioSwitch is not threadsafe, so all calls should be done on the main thread.
    private final Handler handler = new Handler(Looper.getMainLooper());

    @Nullable
    private AudioSwitch audioSwitch;

    public AudioSwitchManager(@NonNull Context context) {
        this.context = context;
        this.audioManager = (AudioManager) context.getSystemService(Context.AUDIO_SERVICE);

        preferredDeviceList = new ArrayList<>();
        preferredDeviceList.add(AudioDevice.BluetoothHeadset.class);
        preferredDeviceList.add(AudioDevice.WiredHeadset.class);
        preferredDeviceList.add(AudioDevice.Speakerphone.class);
        preferredDeviceList.add(AudioDevice.Earpiece.class);
    }

    public void start() {
        if (audioSwitch == null) {
            handler.removeCallbacksAndMessages(null);
            handler.postAtFrontOfQueue(() -> {
                audioSwitch = new AudioSwitch(
                        context,
                        loggingEnabled,
                        audioFocusChangeListener,
                        preferredDeviceList
                );
                audioSwitch.start(audioDeviceChangeListener);
                audioSwitch.activate();
            });
        }
    }

    public void stop() {
        handler.removeCallbacksAndMessages(null);
        handler.postAtFrontOfQueue(() -> {
            if (audioSwitch != null) {
                audioSwitch.stop();
            }
            audioSwitch = null;
        });
    }

    public void setMicrophoneMute(boolean mute){
        audioManager.setMicrophoneMute(mute);
    }

    @Nullable
    public AudioDevice selectedAudioDevice() {
        AudioSwitch audioSwitchTemp = audioSwitch;
        if (audioSwitchTemp != null) {
            return audioSwitchTemp.getSelectedAudioDevice();
        } else {
            return null;
        }
    }

    @NonNull
    public List<AudioDevice> availableAudioDevices() {
        AudioSwitch audioSwitchTemp = audioSwitch;
        if (audioSwitchTemp != null) {
            return audioSwitchTemp.getAvailableAudioDevices();
        } else {
            return Collections.emptyList();
        }
    }

    public void selectAudioOutput(@NonNull Class<? extends AudioDevice> audioDeviceClass) {
        handler.post(() -> {
            if (audioSwitch != null) {
                List<AudioDevice> devices = availableAudioDevices();
                AudioDevice audioDevice = null;

                for (AudioDevice device : devices) {
                    if (device.getClass().equals(audioDeviceClass)) {
                        audioDevice = device;
                        break;
                    }
                }

                if (audioDevice != null) {
                    audioSwitch.selectDevice(audioDevice);
                }
            }
        });
    }

    public void enableSpeakerphone(boolean enable) {
        if(enable) {
            audioManager.setSpeakerphoneOn(true);
        } else {
            audioManager.setSpeakerphoneOn(false);
        }
    }
    
    public void selectAudioOutput(@Nullable AudioDeviceKind kind) {
        if (kind != null) {
            selectAudioOutput(kind.audioDeviceClass);
        }
    }
}
