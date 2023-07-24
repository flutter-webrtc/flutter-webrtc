package com.cloudwebrtc.webrtc.audio;

import android.annotation.SuppressLint;
import android.content.Context;
import android.media.AudioDeviceInfo;
import android.media.AudioManager;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.twilio.audioswitch.AudioDevice;
import com.twilio.audioswitch.AudioSwitch;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Objects;
import java.util.Map;

import kotlin.Unit;
import kotlin.jvm.functions.Function2;

public class AudioSwitchManager {

    public static final String TAG = "AudioSwitchManager";

    @SuppressLint("StaticFieldLeak")
    public static AudioSwitchManager instance;
    @NonNull
    private final Context context;
    @NonNull
    private final AudioManager audioManager;

    public boolean loggingEnabled;
    private boolean isActive = false;
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

    private boolean _speakerphoneOn = false;

    /**
     * The audio focus mode to use while started.
     *
     * Defaults to [AudioManager.AUDIOFOCUS_GAIN].
     */
    private int focusMode = AudioManager.AUDIOFOCUS_GAIN;

    /**
     * The audio mode to use while started.
     *
     * Defaults to [AudioManager.MODE_NORMAL].
     */
    private int audioMode = AudioManager.MODE_NORMAL;

    public AudioSwitchManager(@NonNull Context context) {
        this.context = context;
        this.audioManager = (AudioManager) context.getSystemService(Context.AUDIO_SERVICE);

        preferredDeviceList = new ArrayList<>();
        preferredDeviceList.add(AudioDevice.BluetoothHeadset.class);
        preferredDeviceList.add(AudioDevice.WiredHeadset.class);
        preferredDeviceList.add(AudioDevice.Speakerphone.class);
        preferredDeviceList.add(AudioDevice.Earpiece.class);
        initAudioSwitch();
    }

    private void initAudioSwitch() {
        if (audioSwitch == null) {
            handler.removeCallbacksAndMessages(null);
            handler.postAtFrontOfQueue(() -> {
                audioSwitch = new AudioSwitch(
                        context,
                        loggingEnabled,
                        audioFocusChangeListener,
                        preferredDeviceList
                );
                audioSwitch.setFocusMode(focusMode);
                audioSwitch.setAudioMode(audioMode);
                audioSwitch.start(audioDeviceChangeListener);
            });
        }
    }

    public void start() {
        if (audioSwitch != null) {
            handler.removeCallbacksAndMessages(null);
            handler.postAtFrontOfQueue(() -> {
                if (!isActive) {
                    Objects.requireNonNull(audioSwitch).activate();
                    audioManager.setSpeakerphoneOn(_speakerphoneOn);
                    isActive = true;
                }
            });
        }
    }

    public void stop() {
        if (audioSwitch != null) {
            handler.removeCallbacksAndMessages(null);
            handler.postAtFrontOfQueue(() -> {
                if (isActive) {
                    Objects.requireNonNull(audioSwitch).deactivate();
                    isActive = false;
                }
            });
        }
    }

    public void setMicrophoneMute(boolean mute){
        audioManager.setMicrophoneMute(mute);
    }

    @Nullable
    public AudioDevice selectedAudioDevice() {
        return Objects.requireNonNull(audioSwitch).getSelectedAudioDevice();
    }

    @NonNull
    public List<AudioDevice> availableAudioDevices() {
        return Objects.requireNonNull(audioSwitch).getAvailableAudioDevices();
    }

    public void selectAudioOutput(@NonNull Class<? extends AudioDevice> audioDeviceClass) {
        handler.post(() -> {
            List<AudioDevice> devices = availableAudioDevices();
            AudioDevice audioDevice = null;
            for (AudioDevice device : devices) {
                if (device.getClass().equals(audioDeviceClass)) {
                    audioDevice = device;
                    break;
                }
            }
            if (audioDevice != null) {
                Objects.requireNonNull(audioSwitch).selectDevice(audioDevice);
            }
        });
    }

    public void enableSpeakerphone(boolean enable) {
        audioManager.setSpeakerphoneOn(enable);
        _speakerphoneOn = enable;
    }

    public void enableSpeakerButPreferBluetooth() {
        AudioDeviceInfo bluetoothDevice = null;
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
            AudioDeviceInfo[] devices = audioManager.getDevices(AudioManager.GET_DEVICES_OUTPUTS);
            for (AudioDeviceInfo device : devices) {
                if (device.getType() == AudioDeviceInfo.TYPE_BLUETOOTH_SCO) {
                    bluetoothDevice = device;
                    break;
                }
            }
        }
        if (bluetoothDevice == null) {
            audioManager.setSpeakerphoneOn(_speakerphoneOn);
        }
    }

    public void selectAudioOutput(@Nullable AudioDeviceKind kind) {
        if (kind != null) {
            selectAudioOutput(kind.audioDeviceClass);
        }
    }

    public void setAudioConfiguration(Map<String, Object> configuration) {
        if(configuration == null) {
            return;
        }

        String audioMode = null;
        if (configuration.get("androidAudioMode") instanceof String) {
            audioMode = (String) configuration.get("androidAudioMode");
        }

        String focusMode = null;
        if (configuration.get("androidAudioFocusMode") instanceof String) {
            focusMode = (String) configuration.get("androidAudioFocusMode");
        }

        setAudioMode(audioMode);
        setFocusMode(focusMode);
    }

    public void setAudioMode(@Nullable String audioModeString) {
        if (audioModeString == null) {
            return;
        }

        int audioMode = -1;
        switch (audioModeString) {
            case "normal":
                audioMode = AudioManager.MODE_NORMAL;
                break;
            case "callScreening":
                audioMode = AudioManager.MODE_CALL_SCREENING;
                break;
            case "inCall":
                audioMode = AudioManager.MODE_IN_CALL;
                break;
            case "inCommunication":
                audioMode = AudioManager.MODE_IN_COMMUNICATION;
                break;
            case "ringtone":
                audioMode = AudioManager.MODE_RINGTONE;
                break;
            default:
                Log.w(TAG, "Unknown audio mode: " + audioModeString);
                break;
        }

        // Valid audio modes start from 0
        if (audioMode >= 0) {
            this.audioMode = audioMode;
            if (audioSwitch != null) {
                Objects.requireNonNull(audioSwitch).setAudioMode(audioMode);
            }
        }
    }

    public void setFocusMode(@Nullable String focusModeString) {
        if (focusModeString == null) {
            return;
        }

        int focusMode = -1;
        switch(focusModeString) {
            case "gain":
                focusMode = AudioManager.AUDIOFOCUS_GAIN;
                break;
            case "gainTransient":
                focusMode = AudioManager.AUDIOFOCUS_GAIN_TRANSIENT;
                break;
            case "gainTransientExclusive":
                focusMode = AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_EXCLUSIVE;
                break;
            case "gainTransientMayDuck":
                focusMode = AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK;
                break;
            default:
                Log.w(TAG, "Unknown audio focus mode: " + focusModeString);
                break;
        }

        // Valid focus modes start from 1
        if (focusMode > 0) {
            this.focusMode = focusMode;
            if (audioSwitch != null) {
                Objects.requireNonNull(audioSwitch).setFocusMode(focusMode);
            }
        }
    }
}
