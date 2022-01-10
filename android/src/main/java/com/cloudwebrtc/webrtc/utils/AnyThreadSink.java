package com.cloudwebrtc.webrtc.utils;

import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import io.flutter.plugin.common.EventChannel;

public final class AnyThreadSink implements EventChannel.EventSink {
    private final EventChannel.EventSink eventSink;
    private final Handler handler = new Handler(Looper.getMainLooper());

    public AnyThreadSink(EventChannel.EventSink eventSink) {
        this.eventSink = eventSink;
    }

    @Override
    public void success(Object o) {
        post(()->eventSink.success(o));
    }

    @Override
    public void error(String s, String s1, Object o) {
        post(()->eventSink.error(s, s1, o));
    }

    @Override
    public void endOfStream() {
        post(eventSink::endOfStream);
    }

    private void post(@NonNull Runnable r) {
        if(Looper.getMainLooper() == Looper.myLooper()){
            r.run();
        }else{
            handler.post(r);
        }
    }
}
