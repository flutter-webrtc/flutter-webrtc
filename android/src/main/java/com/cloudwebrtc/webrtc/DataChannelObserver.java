package com.cloudwebrtc.webrtc;

import java.nio.charset.Charset;
import android.util.Base64;

import org.webrtc.DataChannel;
import io.flutter.plugin.common.EventChannel;
import com.cloudwebrtc.webrtc.utils.AnyThreadSink;
import com.cloudwebrtc.webrtc.utils.ConstraintsMap;

class DataChannelObserver implements DataChannel.Observer, EventChannel.StreamHandler {
    private final int mId;
    private final DataChannel mDataChannel;
    private final String peerConnectionId;
    private final FlutterWebRTCPlugin plugin;
    private EventChannel eventChannel;
    private EventChannel.EventSink eventSink;

    DataChannelObserver(FlutterWebRTCPlugin plugin, String peerConnectionId, int id, DataChannel dataChannel) {
        this.peerConnectionId = peerConnectionId;
        mId = id;
        mDataChannel = dataChannel;
        this.plugin = plugin;
        this.eventChannel =
                new EventChannel(
                        plugin.registrar().messenger(),
                        "FlutterWebRTC/dataChannelEvent" + String.valueOf(id));
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
    }

    @Override
    public void onCancel(Object o) {
        eventSink = null;
    }

    @Override
    public void onBufferedAmountChange(long amount) { }

    @Override
    public void onStateChange() {
        ConstraintsMap params = new ConstraintsMap();
        params.putString("event", "dataChannelStateChanged");
        params.putInt("id", mDataChannel.id());
        params.putString("state", dataChannelStateString(mDataChannel.state()));
        sendEvent(params);
    }

    @Override
    public void onMessage(DataChannel.Buffer buffer) {
        ConstraintsMap params = new ConstraintsMap();
        params.putString("event", "dataChannelReceiveMessage");
        params.putInt("id", mDataChannel.id());

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
            params.putString("data", new String(bytes, Charset.forName("UTF-8")));
        }

        sendEvent(params);
    }

    void sendEvent(ConstraintsMap params) {
        if(eventSink != null)
            eventSink.success(params.toMap());
    }
}
