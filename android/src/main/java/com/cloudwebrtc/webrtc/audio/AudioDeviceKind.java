package com.cloudwebrtc.webrtc.audio;

import androidx.annotation.Nullable;

import com.twilio.audioswitch.AudioDevice;

public enum AudioDeviceKind {
    BLUETOOTH("bluetooth", AudioDevice.BluetoothHeadset.class),
    WIRED_HEADSET("wired-headset", AudioDevice.WiredHeadset.class),
    SPEAKER("speaker", AudioDevice.Speakerphone.class),
    EARPIECE("earpiece", AudioDevice.Earpiece.class);

    public final String typeName;
    public final Class<? extends AudioDevice> audioDeviceClass;

    AudioDeviceKind(String typeName, Class<? extends AudioDevice> audioDeviceClass) {
        this.typeName = typeName;
        this.audioDeviceClass = audioDeviceClass;
    }

    @Nullable
    public static AudioDeviceKind fromAudioDevice(AudioDevice audioDevice) {
        for (AudioDeviceKind kind : values()) {
            if (kind.audioDeviceClass.equals(audioDevice.getClass())) {
                return kind;
            }
        }
        return null;
    }

    @Nullable
    public static AudioDeviceKind fromTypeName(String typeName) {
        for (AudioDeviceKind kind : values()) {
            if (kind.typeName.equals(typeName)) {
                return kind;
            }
        }
        return null;
    }
}
