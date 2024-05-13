package com.cloudwebrtc.webrtc.audio;

import android.media.AudioAttributes;
import android.media.AudioDeviceInfo;
import android.media.AudioManager;
import android.os.Build;
import android.util.Log;

import androidx.annotation.Nullable;

public class AudioUtils {

    private static final String TAG = "AudioUtils";

    @Nullable
    public static Integer getAudioModeForString(@Nullable String audioModeString) {
        if (audioModeString == null) {
            return null;
        }

        Integer audioMode = null;
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

        return audioMode;
    }

    @Nullable
    public static Integer getFocusModeForString(@Nullable String focusModeString) {
        if (focusModeString == null) {
            return null;
        }

        Integer focusMode = null;
        switch (focusModeString) {
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
            case "loss":
                focusMode = AudioManager.AUDIOFOCUS_LOSS;
                break;
            default:
                Log.w(TAG, "Unknown audio focus mode: " + focusModeString);
                break;
        }

        return focusMode;
    }

    @Nullable
    public static Integer getStreamTypeForString(@Nullable String streamTypeString) {
        if (streamTypeString == null) {
            return null;
        }

        Integer streamType = null;
        switch (streamTypeString) {
            case "accessibility":
                streamType = AudioManager.STREAM_ACCESSIBILITY;
                break;
            case "alarm":
                streamType = AudioManager.STREAM_ALARM;
                break;
            case "dtmf":
                streamType = AudioManager.STREAM_DTMF;
                break;
            case "music":
                streamType = AudioManager.STREAM_MUSIC;
                break;
            case "notification":
                streamType = AudioManager.STREAM_NOTIFICATION;
                break;
            case "ring":
                streamType = AudioManager.STREAM_RING;
                break;
            case "system":
                streamType = AudioManager.STREAM_SYSTEM;
                break;
            case "voiceCall":
                streamType = AudioManager.STREAM_VOICE_CALL;
                break;
            default:
                Log.w(TAG, "Unknown audio stream type: " + streamTypeString);
                break;
        }

        return streamType;
    }

    @Nullable
    public static Integer getAudioAttributesUsageTypeForString(@Nullable String usageTypeString) {

        if (usageTypeString == null) {
            return null;
        }

        Integer usageType = null;
        switch (usageTypeString) {
            case "alarm":
                usageType = AudioAttributes.USAGE_ALARM;
                break;
            case "assistanceAccessibility":
                usageType = AudioAttributes.USAGE_ASSISTANCE_ACCESSIBILITY;
                break;
            case "assistanceNavigationGuidance":
                usageType = AudioAttributes.USAGE_ASSISTANCE_NAVIGATION_GUIDANCE;
                break;
            case "assistanceSonification":
                usageType = AudioAttributes.USAGE_ASSISTANCE_SONIFICATION;
                break;
            case "assistant":
                usageType = AudioAttributes.USAGE_ASSISTANT;
                break;
            case "game":
                usageType = AudioAttributes.USAGE_GAME;
                break;
            case "media":
                usageType = AudioAttributes.USAGE_MEDIA;
                break;
            case "notification":
                usageType = AudioAttributes.USAGE_NOTIFICATION;
                break;
            case "notificationEvent":
                usageType = AudioAttributes.USAGE_NOTIFICATION_EVENT;
                break;
            case "notificationRingtone":
                usageType = AudioAttributes.USAGE_NOTIFICATION_RINGTONE;
                break;
            case "unknown":
                usageType = AudioAttributes.USAGE_UNKNOWN;
                break;
            case "voiceCommunication":
                usageType = AudioAttributes.USAGE_VOICE_COMMUNICATION;
                break;
            case "voiceCommunicationSignalling":
                usageType = AudioAttributes.USAGE_VOICE_COMMUNICATION_SIGNALLING;
                break;
            default:
                Log.w(TAG, "Unknown audio attributes usage type: " + usageTypeString);
                break;
        }

        return usageType;
    }

    @Nullable
    public static Integer getAudioAttributesContentTypeFromString(@Nullable String contentTypeString) {

        if (contentTypeString == null) {
            return null;
        }

        Integer contentType = null;
        switch (contentTypeString) {
            case "movie":
                contentType = AudioAttributes.CONTENT_TYPE_MOVIE;
                break;
            case "music":
                contentType = AudioAttributes.CONTENT_TYPE_MUSIC;
                break;
            case "sonification":
                contentType = AudioAttributes.CONTENT_TYPE_SONIFICATION;
                break;
            case "speech":
                contentType = AudioAttributes.CONTENT_TYPE_SPEECH;
                break;
            case "unknown":
                contentType = AudioAttributes.CONTENT_TYPE_UNKNOWN;
                break;
            default:
                Log.w(TAG, "Unknown audio attributes content type:" + contentTypeString);
                break;
        }

        return contentType;

    }

    static public String getAudioDeviceId(AudioDeviceInfo device) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            return "audio-1";
        } else {

            String address = Build.VERSION.SDK_INT < Build.VERSION_CODES.P ? "" : device.getAddress();
            String deviceId = "" + device.getId();
            if (device.getType() == AudioDeviceInfo.TYPE_BUILTIN_MIC) {
                deviceId =   "microphone-" + address;
            }
            if (device.getType() == AudioDeviceInfo.TYPE_WIRED_HEADSET) {
                deviceId = "wired-headset";
            }
            if (device.getType() == AudioDeviceInfo.TYPE_BLUETOOTH_SCO) {
                deviceId = "bluetooth";
            }
            return deviceId;
        }
    }

    static public String getAudioGroupId(AudioDeviceInfo device) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            return "microphone";
        } else {
            String groupId = "" + device.getType();
            if (device.getType() == AudioDeviceInfo.TYPE_BUILTIN_MIC) {
                groupId = "microphone";
            }
            if (device.getType() == AudioDeviceInfo.TYPE_WIRED_HEADSET) {
                groupId = "wired-headset";
            }
            if (device.getType() == AudioDeviceInfo.TYPE_BLUETOOTH_SCO) {
                groupId = "bluetooth";
            }
            return groupId;
        }
    }

    static public String getAudioDeviceLabel(AudioDeviceInfo device) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            return "Audio";
        } else {
            String address = Build.VERSION.SDK_INT < Build.VERSION_CODES.P ? "" : device.getAddress();
            String label = device.getProductName().toString();
            if (device.getType() == AudioDeviceInfo.TYPE_BUILTIN_MIC) {
                label = "Built-in Microphone (" + address + ")";
            }

            if (device.getType() == AudioDeviceInfo.TYPE_WIRED_HEADSET) {
                label = "Wired Headset Microphone";
            }

            if (device.getType() == AudioDeviceInfo.TYPE_BLUETOOTH_SCO) {
                label = device.getProductName().toString();
            }
            return label;
        }
    }
}