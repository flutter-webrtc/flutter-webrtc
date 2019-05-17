package com.cloudwebrtc.webrtc.utils;

import android.os.Looper;
import android.os.Handler;

import io.flutter.plugin.common.MethodChannel;

public final class AnyThreadResult implements MethodChannel.Result {
    final private MethodChannel.Result result;

    public AnyThreadResult(MethodChannel.Result result) {
        this.result = result;
    }

    @Override
    public void success(Object o) {
        final Handler handler = new Handler(Looper.getMainLooper());
        handler.post(()->result.success(o));
    }

    @Override
    public void error(String s, String s1, Object o) {
        final Handler handler = new Handler(Looper.getMainLooper());
        handler.post(()->result.error(s, s1, o));
    }

    @Override
    public void notImplemented() {
        final Handler handler = new Handler(Looper.getMainLooper());
        handler.post(result::notImplemented);
    }
}
