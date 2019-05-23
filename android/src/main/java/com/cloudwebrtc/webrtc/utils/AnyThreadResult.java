package com.cloudwebrtc.webrtc.utils;

import android.os.Looper;
import android.os.Handler;

import io.flutter.plugin.common.MethodChannel;

public final class AnyThreadResult implements MethodChannel.Result {
    final private MethodChannel.Result result;
    final private Handler handler = new Handler(Looper.getMainLooper());

    public AnyThreadResult(MethodChannel.Result result) {
        this.result = result;
    }

    @Override
    public void success(Object o) {
        post(()->result.success(o));
    }

    @Override
    public void error(String s, String s1, Object o) {
        post(()->result.error(s, s1, o));
    }

    @Override
    public void notImplemented() {
        post(result::notImplemented);
    }

    private void post(Runnable r) {
        if(Looper.getMainLooper() == Looper.myLooper()){
            r.run();
        }else{
            handler.post(r);
        }
    }
}
