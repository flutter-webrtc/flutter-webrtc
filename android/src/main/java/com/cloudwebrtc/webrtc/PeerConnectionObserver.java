package com.cloudwebrtc.webrtc;

import java.io.UnsupportedEncodingException;
import java.nio.ByteBuffer;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import android.util.Base64;
import android.util.Log;
import android.util.SparseArray;
import androidx.annotation.Nullable;

import com.cloudwebrtc.webrtc.utils.AnyThreadSink;
import com.cloudwebrtc.webrtc.utils.ConstraintsArray;
import com.cloudwebrtc.webrtc.utils.ConstraintsMap;

import org.webrtc.AudioTrack;
import org.webrtc.DataChannel;
import org.webrtc.IceCandidate;
import org.webrtc.MediaStream;
import org.webrtc.MediaStreamTrack;
import org.webrtc.PeerConnection;
import org.webrtc.RtpReceiver;
import org.webrtc.StatsObserver;
import org.webrtc.StatsReport;
import org.webrtc.VideoTrack;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel.Result;

class PeerConnectionObserver implements PeerConnection.Observer, EventChannel.StreamHandler {
    private final static String TAG = FlutterWebRTCPlugin.TAG;

    private final SparseArray<DataChannel> dataChannels
        = new SparseArray<DataChannel>();
    private final String id;
    private PeerConnection peerConnection;
    final Map<String, MediaStream> remoteStreams;
    final Map<String, MediaStreamTrack> remoteTracks;
    private final FlutterWebRTCPlugin plugin;

    EventChannel eventChannel;
    EventChannel.EventSink eventSink;

    PeerConnectionObserver(FlutterWebRTCPlugin plugin, String id) {
        this.plugin = plugin;
        this.id = id;
        this.remoteStreams = new HashMap<String, MediaStream>();
        this.remoteTracks = new HashMap<String, MediaStreamTrack>();


        this.eventChannel =
                new EventChannel(
                        plugin.registrar().messenger(),
                        "FlutterWebRTC/peerConnectoinEvent" + id);
        eventChannel.setStreamHandler(this);
        this.eventSink = null;
    }

    @Override
    public void onListen(Object o, EventChannel.EventSink sink) {
        eventSink = new AnyThreadSink(sink);
    }

    @Override
    public void onCancel(Object o) {
        eventSink = null;
    }

    PeerConnection getPeerConnection() {
        return peerConnection;
    }

    void setPeerConnection(PeerConnection peerConnection) {
        this.peerConnection = peerConnection;
    }

    void close() {
        peerConnection.close();
        remoteStreams.clear();
        remoteTracks.clear();
        dataChannels.clear();
    }

    void  dispose() {
        this.close();
        peerConnection.dispose();
        eventChannel.setStreamHandler(null);
    }

    void createDataChannel(String label, ConstraintsMap config, Result result) {
        DataChannel.Init init = new DataChannel.Init();
        if (config != null) {
            if (config.hasKey("id")) {
                init.id = config.getInt("id");
            }
            if (config.hasKey("ordered")) {
                init.ordered = config.getBoolean("ordered");
            }
            if (config.hasKey("maxRetransmitTime")) {
                init.maxRetransmitTimeMs = config.getInt("maxRetransmitTime");
            }
            if (config.hasKey("maxRetransmits")) {
                init.maxRetransmits = config.getInt("maxRetransmits");
            }
            if (config.hasKey("protocol")) {
                init.protocol = config.getString("protocol");
            }
            if (config.hasKey("negotiated")) {
                init.negotiated = config.getBoolean("negotiated");
            }
        }
        DataChannel dataChannel = peerConnection.createDataChannel(label, init);
        // XXX RTP data channels are not defined by the WebRTC standard, have
        // been deprecated in Chromium, and Google have decided (in 2015) to no
        // longer support them (in the face of multiple reported issues of
        // breakages).
        int dataChannelId = init.id;
        if (dataChannel != null && -1 != dataChannelId) {
            dataChannels.put(dataChannelId, dataChannel);
            registerDataChannelObserver(dataChannelId, dataChannel);

            ConstraintsMap params = new ConstraintsMap();
            params.putInt("id", dataChannel.id());
            params.putString("label", dataChannel.label());
            result.success(params.toMap());
        }else{
            result.error("createDataChannel",
                    "Can't create data-channel for id: " + dataChannelId,
                    null);
        }
    }

