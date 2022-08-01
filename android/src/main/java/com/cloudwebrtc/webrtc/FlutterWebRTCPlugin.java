package com.cloudwebrtc.webrtc;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.os.Bundle;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleOwner;
import com.cloudwebrtc.webrtc.audio.AudioDeviceKind;
import com.cloudwebrtc.webrtc.audio.AudioSwitchManager;
import com.cloudwebrtc.webrtc.MethodCallHandlerImpl.AudioManager;
import com.twilio.audioswitch.AudioDevice;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.lifecycle.HiddenLifecycleReference;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.view.TextureRegistry;

import java.util.Collections;
import java.util.Set;
import java.util.List;

/**
 * FlutterWebRTCPlugin
 */
public class FlutterWebRTCPlugin implements FlutterPlugin, ActivityAware {

    static public final String TAG = "FlutterWebRTCPlugin";
    private static Application application;

    private AudioSwitchManager audioSwitchManager;
    private MethodChannel channel;
    private MethodCallHandlerImpl methodCallHandler;
    private LifeCycleObserver observer;
    private Lifecycle lifecycle;

    public FlutterWebRTCPlugin() {
    }

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final FlutterWebRTCPlugin plugin = new FlutterWebRTCPlugin();

        plugin.startListening(registrar.context(), registrar.messenger(), registrar.textures());

        if (registrar.activeContext() instanceof Activity) {
            plugin.methodCallHandler.setActivity((Activity) registrar.activeContext());
        }
        application = ((Application) registrar.context().getApplicationContext());
        application.registerActivityLifecycleCallbacks(plugin.observer);

        registrar.addViewDestroyListener(view -> {
            plugin.stopListening();
            return false;
        });
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        startListening(binding.getApplicationContext(), binding.getBinaryMessenger(),
                binding.getTextureRegistry());
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        stopListening();
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        methodCallHandler.setActivity(binding.getActivity());
        this.observer = new LifeCycleObserver();
        this.lifecycle = ((HiddenLifecycleReference) binding.getLifecycle()).getLifecycle();
        this.lifecycle.addObserver(this.observer);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        methodCallHandler.setActivity(null);
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        methodCallHandler.setActivity(binding.getActivity());
    }

    @Override
    public void onDetachedFromActivity() {
        methodCallHandler.setActivity(null);
        if (this.observer != null) {
            this.lifecycle.removeObserver(this.observer);
            if (this.application!=null) {
                this.application.unregisterActivityLifecycleCallbacks(this.observer);
            }
        }
        this.lifecycle = null;
    }

    private void startListening(final Context context, BinaryMessenger messenger,
                                TextureRegistry textureRegistry) {
        methodCallHandler = new MethodCallHandlerImpl(context, messenger, textureRegistry,
                new AudioManager() {
                    @Override
                    public void onAudioManagerRequested(boolean requested) {
                        if (requested) {
                            if (audioSwitchManager == null) {
                                audioSwitchManager = new AudioSwitchManager(context);
                            }
                            audioSwitchManager.start();
                        } else {
                            if (audioSwitchManager != null) {
                                audioSwitchManager.stop();
                                audioSwitchManager = null;
                            }
                        }
                    }

                    @Override
                    public void setMicrophoneMute(boolean mute) {
                        if (audioSwitchManager != null) {
                            //TODO: audioSwitchManager.setMicrophoneMute(mute);
                        }
                    }

                    @Override
                    public void selectAudioOutput(@Nullable AudioDeviceKind kind) {
                        if (audioSwitchManager != null) {
                            audioSwitchManager.selectAudioOutput(kind);
                        }
                    }

                    @Override
                    public List<AudioDevice> getAvailableAudioOutputDevices() {
                        if (audioSwitchManager != null) {
                            return audioSwitchManager.availableAudioDevices();
                        } else {
                            return Collections.emptyList();
                        }
                    }
                });

        channel = new MethodChannel(messenger, "FlutterWebRTC.Method");
        channel.setMethodCallHandler(methodCallHandler);
    }

    private void stopListening() {
        methodCallHandler.dispose();
        methodCallHandler = null;
        channel.setMethodCallHandler(null);

        if (audioSwitchManager != null) {
            Log.d(TAG, "Stopping the audio manager...");
            audioSwitchManager.stop();
            audioSwitchManager = null;
        }
    }

    // This method is called when the audio manager reports audio device change,
    // e.g. from wired headset to speakerphone.
    private void onAudioManagerDevicesChanged() {
    }

    private class LifeCycleObserver implements Application.ActivityLifecycleCallbacks, DefaultLifecycleObserver {

        @Override
        public void onActivityCreated(Activity activity, Bundle savedInstanceState) {

        }

        @Override
        public void onActivityStarted(Activity activity) {

        }

        @Override
        public void onActivityResumed(Activity activity) {
            if (null != methodCallHandler) {
                methodCallHandler.reStartCamera();
            }
        }

        @Override
        public void onResume(LifecycleOwner owner) {
            if (null != methodCallHandler) {
                methodCallHandler.reStartCamera();
            }
        }

        @Override
        public void onActivityPaused(Activity activity) {

        }

        @Override
        public void onActivityStopped(Activity activity) {

        }

        @Override
        public void onActivitySaveInstanceState(Activity activity, Bundle outState) {

        }

        @Override
        public void onActivityDestroyed(Activity activity) {

        }
    }
}
