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

    DataChannelObserver(BinaryMessenger messenger, String peerConnectionId, String flutterId,
                        DataChannel dataChannel) {
        this.flutterId = flutterId;
        this.dataChannel = dataChannel;
        eventChannel =
                new EventChannel(messenger, "FlutterWebRTC/dataChannelEvent" + peerConnectionId + flutterId);
        eventChannel.setStreamHandler(this);
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
        eventSink = new AnyThreadSink(sink);
        for(Object event : eventQueue) {
            eventSink.success(event);
        }
        eventQueue.clear();
    }

    @Override
    public void onCancel(Object o) {
        eventSink = null;
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
        if (eventSink != null) {
            eventSink.success(params.toMap());
        } else {
            eventQueue.add(params.toMap());
        }
    }
}
