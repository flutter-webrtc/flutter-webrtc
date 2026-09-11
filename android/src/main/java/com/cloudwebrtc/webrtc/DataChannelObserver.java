package com.cloudwebrtc.webrtc;

import com.cloudwebrtc.webrtc.utils.AnyThreadSink;
import com.cloudwebrtc.webrtc.utils.ConstraintsMap;

import org.webrtc.DataChannel;

import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;

class DataChannelObserver implements DataChannel.Observer, EventChannel.StreamHandler {

    private final String flutterId;
    private final DataChannel dataChannel;

    private final EventChannel eventChannel;
    private EventChannel.EventSink eventSink;
    private final ArrayList eventQueue = new ArrayList();
    private final Object eventLock = new Object();
    private boolean disposed = false;

    DataChannelObserver(BinaryMessenger messenger, String peerConnectionId, String flutterId,
                        DataChannel dataChannel) {
        this.flutterId = flutterId;
        this.dataChannel = dataChannel;
        eventChannel =
                new EventChannel(messenger, "FlutterWebRTC/dataChannelEvent" + peerConnectionId + flutterId);
        eventChannel.setStreamHandler(this);
    }

    /**
     * Stops delivering events for this data channel and releases everything that
     * keeps this observer alive. The binary messenger holds on to a stream
     * handler until it is cleared, so without this the observer and the data
     * channel it points at stay alive for the whole life of the process. The
     * native observer is unregistered first so that the JNI adapter holding a
     * global reference to this object is destroyed too. Calling this more than
     * once does nothing.
     *
     * Must be called while the data channel is still valid, so before
     * DataChannel.dispose().
     */
    void dispose() {
        if (disposed) {
            return;
        }
        disposed = true;
        dataChannel.unregisterObserver();
        eventChannel.setStreamHandler(null);
        synchronized (eventLock) {
            eventSink = null;
            eventQueue.clear();
        }
    }

    private String dataChannelStateString(DataChannel.State dataChannelState) {
        switch (dataChannelState) {
            case CONNECTING:
                return "connecting";
            case OPEN:
                return "open";
            case CLOSING:
                return "closing";
            case CLOSED:
                return "closed";
        }
        return "";
    }

    @Override
    public void onListen(Object o, EventChannel.EventSink sink) {
        synchronized (eventLock) {
            eventSink = new AnyThreadSink(sink);
            for (Object event : eventQueue) {
                eventSink.success(event);
            }
            eventQueue.clear();
        }
    }

    @Override
    public void onCancel(Object o) {
        synchronized (eventLock) {
            eventSink = null;
        }
    }
    
    @Override
    public void onBufferedAmountChange(long amount) {
        ConstraintsMap params = new ConstraintsMap();
        params.putString("event", "dataChannelBufferedAmountChange");
        params.putInt("id", dataChannel.id());
        params.putLong("bufferedAmount", dataChannel.bufferedAmount());
        params.putLong("changedAmount", amount);
        sendEvent(params);
    }

    @Override
    public void onStateChange() {
        ConstraintsMap params = new ConstraintsMap();
        params.putString("event", "dataChannelStateChanged");
        params.putInt("id", dataChannel.id());
        params.putString("state", dataChannelStateString(dataChannel.state()));
        sendEvent(params);
    }

    @Override
    public void onMessage(DataChannel.Buffer buffer) {
        ConstraintsMap params = new ConstraintsMap();
        params.putString("event", "dataChannelReceiveMessage");
        params.putInt("id", dataChannel.id());

        byte[] bytes;
        if (buffer.data.hasArray()) {
            bytes = buffer.data.array();
        } else {
            bytes = new byte[buffer.data.remaining()];
            buffer.data.get(bytes);
        }

        if (buffer.binary) {
            params.putString("type", "binary");
            params.putByte("data", bytes);
        } else {
            params.putString("type", "text");
            params.putString("data", new String(bytes, StandardCharsets.UTF_8));
        }

        sendEvent(params);
    }

    private void sendEvent(ConstraintsMap params) {
        synchronized (eventLock) {
            if (eventSink != null) {
                eventSink.success(params.toMap());
            } else {
                eventQueue.add(params.toMap());
            }
        }
    }
}