    void dataChannelClose(int dataChannelId) {
        DataChannel dataChannel = dataChannels.get(dataChannelId);
        if (dataChannel != null) {
            dataChannel.close();
            dataChannels.remove(dataChannelId);
        } else {
            Log.d(TAG, "dataChannelClose() dataChannel is null");
        }
    }

    void dataChannelSend(int dataChannelId, ByteBuffer byteBuffer, Boolean isBinary) {
        DataChannel dataChannel = dataChannels.get(dataChannelId);
        if (dataChannel != null) {
            DataChannel.Buffer buffer = new DataChannel.Buffer(byteBuffer, isBinary);
            dataChannel.send(buffer);
        } else {
            Log.d(TAG, "dataChannelSend() dataChannel is null");
        }
    }

    void getStats(String trackId, final Result result) {
        MediaStreamTrack track = null;
        if (trackId == null
                || trackId.isEmpty()
                || (track = plugin.localTracks.get(trackId)) != null
                || (track = remoteTracks.get(trackId)) != null) {
            peerConnection.getStats(
                    new StatsObserver() {
                        @Override
                        public void onComplete(StatsReport[] reports) {

                            final int reportCount = reports.length;
                            ConstraintsMap params = new ConstraintsMap();
                            ConstraintsArray stats = new ConstraintsArray();

                            for (int i = 0; i < reportCount; ++i) {
                                StatsReport report = reports[i];
                                ConstraintsMap report_map = new ConstraintsMap();

                                report_map.putString("id", report.id);
                                report_map.putString("type", report.type);
                                report_map.putDouble("timestamp", report.timestamp);

                                StatsReport.Value[] values = report.values;
                                ConstraintsMap v_map = new ConstraintsMap();
                                final int valueCount = values.length;
                                for (int j = 0; j < valueCount; ++j) {
                                    StatsReport.Value v = values[j];
                                    v_map.putString(v.name, v.value);
                                }

                                report_map.putMap("values", v_map.toMap());
                                stats.pushMap(report_map);
                            }

                            params.putArray("stats", stats.toArrayList());
                            result.success(params.toMap());
                        }
                    },
                    track);
        } else {
            Log.e(TAG, "peerConnectionGetStats() MediaStreamTrack not found for id: " + trackId);
            result.error("peerConnectionGetStats",
                    "peerConnectionGetStats() MediaStreamTrack not found for id: " + trackId,
                    null);
        }
    }

    @Override
    public void onIceCandidate(final IceCandidate candidate) {
        Log.d(TAG, "onIceCandidate");
        ConstraintsMap params = new ConstraintsMap();
        params.putString("event", "onCandidate");
        ConstraintsMap candidateParams = new ConstraintsMap();
        candidateParams.putInt("sdpMLineIndex", candidate.sdpMLineIndex);
        candidateParams.putString("sdpMid", candidate.sdpMid);
        candidateParams.putString("candidate", candidate.sdp);
        params.putMap("candidate", candidateParams.toMap());
        sendEvent(params);
    }

    @Override
    public void onIceCandidatesRemoved(final IceCandidate[] candidates) {
        Log.d(TAG, "onIceCandidatesRemoved");
    }

    @Override
    public void onIceConnectionChange(PeerConnection.IceConnectionState iceConnectionState) {
        ConstraintsMap params = new ConstraintsMap();
        params.putString("event", "iceConnectionState");
        params.putString("state", iceConnectionStateString(iceConnectionState));
        sendEvent(params);
    }

    @Override
    public void onIceConnectionReceivingChange(boolean var1) {
    }

