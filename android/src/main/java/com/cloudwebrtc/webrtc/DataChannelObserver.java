package com.cloudwebrtc.webrtc;

import java.nio.charset.Charset;
import java.util.HashMap;
import java.util.Map;

import android.util.Base64;

import org.webrtc.DataChannel;

import io.flutter.plugin.common.EventChannel;

class DataChannelObserver implements DataChannel.Observer, EventChannel.StreamHandler {
    private final int mId;
    private final DataChannel mDataChannel;
    private final int peerConnectionId;
    private final FlutterWebRTCPlugin plugin;
    private EventChannel eventChannel;
    private EventChannel.EventSink eventSink;

    DataChannelObserver(FlutterWebRTCPlugin plugin, int peerConnectionId, int id, DataChannel dataChannel) {
        this.peerConnectionId = peerConnectionId;
        mId = id;
        mDataChannel = dataChannel;
        this.plugin = plugin;

        this.eventChannel =
                new EventChannel(
                        plugin.registrar().messenger(),
                        "cloudwebrtc.com/WebRTC/peerDataChannelEvent" + dataChannel);
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
        eventSink = sink;
    }

    @Override
    public void onCancel(Object o) {
        eventSink = null;
    }

    @Override
    public void onBufferedAmountChange(long amount) {
    }

    @Override
    public void onStateChange() {
        ConstraintsMap params = new ConstraintsMap();
        params.putInt("id", mId);
        params.putInt("peerConnectionId", peerConnectionId);
        params.putString("state", dataChannelStateString(mDataChannel.state()));
        sendEvent("dataChannelStateChanged", params);
    }

    @Override
    public void onMessage(DataChannel.Buffer buffer) {
        ConstraintsMap params = new ConstraintsMap();
        params.putInt("id", mId);
        params.putInt("peerConnectionId", peerConnectionId);

        byte[] bytes;
        if (buffer.data.hasArray()) {
            bytes = buffer.data.array();
        } else {
            bytes = new byte[buffer.data.remaining()];
            buffer.data.get(bytes);
        }

        if (buffer.binary) {
            params.putString("type", "binary");
            params.putString("data", Base64.encodeToString(bytes, Base64.NO_WRAP));
        } else {
            params.putString("type", "text");
            params.putString("data", new String(bytes, Charset.forName("UTF-8")));
        }

        sendEvent("dataChannelReceiveMessage", params);
    }

    void sendEvent(String eventName,  ConstraintsMap params) {
        Map<String, Object> event = new HashMap<>();
        event.put("event", eventName);
        event.put("body", params.toMap());
        eventSink.success(event);
    }
}
