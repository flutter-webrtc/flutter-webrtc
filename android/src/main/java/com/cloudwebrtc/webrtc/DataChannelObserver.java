package com.cloudwebrtc.webrtc;

import com.cloudwebrtc.webrtc.utils.AnyThreadSink;
import com.cloudwebrtc.webrtc.utils.ConstraintsMap;

import org.webrtc.DataChannel;

import java.nio.charset.StandardCharsets;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.AtomicBoolean;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;

class DataChannelObserver implements DataChannel.Observer, EventChannel.StreamHandler {

    private static final int MAX_BATCH_SIZE = 32;
    private static final String BATCH_EVENT_NAME = "dataChannelEventsBatch";
    private static final int DISPATCH_POOL_SIZE =
            Math.max(2, Math.min(4, Runtime.getRuntime().availableProcessors()));
    private static final ExecutorService EVENT_DISPATCH_EXECUTOR =
            Executors.newFixedThreadPool(DISPATCH_POOL_SIZE);

    private final String flutterId;
    private final DataChannel dataChannel;

    private final EventChannel eventChannel;
    private volatile EventChannel.EventSink eventSink;

    private final Object queueLock = new Object();
    private final ArrayDeque<Object> eventQueue = new ArrayDeque<>();
    private final AtomicBoolean flushScheduled = new AtomicBoolean(false);

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
        scheduleFlush();
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
        enqueueEvent(params.toMap());
    }

    private void enqueueEvent(Object event) {
        synchronized (queueLock) {
            eventQueue.addLast(event);
        }
        scheduleFlush();
    }

    private void scheduleFlush() {
        if (!flushScheduled.compareAndSet(false, true)) {
            return;
        }

        EVENT_DISPATCH_EXECUTOR.execute(this::drainQueuedEvents);
    }

    private void drainQueuedEvents() {
        try {
            while (true) {
                EventChannel.EventSink sink = eventSink;
                if (sink == null) {
                    return;
                }

                ArrayList<Object> batch = new ArrayList<>(MAX_BATCH_SIZE);
                synchronized (queueLock) {
                    while (!eventQueue.isEmpty() && batch.size() < MAX_BATCH_SIZE) {
                        batch.add(eventQueue.removeFirst());
                    }
                }

                if (batch.isEmpty()) {
                    return;
                }

                if (batch.size() == 1) {
                    sink.success(batch.get(0));
                } else {
                    Map<String, Object> batchEvent = new HashMap<>();
                    batchEvent.put("event", BATCH_EVENT_NAME);
                    batchEvent.put("events", batch);
                    sink.success(batchEvent);
                }
            }
        } finally {
            flushScheduled.set(false);

            boolean hasPending;
            synchronized (queueLock) {
                hasPending = !eventQueue.isEmpty();
            }

            if (hasPending && eventSink != null) {
                scheduleFlush();
            }
        }
    }
}