    @Override
    public void onIceGatheringChange(PeerConnection.IceGatheringState iceGatheringState) {
        Log.d(TAG, "onIceGatheringChange" + iceGatheringState.name());
        ConstraintsMap params = new ConstraintsMap();
        params.putString("event", "iceGatheringState");
        params.putString("state", iceGatheringStateString(iceGatheringState));
        sendEvent(params);
    }

    private String getUIDForStream(MediaStream mediaStream) {
        for (Iterator<Map.Entry<String, MediaStream>> i
                    = remoteStreams.entrySet().iterator();
                i.hasNext();) {
            Map.Entry<String, MediaStream> e = i.next();
            if (e.getValue().equals(mediaStream)) {
                return e.getKey();
            }
        }
        return null;
    }

    @Override
    public void onAddStream(MediaStream mediaStream) {
        String streamUID = null;
        String streamId = mediaStream.getId();
        // The native WebRTC implementation has a special concept of a default
        // MediaStream instance with the label default that the implementation
        // reuses.
        if ("default".equals(streamId)) {
            for (Map.Entry<String, MediaStream> e
                    : remoteStreams.entrySet()) {
                if (e.getValue().equals(mediaStream)) {
                    streamUID = e.getKey();
                    break;
                }
            }
        }

        if (streamUID == null){
            streamUID = plugin.getNextStreamUUID();
            remoteStreams.put(streamId, mediaStream);
        }

        ConstraintsMap params = new ConstraintsMap();
        params.putString("event", "onAddStream");
        params.putString("streamId", streamId);

        ConstraintsArray audioTracks = new ConstraintsArray();
        ConstraintsArray videoTracks = new ConstraintsArray();

        for (int i = 0; i < mediaStream.videoTracks.size(); i++) {
            VideoTrack track = mediaStream.videoTracks.get(i);
            String trackId = track.id();

            remoteTracks.put(trackId, track);

            ConstraintsMap trackInfo = new ConstraintsMap();
            trackInfo.putString("id", trackId);
            trackInfo.putString("label", "Video");
            trackInfo.putString("kind", track.kind());
            trackInfo.putBoolean("enabled", track.enabled());
            trackInfo.putString("readyState", track.state().toString());
            trackInfo.putBoolean("remote", true);
            videoTracks.pushMap(trackInfo);
        }
        for (int i = 0; i < mediaStream.audioTracks.size(); i++) {
            AudioTrack track = mediaStream.audioTracks.get(i);
            String trackId = track.id();

            remoteTracks.put(trackId, track);

            ConstraintsMap trackInfo = new ConstraintsMap();
            trackInfo.putString("id", trackId);
            trackInfo.putString("label", "Audio");
            trackInfo.putString("kind", track.kind());
            trackInfo.putBoolean("enabled", track.enabled());
            trackInfo.putString("readyState", track.state().toString());
            trackInfo.putBoolean("remote", true);
            audioTracks.pushMap(trackInfo);
        }
        params.putArray("audioTracks", audioTracks.toArrayList());
        params.putArray("videoTracks", videoTracks.toArrayList());

        sendEvent(params);
    }


    void sendEvent(ConstraintsMap event) {
        if(eventSink != null )
            eventSink.success(event.toMap());
    }

    @Override
    public void onRemoveStream(MediaStream mediaStream) {

        String streamId = mediaStream.getId();

        for (VideoTrack track : mediaStream.videoTracks) {
            this.remoteTracks.remove(track.id());
        }
        for (AudioTrack track : mediaStream.audioTracks) {
            this.remoteTracks.remove(track.id());
        }

        this.remoteStreams.remove(streamId);
        ConstraintsMap params = new ConstraintsMap();
        params.putString("event", "onRemoveStream");
        params.putString("streamId", streamId);
        sendEvent(params);
    }

