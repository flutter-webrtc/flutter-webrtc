package com.cloudwebrtc.webrtc.audio;

import android.annotation.SuppressLint;
import android.content.Context;
import android.media.AudioAttributes;
import android.media.AudioManager;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.twilio.audioswitch.AudioDevice;
import com.twilio.audioswitch.AudioSwitch;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;

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
    public AudioManager.OnAudioFocusChangeListener audioFocusChangeListener = (i -> {
    });

    @NonNull
    public List<Class<? extends AudioDevice>> preferredDeviceList;

    // AudioSwitch is not threadsafe, so all calls should be done on the main thread.
    private final Handler handler = new Handler(Looper.getMainLooper());

    @Nullable
    private AudioSwitch audioSwitch;

    /**
     * When true, AudioSwitchManager will request audio focus on start and abandon on stop.
     * <br />
     * Defaults to true.
     */
    private boolean manageAudioFocus = true;

    /**
     * The audio focus mode to use while started.
     * <br />
     * Defaults to AudioManager.AUDIOFOCUS_GAIN.
     */
    private int focusMode = AudioManager.AUDIOFOCUS_GAIN;

    /**
     * The audio mode to use while started.
     * <br />
     * Defaults to AudioManager.MODE_NORMAL.
     */
    private int audioMode = AudioManager.MODE_IN_COMMUNICATION;

    /**
     * The audio stream type to use when requesting audio focus on pre-O devices.
     * <br />
     * Defaults to AudioManager.STREAM_VOICE_CALL.
     * <br />
     * Refer to this <a href="https://source.android.com/docs/core/audio/attributes#compatibility">compatibility table</a>
     * to ensure that your values match between android versions.
     * <br />
     * Note: Manual audio routing may not work appropriately when using non-default values.
     */
    private int audioStreamType = AudioManager.STREAM_VOICE_CALL;

    /**
     * The audio attribute usage type to use when requesting audio focus on devices O and beyond.
     * <br />
     * Defaults to AudioAttributes.USAGE_VOICE_COMMUNICATION.
     * <br />
     * Refer to this <a href="https://source.android.com/docs/core/audio/attributes#compatibility">compatibility table</a>
     * to ensure that your values match between android versions.
     * <br />
     * Note: Manual audio routing may not work appropriately when using non-default values.
     */
    private int audioAttributeUsageType = AudioAttributes.USAGE_VOICE_COMMUNICATION;

    /**
     * The audio attribute content type to use when requesting audio focus on devices O and beyond.
     * <br />
     * Defaults to AudioAttributes.CONTENT_TYPE_SPEECH.
     * <br />
     * Refer to this <a href="https://source.android.com/docs/core/audio/attributes#compatibility">compatibility table</a>
     * to ensure that your values match between android versions.
     * <br />
     * Note: Manual audio routing may not work appropriately when using non-default values.
     */
    private int audioAttributeContentType = AudioAttributes.CONTENT_TYPE_SPEECH;

    /**
     * On certain Android devices, audio routing does not function properly and bluetooth microphones will not work
     * unless audio mode is set to [AudioManager.MODE_IN_COMMUNICATION] or [AudioManager.MODE_IN_CALL].
     *
     * AudioSwitchManager by default will not handle audio routing in those cases to avoid audio issues.
     *
     * If this set to true, AudioSwitchManager will attempt to do audio routing, though behavior is undefined.
     */
    private boolean forceHandleAudioRouting = false;

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
                audioSwitch.setManageAudioFocus(manageAudioFocus);
                audioSwitch.setFocusMode(focusMode);
                audioSwitch.setAudioMode(audioMode);
                audioSwitch.setAudioStreamType(audioStreamType);
                audioSwitch.setAudioAttributeContentType(audioAttributeContentType);
                audioSwitch.setAudioAttributeUsageType(audioAttributeUsageType);
                audioSwitch.setForceHandleAudioRouting(forceHandleAudioRouting);
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

    public void setMicrophoneMute(boolean mute) {
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

    private void updatePreferredDeviceList(boolean speakerOn) {
        preferredDeviceList = new ArrayList<>();
        preferredDeviceList.add(AudioDevice.BluetoothHeadset.class);
        preferredDeviceList.add(AudioDevice.WiredHeadset.class);
        if (speakerOn) {
            preferredDeviceList.add(AudioDevice.Speakerphone.class);
            preferredDeviceList.add(AudioDevice.Earpiece.class);
        } else {
            preferredDeviceList.add(AudioDevice.Earpiece.class);
            preferredDeviceList.add(AudioDevice.Speakerphone.class);
        }
        handler.post(() -> {
            Objects.requireNonNull(audioSwitch).setPreferredDeviceList(preferredDeviceList);
        });
    }

    public void enableSpeakerphone(boolean enable) {
        updatePreferredDeviceList(enable);
        if (enable) {
            selectAudioOutput(AudioDevice.Speakerphone.class);
        } else {
            List<AudioDevice> devices = availableAudioDevices();
            AudioDevice audioDevice = null;
            for (AudioDevice device : devices) {
                if (device.getClass().equals(AudioDevice.BluetoothHeadset.class)) {
                    audioDevice = device;
                    break;
                } else if (device.getClass().equals(AudioDevice.WiredHeadset.class)) {
                    audioDevice = device;
                    break;
                } else if (device.getClass().equals(AudioDevice.Earpiece.class)) {
                    audioDevice = device;
                    break;
                }
            }
            if (audioDevice != null) {
                selectAudioOutput(audioDevice.getClass());
            } else {
                handler.post(() -> {
                    Objects.requireNonNull(audioSwitch).selectDevice(null);
                });
            }
        }
    }

    public void enableSpeakerButPreferBluetooth() {
        List<AudioDevice> devices = availableAudioDevices();
        AudioDevice audioDevice = null;
        for (AudioDevice device : devices) {
            if (device.getClass().equals(AudioDevice.BluetoothHeadset.class)) {
                audioDevice = device;
                break;
            } else if (device.getClass().equals(AudioDevice.WiredHeadset.class)) {
                audioDevice = device;
                break;
            }
        }

        if (audioDevice == null) {
            selectAudioOutput(AudioDevice.Speakerphone.class);
        } else {
            selectAudioOutput(audioDevice.getClass());
        }
    }

    public void selectAudioOutput(@Nullable AudioDeviceKind kind) {
        if (kind != null) {
            selectAudioOutput(kind.audioDeviceClass);
        }
    }

    public void setAudioConfiguration(Map<String, Object> configuration) {
        if (configuration == null) {
            return;
        }

        Boolean manageAudioFocus = null;
        if (configuration.get("manageAudioFocus") instanceof Boolean) {
            manageAudioFocus = (Boolean) configuration.get("manageAudioFocus");
        }
        setManageAudioFocus(manageAudioFocus);

        String audioMode = null;
        if (configuration.get("androidAudioMode") instanceof String) {
            audioMode = (String) configuration.get("androidAudioMode");
        }
        setAudioMode(audioMode);

        String focusMode = null;
        if (configuration.get("androidAudioFocusMode") instanceof String) {
            focusMode = (String) configuration.get("androidAudioFocusMode");
        }
        setFocusMode(focusMode);

        String streamType = null;
        if (configuration.get("androidAudioStreamType") instanceof String) {
            streamType = (String) configuration.get("androidAudioStreamType");
        }
        setAudioStreamType(streamType);

        String usageType = null;
        if (configuration.get("androidAudioAttributesUsageType") instanceof String) {
            usageType = (String) configuration.get("androidAudioAttributesUsageType");
        }
        setAudioAttributesUsageType(usageType);

        String contentType = null;
        if (configuration.get("androidAudioAttributesContentType") instanceof String) {
            contentType = (String) configuration.get("androidAudioAttributesContentType");
        }
        setAudioAttributesContentType(contentType);

        Boolean forceHandleAudioRouting = null;
        if (configuration.get("forceHandleAudioRouting") instanceof Boolean) {
            forceHandleAudioRouting = (Boolean) configuration.get("forceHandleAudioRouting");
        }
        setForceHandleAudioRouting(forceHandleAudioRouting);
    }

    public void setManageAudioFocus(@Nullable Boolean manage) {
        if (manage != null && audioSwitch != null) {
            this.manageAudioFocus = manage;
            Objects.requireNonNull(audioSwitch).setManageAudioFocus(this.manageAudioFocus);
        }
    }

    public void setAudioMode(@Nullable String audioModeString) {
        Integer audioMode = AudioUtils.getAudioModeForString(audioModeString);

        if (audioMode == null) {
            return;
        }
        this.audioMode = audioMode;
        if (audioSwitch != null) {
            Objects.requireNonNull(audioSwitch).setAudioMode(audioMode);
        }
    }

    public void setFocusMode(@Nullable String focusModeString) {
        Integer focusMode = AudioUtils.getFocusModeForString(focusModeString);

        if (focusMode == null) {
            return;
        }
        this.focusMode = focusMode;
        if (audioSwitch != null) {
            Objects.requireNonNull(audioSwitch).setFocusMode(focusMode);
        }
    }

    public void setAudioStreamType(@Nullable String streamTypeString) {
        Integer streamType = AudioUtils.getStreamTypeForString(streamTypeString);

        if (streamType == null) {
            return;
        }
        this.audioStreamType = streamType;
        if (audioSwitch != null) {
            Objects.requireNonNull(audioSwitch).setAudioStreamType(this.audioStreamType);
        }
    }

    public void setAudioAttributesUsageType(@Nullable String usageTypeString) {
        Integer usageType = AudioUtils.getAudioAttributesUsageTypeForString(usageTypeString);

        if (usageType == null) {
            return;
        }
        this.audioAttributeUsageType = usageType;
        if (audioSwitch != null) {
            Objects.requireNonNull(audioSwitch).setAudioAttributeUsageType(this.audioAttributeUsageType);
        }
    }

    public void setAudioAttributesContentType(@Nullable String contentTypeString) {
        Integer contentType = AudioUtils.getAudioAttributesContentTypeFromString(contentTypeString);

        if (contentType == null) {
            return;
        }
        this.audioAttributeContentType = contentType;
        if (audioSwitch != null) {
            Objects.requireNonNull(audioSwitch).setAudioAttributeContentType(this.audioAttributeContentType);
        }
    }

    public void setForceHandleAudioRouting(@Nullable Boolean force) {
        if (force != null && audioSwitch != null) {
            this.forceHandleAudioRouting = force;
            Objects.requireNonNull(audioSwitch).setForceHandleAudioRouting(this.forceHandleAudioRouting);
        }
    }

    public void clearCommunicationDevice() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            audioManager.clearCommunicationDevice();
        }
    }
}
