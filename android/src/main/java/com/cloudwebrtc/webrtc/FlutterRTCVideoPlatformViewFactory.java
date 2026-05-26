package com.cloudwebrtc.webrtc;

import android.content.Context;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class FlutterRTCVideoPlatformViewFactory extends PlatformViewFactory {
    public static final String VIEW_TYPE = "rtc_video_platform_view";

    private final BinaryMessenger messenger;
    private final MethodCallHandlerImpl methodCallHandler;

    public FlutterRTCVideoPlatformViewFactory(
            BinaryMessenger messenger,
            MethodCallHandlerImpl methodCallHandler) {
        super(StandardMessageCodec.INSTANCE);
        this.messenger = messenger;
        this.methodCallHandler = methodCallHandler;
    }

    @Override
    public PlatformView create(Context context, int viewId, Object args) {
        FlutterRTCVideoPlatformView view = new FlutterRTCVideoPlatformView(
                context,
                messenger,
                viewId,
                methodCallHandler);
        methodCallHandler.registerPlatformView(viewId, view);
        return view;
    }
}