    @Override
    public void onAddTrack(RtpReceiver receiver, MediaStream[] mediaStreams){
        Log.d(TAG, "onAddTrack");
        for (MediaStream stream : mediaStreams) {
            String streamId = stream.getId();
            MediaStreamTrack track = receiver.track();
            ConstraintsMap params = new ConstraintsMap();
            params.putString("event", "onAddTrack");
            params.putString("streamId", streamId);
            params.putString("trackId", track.id());

            String trackId = track.id();
            ConstraintsMap trackInfo = new ConstraintsMap();
            trackInfo.putString("id", trackId);
            trackInfo.putString("label", track.kind());
            trackInfo.putString("kind", track.kind());
            trackInfo.putBoolean("enabled", track.enabled());
            trackInfo.putString("readyState", track.state().toString());
            trackInfo.putBoolean("remote", true);
            params.putMap("track", trackInfo.toMap());
            sendEvent(params);
        }
    }
    @Override
    public void onDataChannel(DataChannel dataChannel) {
        // XXX Unfortunately, the Java WebRTC API doesn't expose the id
        // of the underlying C++/native DataChannel (even though the
        // WebRTC standard defines the DataChannel.id property). As a
        // workaround, generated an id which will surely not clash with
        // the ids of the remotely-opened (and standard-compliant
        // locally-opened) DataChannels.
        int dataChannelId = -1;
        // The RTCDataChannel.id space is limited to unsigned short by
        // the standard:
        // https://www.w3.org/TR/webrtc/#dom-datachannel-id.
        // Additionally, 65535 is reserved due to SCTP INIT and
        // INIT-ACK chunks only allowing a maximum of 65535 streams to
        // be negotiated (as defined by the WebRTC Data Channel
        // Establishment Protocol).
        for (int i = 65536; i <= Integer.MAX_VALUE; ++i) {
            if (null == dataChannels.get(i, null)) {
                dataChannelId = i;
                break;
            }
        }
        if (-1 == dataChannelId) {
          return;
        }
        ConstraintsMap params = new ConstraintsMap();
        params.putString("event", "didOpenDataChannel");
        params.putInt("id", dataChannelId);
        params.putString("label", dataChannel.label());

        dataChannels.put(dataChannelId, dataChannel);
        registerDataChannelObserver(dataChannelId, dataChannel);

        sendEvent(params);
    }

    private void registerDataChannelObserver(int dcId, DataChannel dataChannel) {
        // DataChannel.registerObserver implementation does not allow to
        // unregister, so the observer is registered here and is never
        // unregistered
        dataChannel.registerObserver(
            new DataChannelObserver(plugin, id, dcId, dataChannel));
    }

    @Override
    public void onRenegotiationNeeded() {
        ConstraintsMap params = new ConstraintsMap();
        params.putString("event", "onRenegotiationNeeded");
        sendEvent(params);
    }

    @Override
    public void onSignalingChange(PeerConnection.SignalingState signalingState) {
        ConstraintsMap params = new ConstraintsMap();
        params.putString("event", "signalingState");
        params.putString("state", signalingStateString(signalingState));
        sendEvent(params);
    }

    @Nullable
    private String iceConnectionStateString(PeerConnection.IceConnectionState iceConnectionState) {
        switch (iceConnectionState) {
            case NEW:
                return "new";
            case CHECKING:
                return "checking";
            case CONNECTED:
                return "connected";
            case COMPLETED:
                return "completed";
            case FAILED:
                return "failed";
            case DISCONNECTED:
                return "disconnected";
            case CLOSED:
                return "closed";
        }
        return null;
    }

    @Nullable
    private String iceGatheringStateString(PeerConnection.IceGatheringState iceGatheringState) {
        switch (iceGatheringState) {
            case NEW:
                return "new";
            case GATHERING:
                return "gathering";
            case COMPLETE:
                return "complete";
        }
        return null;
    }

    @Nullable
    private String signalingStateString(PeerConnection.SignalingState signalingState) {
        switch (signalingState) {
            case STABLE:
                return "stable";
            case HAVE_LOCAL_OFFER:
                return "have-local-offer";
            case HAVE_LOCAL_PRANSWER:
                return "have-local-pranswer";
            case HAVE_REMOTE_OFFER:
                return "have-remote-offer";
            case HAVE_REMOTE_PRANSWER:
                return "have-remote-pranswer";
            case CLOSED:
                return "closed";
        }
        return null;
    }
}
