package com.cloudwebrtc.webrtc.utils;

import android.os.Handler;
import android.os.Looper;

import io.flutter.plugin.common.EventChannel;

public final class AnyThreadSink implements EventChannel.EventSink {
    private final EventChannel.EventSink eventSink;
    
    public AnyThreadSink(EventChannel.EventSink eventSink) {
        this.eventSink = eventSink;
    }
    
    @Override
    public void success(Object o) {
        final Handler handler = new Handler(Looper.getMainLooper());
        handler.post(()->eventSink.success(o));
    }

    @Override
    public void error(String s, String s1, Object o) {
        final Handler handler = new Handler(Looper.getMainLooper());
        handler.post(()->eventSink.error(s, s1, o));
    }

    @Override
    public void endOfStream() {
        final Handler handler = new Handler(Looper.getMainLooper());
        handler.post(eventSink::endOfStream);
    }
}
