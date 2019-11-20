package com.cloudwebrtc.webrtc;

import java.io.UnsupportedEncodingException;
import java.nio.ByteBuffer;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
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
import org.webrtc.DtmfSender;
import org.webrtc.IceCandidate;
import org.webrtc.MediaStream;
import org.webrtc.MediaStreamTrack;
import org.webrtc.PeerConnection;
import org.webrtc.RtpParameters;
import org.webrtc.RtpReceiver;
import org.webrtc.RtpSender;
import org.webrtc.RtpTransceiver;
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
    final Map<String, RtpTransceiver> transceivers;
    final Map<String, RtpSender> senders;
    final Map<String, RtpReceiver> receivers;
    private final FlutterWebRTCPlugin plugin;

    EventChannel eventChannel;
    EventChannel.EventSink eventSink;

    PeerConnectionObserver(FlutterWebRTCPlugin plugin, String id) {
        this.plugin = plugin;
        this.id = id;
        this.remoteStreams = new HashMap<String, MediaStream>();
        this.remoteTracks = new HashMap<String, MediaStreamTrack>();
        this.transceivers = new HashMap<String, RtpTransceiver>();
        this.senders = new HashMap<String, RtpSender>();
        this.receivers = new HashMap<String, RtpReceiver>();

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
        transceivers.clear();
        senders.clear();;
        receivers.clear();;
    }
    void  dispose(){
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
        Log.d(TAG, "onIceCandidate => " + candidate.toString());
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

    @Nullable
    private String transceiverDirectionString(RtpTransceiver.RtpTransceiverDirection direction) {
        switch (direction) {
            case SEND_RECV:
                return "sendrecv";
            case SEND_ONLY:
                return "sendonly";
            case RECV_ONLY:
                return "recvonly";
            case INACTIVE:
                return "inactive";
        }
        return null;
    }

    private RtpTransceiver.RtpTransceiverDirection typStringToTransceiverDirection(String direction) {
        switch (direction) {
            case "sendrecv":
                return RtpTransceiver.RtpTransceiverDirection.SEND_RECV;
            case "sendonly":
                return RtpTransceiver.RtpTransceiverDirection.SEND_ONLY;
            case "recvonly":
                return RtpTransceiver.RtpTransceiverDirection.RECV_ONLY;
            case "inactive":
                return RtpTransceiver.RtpTransceiverDirection.INACTIVE;
        }
        return RtpTransceiver.RtpTransceiverDirection.INACTIVE;
    }

    private Map<String, Object> rtpParametersToMap(RtpParameters rtpParameters){
        ConstraintsMap info = new ConstraintsMap();
        info.putString("transactionId", rtpParameters.transactionId);

        ConstraintsMap rtcp = new ConstraintsMap();
        rtcp.putString("cname", rtpParameters.getRtcp().getCname());
        rtcp.putBoolean("reducedSize",  rtpParameters.getRtcp().getReducedSize());
        info.putMap("rtcp", rtcp.toMap());

        ConstraintsArray headerExtensions = new ConstraintsArray();
        for(RtpParameters.HeaderExtension extension : rtpParameters.getHeaderExtensions()){
            ConstraintsMap map = new ConstraintsMap();
            map.putString("uri",extension.getUri());
            map.putInt("id", extension.getId());
            map.putBoolean("encrypted", extension.getEncrypted());
            headerExtensions.pushMap(map);
        }
        info.putArray("headerExtensions", headerExtensions.toArrayList());

        ConstraintsArray encodings = new ConstraintsArray();
        for(RtpParameters.Encoding encoding : rtpParameters.encodings){
            ConstraintsMap map = new ConstraintsMap();
            map.putBoolean("active",encoding.active);
            map.putInt("maxBitrateBps", encoding.maxBitrateBps);
            map.putInt("minBitrateBps", encoding.minBitrateBps);
            map.putInt("maxFramerate", encoding.maxFramerate);
            map.putInt("numTemporalLayers", encoding.numTemporalLayers);
            map.putDouble("scaleResolutionDownBy", encoding.scaleResolutionDownBy);
            map.putLong("ssrc", encoding.ssrc);
            encodings.pushMap(map);
        }
        info.putArray("encodings", encodings.toArrayList());

        ConstraintsArray codecs = new ConstraintsArray();
        for(RtpParameters.Codec codec : rtpParameters.codecs){
            ConstraintsMap map = new ConstraintsMap();
            map.putString("name",codec.name);
            map.putInt("payloadType", codec.payloadType);
            map.putInt("clockRate", codec.clockRate);
            map.putInt("numChannels", codec.numChannels);
            map.putMap("numTemporalLayers", new HashMap<String, Object>(codec.parameters));
            //map.putString("kind", codec.kind);
            codecs.pushMap(map);
        }

        info.putArray("codecs", codecs.toArrayList());
        return info.toMap();
    }

    @Nullable
    private Map<String, Object> mediaTrackToMap(MediaStreamTrack track){
        ConstraintsMap info = new ConstraintsMap();
        if(track != null){
            info.putString("trackId", track.id());
            info.putString("label",track.id());
            info.putString("kind",track.kind());
            info.putBoolean("enabled", track.enabled());
        }
        return info.toMap();
    }

    private Map<String, Object> dtmfSenderToMap(DtmfSender dtmfSender, String id){
        ConstraintsMap info = new ConstraintsMap();
        info.putString("dtmfSenderId",id);
        info.putInt("interToneGap", dtmfSender.interToneGap());
        info.putInt("duration",dtmfSender.duration());
        return info.toMap();
    }

    private Map<String, Object> rtpSenderToMap(RtpSender sender){
        ConstraintsMap info = new ConstraintsMap();
        info.putString("senderId", sender.id());
        info.putBoolean("ownsTrack", true);
        info.putMap("dtmfSender", dtmfSenderToMap(sender.dtmf(), sender.id()));
        info.putMap("rtpParameters", rtpParametersToMap(sender.getParameters()));
        info.putMap("track", mediaTrackToMap(sender.track()));
        return info.toMap();
    }

    private Map<String, Object> rtpReceiverToMap(RtpReceiver receiver){
        ConstraintsMap info = new ConstraintsMap();
        info.putString("receiverId", receiver.id());
        info.putMap("track", mediaTrackToMap(receiver.track()));
        return info.toMap();
    }

    Map<String, Object> transceiverToMap(RtpTransceiver transceiver){
        ConstraintsMap info = new ConstraintsMap();
        info.putString("transceiverId", transceiver.getMid());
        info.putString("mid", transceiver.getMid());
        info.putString("direction", transceiverDirectionString(transceiver.getDirection()));
        info.putMap("sender", rtpSenderToMap(transceiver.getSender()));
        info.putMap("receiver", rtpReceiverToMap(transceiver.getReceiver()));
        return info.toMap();
    }

    @Override
    public void onTrack(RtpTransceiver transceiver) {
        ConstraintsMap params = new ConstraintsMap();
        params.putString("event", "onTrack");
        params.putMap("transceiver", transceiverToMap(transceiver));
        sendEvent(params);
    }

    public void createSender(String kind, String streamId, Result result){
        RtpSender sender = peerConnection.createSender(kind, streamId);
        senders.put(sender.id(),sender);
        result.success(rtpSenderToMap(sender));
    }

    public void addTrack(MediaStreamTrack track, List<String> streamIds, Result result){
        RtpSender sender = peerConnection.addTrack(track, streamIds);
        senders.put(sender.id(),sender);
        result.success(rtpSenderToMap(sender));
    }

    public void removeTrack(String senderId, Result result){
        RtpSender sender = senders.get(senderId);
        if(sender == null){
            result.error("removeTrack", "removeTrack() sender is null", null);
            return;
        }
        boolean res = peerConnection.removeTrack(sender);
        ConstraintsMap params = new ConstraintsMap();
        params.putBoolean("result", res);
        result.success(params);
    }

    public void addTransceiver(MediaStreamTrack track, Map<String, Object> transceiverInit,  Result result) {
        RtpTransceiver  transceiver;
        if(transceiverInit != null){
            List<String> streamIds =  (List)transceiverInit.get("streamIds");
            String direction = (String)transceiverInit.get("direction");
            RtpTransceiver.RtpTransceiverInit init = new RtpTransceiver.RtpTransceiverInit(typStringToTransceiverDirection(direction) ,streamIds);
            transceiver = peerConnection.addTransceiver(track, init);
        } else {
            transceiver = peerConnection.addTransceiver(track);
        }
        transceivers.put(transceiver.getMid(), transceiver);
        result.success(transceiverToMap(transceiver));
    }

    public void addTransceiverOfType(String mediaType, Map<String, Object> transceiverInit,  Result result) {
        MediaStreamTrack.MediaType type = MediaStreamTrack.MediaType.MEDIA_TYPE_AUDIO;
        if(mediaType == "audio")
            type = MediaStreamTrack.MediaType.MEDIA_TYPE_AUDIO;
        else if(mediaType == "video")
            type = MediaStreamTrack.MediaType.MEDIA_TYPE_VIDEO;
        RtpTransceiver  transceiver;
        if(transceiverInit != null){
            List<String> streamIds =  (List)transceiverInit.get("streamIds");
            String direction = (String)transceiverInit.get("direction");
            RtpTransceiver.RtpTransceiverInit init = new RtpTransceiver.RtpTransceiverInit(typStringToTransceiverDirection(direction) ,streamIds);
            transceiver = peerConnection.addTransceiver(type, init);
        } else {
            transceiver = peerConnection.addTransceiver(type);
        }
        transceivers.put(transceiver.getMid(), transceiver);
        result.success(transceiverToMap(transceiver));
    }
}
