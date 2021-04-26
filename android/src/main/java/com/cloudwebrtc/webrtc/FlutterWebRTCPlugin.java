package com.cloudwebrtc.webrtc;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.os.Bundle;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleOwner;
import com.cloudwebrtc.webrtc.MethodCallHandlerImpl.AudioManager;
import com.cloudwebrtc.webrtc.utils.RTCAudioManager;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.lifecycle.HiddenLifecycleReference;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.view.TextureRegistry;

import java.util.Set;

/**
 * FlutterWebRTCPlugin
 */
public class FlutterWebRTCPlugin implements FlutterPlugin, ActivityAware {

    static public final String TAG = "FlutterWebRTCPlugin";
    private static Application application;

    private RTCAudioManager rtcAudioManager;
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
            this.application.unregisterActivityLifecycleCallbacks(this.observer);
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
                            if (rtcAudioManager == null) {
                                rtcAudioManager = RTCAudioManager.create(context);
                            }
                            rtcAudioManager.start(FlutterWebRTCPlugin.this::onAudioManagerDevicesChanged);
                        } else {
                            if (rtcAudioManager != null) {
                                rtcAudioManager.stop();
                                rtcAudioManager = null;
                            }
                        }
                    }

                    @Override
                    public void setMicrophoneMute(boolean mute) {
                        if (rtcAudioManager != null) {
                            rtcAudioManager.setMicrophoneMute(mute);
                        }
                    }

                    @Override
                    public void setSpeakerphoneOn(boolean on) {
                        if (rtcAudioManager != null) {
                            rtcAudioManager.setSpeakerphoneOn(on);
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

        if (rtcAudioManager != null) {
            Log.d(TAG, "Stopping the audio manager...");
            rtcAudioManager.stop();
            rtcAudioManager = null;
        }
    }

    // This method is called when the audio manager reports audio device change,
    // e.g. from wired headset to speakerphone.
    private void onAudioManagerDevicesChanged(
            final RTCAudioManager.AudioDevice device,
            final Set<RTCAudioManager.AudioDevice> availableDevices) {
        Log.d(TAG, "onAudioManagerDevicesChanged: " + availableDevices + ", "
                + "selected: " + device);
        // TODO(henrika): add callback handler.
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
