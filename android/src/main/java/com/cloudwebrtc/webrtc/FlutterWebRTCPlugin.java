package com.cloudwebrtc.webrtc;

import android.app.Activity;
import android.content.Context;
import android.hardware.Camera;
import android.graphics.SurfaceTexture;
import android.util.Log;
import android.util.LongSparseArray;

import com.cloudwebrtc.webrtc.record.FrameCapturer;
import com.cloudwebrtc.webrtc.utils.ConstraintsArray;
import com.cloudwebrtc.webrtc.utils.ConstraintsMap;
import com.cloudwebrtc.webrtc.utils.EglUtils;
import com.cloudwebrtc.webrtc.utils.ObjectType;

import java.io.File;
import java.util.*;

import org.webrtc.AudioTrack;
import org.webrtc.DefaultVideoDecoderFactory;
import org.webrtc.DefaultVideoEncoderFactory;
import org.webrtc.EglBase;
import org.webrtc.IceCandidate;
import org.webrtc.Logging;
import org.webrtc.MediaConstraints;
import org.webrtc.MediaStream;
import org.webrtc.MediaStreamTrack;
import org.webrtc.PeerConnection;
import org.webrtc.PeerConnectionFactory;
import org.webrtc.SdpObserver;
import org.webrtc.SessionDescription;
import org.webrtc.VideoTrack;
import org.webrtc.audio.AudioDeviceModule;
import org.webrtc.audio.JavaAudioDeviceModule;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.view.TextureRegistry;

/**
 * FlutterWebRTCPlugin
 */
public class FlutterWebRTCPlugin implements MethodCallHandler {

    static public final String TAG = "FlutterWebRTCPlugin";

    private final Registrar registrar;
    private final MethodChannel channel;

    public Map<String, MediaStream> localStreams;
    public Map<String, MediaStreamTrack> localTracks;
    private final Map<String, PeerConnectionObserver> mPeerConnectionObservers;

    private final TextureRegistry textures;
    private LongSparseArray<FlutterRTCVideoRenderer> renders = new LongSparseArray<>();

    /**
     * The implementation of {@code getUserMedia} extracted into a separate file
     * in order to reduce complexity and to (somewhat) separate concerns.
     */
    private GetUserMediaImpl getUserMediaImpl;
    final PeerConnectionFactory mFactory;


    public Activity getActivity() {
        return registrar.activity();
    }

    public Context getContext() {
        return registrar.context();
    }

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "cloudwebrtc.com/WebRTC.Method");
        channel.setMethodCallHandler(new FlutterWebRTCPlugin(registrar, channel));
    }

    public Registrar registrar() {
        return this.registrar;
    }

    private FlutterWebRTCPlugin(Registrar registrar, MethodChannel channel) {
        this.registrar = registrar;
        this.channel = channel;
        this.textures = registrar.textures();
        mPeerConnectionObservers = new HashMap<String, PeerConnectionObserver>();
        localStreams = new HashMap<String, MediaStream>();
        localTracks = new HashMap<String, MediaStreamTrack>();

        PeerConnectionFactory.initialize(
                PeerConnectionFactory.InitializationOptions.builder(registrar.context())
                        .setEnableInternalTracer(true)
                        .createInitializationOptions());

        // Initialize EGL contexts required for HW acceleration.
        EglBase.Context eglContext = EglUtils.getRootEglBaseContext();

        getUserMediaImpl = new GetUserMediaImpl(this, registrar.context());

        final AudioDeviceModule audioDeviceModule = JavaAudioDeviceModule.builder(registrar.context())
                .setUseHardwareAcousticEchoCanceler(true)
                .setUseHardwareNoiseSuppressor(true)
                .setSamplesReadyCallback(getUserMediaImpl.audioSamplesInterceptor)
                .createAudioDeviceModule();


        mFactory = PeerConnectionFactory.builder()
                .setOptions(new PeerConnectionFactory.Options())
                .setVideoEncoderFactory(new DefaultVideoEncoderFactory(eglContext, true, true))
                .setVideoDecoderFactory(new DefaultVideoDecoderFactory(eglContext))
                .setAudioDeviceModule(audioDeviceModule)
                .createPeerConnectionFactory();
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.equals("createPeerConnection")) {
            Map<String, Object> constraints = call.argument("constraints");
            Map<String, Object> configuration = call.argument("configuration");
            String peerConnectionId = peerConnectionInit(new ConstraintsMap(configuration), new ConstraintsMap((constraints)));
            ConstraintsMap res = new ConstraintsMap();
            res.putString("peerConnectionId", peerConnectionId);
            result.success(res.toMap());
        } else if (call.method.equals("getUserMedia")) {
            Map<String, Object> constraints = call.argument("constraints");
            ConstraintsMap constraintsMap = new ConstraintsMap(constraints);
            getUserMedia(constraintsMap, result);
        }else if (call.method.equals("getSources")) {
            getSources(result);
        }else if (call.method.equals("createOffer")) {
            String peerConnectionId = call.argument("peerConnectionId");
            Map<String, Object> constraints = call.argument("constraints");
            peerConnectionCreateOffer(peerConnectionId, new ConstraintsMap(constraints), result);
        } else if (call.method.equals("createAnswer")) {
            String peerConnectionId = call.argument("peerConnectionId");
            Map<String, Object> constraints = call.argument("constraints");
            peerConnectionCreateAnswer(peerConnectionId, new ConstraintsMap(constraints), result);
        } else if (call.method.equals("mediaStreamGetTracks")) {
            String streamId = call.argument("streamId");
            MediaStream stream = getStreamForId(streamId);
            Map<String, Object> resultMap = new HashMap<>();
            List<Object> audioTracks = new ArrayList<>();
            List<Object> videoTracks = new ArrayList<>();
            for (AudioTrack track : stream.audioTracks) {
                localTracks.put(track.id(), track);
                Map<String, Object> trackMap = new HashMap<>();
                trackMap.put("enabled", track.enabled());
                trackMap.put("id", track.id());
                trackMap.put("kind", track.kind());
                trackMap.put("label", track.id());
                trackMap.put("readyState", "live");
                trackMap.put("remote", false);
                audioTracks.add(trackMap);
            }
            for (VideoTrack track : stream.videoTracks) {
                localTracks.put(track.id(), track);
                Map<String, Object> trackMap = new HashMap<>();
                trackMap.put("enabled", track.enabled());
                trackMap.put("id", track.id());
                trackMap.put("kind", track.kind());
                trackMap.put("label", track.id());
                trackMap.put("readyState", "live");
                trackMap.put("remote", false);
                videoTracks.add(trackMap);
            }
            resultMap.put("audioTracks", audioTracks);
            resultMap.put("videoTracks", videoTracks);
            result.success(resultMap);
        } else if (call.method.equals("addStream")) {
            String streamId = call.argument("streamId");
            String peerConnectionId = call.argument("peerConnectionId");
            peerConnectionAddStream(streamId, peerConnectionId, result);
        } else if (call.method.equals("removeStream")) {
            String streamId = call.argument("streamId");
            String peerConnectionId = call.argument("peerConnectionId");
            peerConnectionRemoveStream(streamId, peerConnectionId, result);
        } else if (call.method.equals("setLocalDescription")) {
            String peerConnectionId = call.argument("peerConnectionId");
            Map<String, Object> description = call.argument("description");
            peerConnectionSetLocalDescription(new ConstraintsMap(description), peerConnectionId, result);
        } else if (call.method.equals("setRemoteDescription")) {
            String peerConnectionId = call.argument("peerConnectionId");
            Map<String, Object> description = call.argument("description");
            peerConnectionSetRemoteDescription(new ConstraintsMap(description), peerConnectionId, result);
        } else if (call.method.equals("addCandidate")) {
            String peerConnectionId = call.argument("peerConnectionId");
            Map<String, Object> candidate = call.argument("candidate");
            peerConnectionAddICECandidate(new ConstraintsMap(candidate), peerConnectionId, result);
        } else if (call.method.equals("getStats")) {
            String peerConnectionId = call.argument("peerConnectionId");
            String trackId = call.argument("trackId");
            peerConnectionGetStats(trackId, peerConnectionId, result);
        } else if (call.method.equals("createDataChannel")) {
            String peerConnectionId = call.argument("peerConnectionId");
            String label = call.argument("label");
            Map<String, Object> dataChannelDict = call.argument("dataChannelDict");
            createDataChannel(peerConnectionId, label, new ConstraintsMap(dataChannelDict), result);
        } else if (call.method.equals("dataChannelSend")) {
            String peerConnectionId = call.argument("peerConnectionId");
            int dataChannelId = call.argument("dataChannelId");
            String data = call.argument("data");
            String type = call.argument("type");
            dataChannelSend(peerConnectionId, dataChannelId, data, type);
        } else if (call.method.equals("dataChannelClose")) {
            String peerConnectionId = call.argument("peerConnectionId");
            int dataChannelId = call.argument("dataChannelId");
            dataChannelClose(peerConnectionId, dataChannelId);
        } else if (call.method.equals("streamDispose")) {
            String streamId = call.argument("streamId");
            mediaStreamRelease(streamId);
            result.success(null);
        }else if (call.method.equals("mediaStreamTrackSetEnable")) {
            String trackId = call.argument("trackId");
            Boolean enabled = call.argument("enabled");
            MediaStreamTrack track = getTrackForId(trackId);
            if(track != null){
                track.setEnabled(enabled);
            }
            result.success(null);
        }else if (call.method.equals("trackDispose")) {
            String trackId = call.argument("trackId");
            localTracks.remove(trackId);
            result.success(null);
        } else if (call.method.equals("peerConnectionClose")) {
            String peerConnectionId = call.argument("peerConnectionId");
            peerConnectionClose(peerConnectionId);
            result.success(null);
        } else if (call.method.equals("createVideoRenderer")) {
            TextureRegistry.SurfaceTextureEntry entry = textures.createSurfaceTexture();
            SurfaceTexture surfaceTexture = entry.surfaceTexture();
            FlutterRTCVideoRenderer render = new FlutterRTCVideoRenderer(surfaceTexture);
            renders.put(entry.id(), render);

            EventChannel eventChannel =
                    new EventChannel(
                            registrar.messenger(),
                            "cloudwebrtc.com/WebRTC/Texture" + entry.id());

            eventChannel.setStreamHandler(render);
            render.setEventChannel(eventChannel);
            render.setId((int)entry.id());

            ConstraintsMap params = new ConstraintsMap();
            params.putInt("textureId", (int)entry.id());
            result.success(params.toMap());
        } else if (call.method.equals("videoRendererDispose")) {
            int textureId = call.argument("textureId");
            FlutterRTCVideoRenderer render = renders.get(textureId);
            render.Dispose();
            renders.delete(textureId);
        } else if (call.method.equals("videoRendererSetSrcObject")) {
            int textureId = call.argument("textureId");
            String streamId = call.argument("streamId");

            FlutterRTCVideoRenderer render = renders.get(textureId);

            if(render == null ){
                result.error("FlutterRTCVideoRendererNotFound", "render [" + textureId + "] not found !", null);
                return;
            }

            MediaStream stream = getStreamForId(streamId);
            render.setStream(stream);
            result.success(null);
        } else if (call.method.equals("mediaStreamTrackSwitchCamera")) {
            String trackId = call.argument("trackId");
            mediaStreamTrackSwitchCamera(trackId, result);
        } else if (call.method.equals("setVolume")) {
            String trackId = call.argument("trackId");
            double volume = call.argument("volume");
            mediaStreamTrackSetVolume(trackId, volume);
            result.success(null);
        } else if(call.method.equals("getDisplayMedia")) {
            Map<String, Object> constraints = call.argument("constraints");
            ConstraintsMap constraintsMap = new ConstraintsMap(constraints);
            getDisplayMedia(constraintsMap, result);
        }else if (call.method.equals("startRecordToFile")) {
            //This method can a lot of different exceptions
            //so we should notify plugin user about them
            try {
                String path = call.argument("path");
                VideoTrack videoTrack = null;
                String videoTrackId = call.argument("videoTrackId");
                if (videoTrackId != null) {
                    MediaStreamTrack track = localTracks.get(videoTrackId);
                    if (track instanceof VideoTrack)
                        videoTrack = (VideoTrack) track;
                }
                AudioTrack audioTrack = null;
                String audioTrackId = call.argument("audioTrackId");
                Integer recorderId = call.argument("recorderId");
                if (audioTrackId != null) {
                    MediaStreamTrack track = localTracks.get(audioTrackId);
                    if (track instanceof AudioTrack)
                        audioTrack = (AudioTrack) track;
                }
                if (videoTrack != null || audioTrack != null) {
                    getUserMediaImpl.startRecordingToFile(path, recorderId, videoTrack, audioTrack);
                    result.success(null);
                } else {
                    result.error("0", "No track", null);
                }
            } catch (Exception e) {
                result.error("-1", e.getMessage(), e);
            }
        } else if (call.method.equals("stopRecordToFile")) {
            Integer recorderId = call.argument("recorderId");
            getUserMediaImpl.stopRecording(recorderId);
            result.success(null);
        } else if (call.method.equals("captureFrame")) {
            String path = call.argument("path");
            String videoTrackId = call.argument("trackId");
            if (videoTrackId != null) {
                MediaStreamTrack track = localTracks.get(videoTrackId);
                if (track instanceof VideoTrack)
                    new FrameCapturer((VideoTrack) track, new File(path), result);
                else
                    result.error("It's not video track", null, null);
            } else {
                result.error("Track is null", null, null);
            }
        } else {
            result.notImplemented();
        }
    }

    private PeerConnection getPeerConnection(String id) {
        PeerConnectionObserver pco = mPeerConnectionObservers.get(id);
        return (pco == null) ? null : pco.getPeerConnection();
    }

    private List<PeerConnection.IceServer> createIceServers(ConstraintsArray iceServersArray) {
        final int size = (iceServersArray == null) ? 0 : iceServersArray.size();
        List<PeerConnection.IceServer> iceServers = new ArrayList<>(size);
        for (int i = 0; i < size; i++) {
            ConstraintsMap iceServerMap = iceServersArray.getMap(i);
            boolean hasUsernameAndCredential = iceServerMap.hasKey("username") && iceServerMap.hasKey("credential");
            if (iceServerMap.hasKey("url")) {
                if (hasUsernameAndCredential) {
                    iceServers.add(new PeerConnection.IceServer(iceServerMap.getString("url"), iceServerMap.getString("username"), iceServerMap.getString("credential")));
                } else {
                    iceServers.add(new PeerConnection.IceServer(iceServerMap.getString("url")));
                }
            } else if (iceServerMap.hasKey("urls")) {
                switch (iceServerMap.getType("urls")) {
                    case String:
                        if (hasUsernameAndCredential) {
                            iceServers.add(new PeerConnection.IceServer(iceServerMap.getString("urls"), iceServerMap.getString("username"), iceServerMap.getString("credential")));
                        } else {
                            iceServers.add(new PeerConnection.IceServer(iceServerMap.getString("urls")));
                        }
                        break;
                    case Array:
                        ConstraintsArray urls = iceServerMap.getArray("urls");
                        for (int j = 0; j < urls.size(); j++) {
                            String url = urls.getString(j);
                            if (hasUsernameAndCredential) {
                                iceServers.add(new PeerConnection.IceServer(url, iceServerMap.getString("username"), iceServerMap.getString("credential")));
                            } else {
                                iceServers.add(new PeerConnection.IceServer(url));
                            }
                        }
                        break;
                }
            }
        }
        return iceServers;
    }

    private PeerConnection.RTCConfiguration parseRTCConfiguration(ConstraintsMap map) {
        ConstraintsArray iceServersArray = null;
        if (map != null) {
            iceServersArray = map.getArray("iceServers");
        }
        List<PeerConnection.IceServer> iceServers = createIceServers(iceServersArray);
        PeerConnection.RTCConfiguration conf = new PeerConnection.RTCConfiguration(iceServers);
        if (map == null) {
            return conf;
        }

        // iceTransportPolicy (public api)
        if (map.hasKey("iceTransportPolicy")
                && map.getType("iceTransportPolicy") == ObjectType.String) {
            final String v = map.getString("iceTransportPolicy");
            if (v != null) {
                switch (v) {
                    case "all": // public
                        conf.iceTransportsType = PeerConnection.IceTransportsType.ALL;
                        break;
                    case "relay": // public
                        conf.iceTransportsType = PeerConnection.IceTransportsType.RELAY;
                        break;
                    case "nohost":
                        conf.iceTransportsType = PeerConnection.IceTransportsType.NOHOST;
                        break;
                    case "none":
                        conf.iceTransportsType = PeerConnection.IceTransportsType.NONE;
                        break;
                }
            }
        }

        // bundlePolicy (public api)
        if (map.hasKey("bundlePolicy")
                && map.getType("bundlePolicy") == ObjectType.String) {
            final String v = map.getString("bundlePolicy");
            if (v != null) {
                switch (v) {
                    case "balanced": // public
                        conf.bundlePolicy = PeerConnection.BundlePolicy.BALANCED;
                        break;
                    case "max-compat": // public
                        conf.bundlePolicy = PeerConnection.BundlePolicy.MAXCOMPAT;
                        break;
                    case "max-bundle": // public
                        conf.bundlePolicy = PeerConnection.BundlePolicy.MAXBUNDLE;
                        break;
                }
            }
        }

        // rtcpMuxPolicy (public api)
        if (map.hasKey("rtcpMuxPolicy")
                && map.getType("rtcpMuxPolicy") == ObjectType.String) {
            final String v = map.getString("rtcpMuxPolicy");
            if (v != null) {
                switch (v) {
                    case "negotiate": // public
                        conf.rtcpMuxPolicy = PeerConnection.RtcpMuxPolicy.NEGOTIATE;
                        break;
                    case "require": // public
                        conf.rtcpMuxPolicy = PeerConnection.RtcpMuxPolicy.REQUIRE;
                        break;
                }
            }
        }

        // FIXME: peerIdentity of type DOMString (public api)
        // FIXME: certificates of type sequence<RTCCertificate> (public api)

        // iceCandidatePoolSize of type unsigned short, defaulting to 0
        if (map.hasKey("iceCandidatePoolSize")
                && map.getType("iceCandidatePoolSize") == ObjectType.Number) {
            final int v = map.getInt("iceCandidatePoolSize");
            if (v > 0) {
                conf.iceCandidatePoolSize = v;
            }
        }

        // === below is private api in webrtc ===

        // tcpCandidatePolicy (private api)
        if (map.hasKey("tcpCandidatePolicy")
                && map.getType("tcpCandidatePolicy") == ObjectType.String) {
            final String v = map.getString("tcpCandidatePolicy");
            if (v != null) {
                switch (v) {
                    case "enabled":
                        conf.tcpCandidatePolicy = PeerConnection.TcpCandidatePolicy.ENABLED;
                        break;
                    case "disabled":
                        conf.tcpCandidatePolicy = PeerConnection.TcpCandidatePolicy.DISABLED;
                        break;
                }
            }
        }

        // candidateNetworkPolicy (private api)
        if (map.hasKey("candidateNetworkPolicy")
                && map.getType("candidateNetworkPolicy") == ObjectType.String) {
            final String v = map.getString("candidateNetworkPolicy");
            if (v != null) {
                switch (v) {
                    case "all":
                        conf.candidateNetworkPolicy = PeerConnection.CandidateNetworkPolicy.ALL;
                        break;
                    case "low_cost":
                        conf.candidateNetworkPolicy = PeerConnection.CandidateNetworkPolicy.LOW_COST;
                        break;
                }
            }
        }

        // KeyType (private api)
        if (map.hasKey("keyType")
                && map.getType("keyType") == ObjectType.String) {
            final String v = map.getString("keyType");
            if (v != null) {
                switch (v) {
                    case "RSA":
                        conf.keyType = PeerConnection.KeyType.RSA;
                        break;
                    case "ECDSA":
                        conf.keyType = PeerConnection.KeyType.ECDSA;
                        break;
                }
            }
        }

        // continualGatheringPolicy (private api)
        if (map.hasKey("continualGatheringPolicy")
                && map.getType("continualGatheringPolicy") == ObjectType.String) {
            final String v = map.getString("continualGatheringPolicy");
            if (v != null) {
                switch (v) {
                    case "gather_once":
                        conf.continualGatheringPolicy = PeerConnection.ContinualGatheringPolicy.GATHER_ONCE;
                        break;
                    case "gather_continually":
                        conf.continualGatheringPolicy = PeerConnection.ContinualGatheringPolicy.GATHER_CONTINUALLY;
                        break;
                }
            }
        }

        // audioJitterBufferMaxPackets (private api)
        if (map.hasKey("audioJitterBufferMaxPackets")
                && map.getType("audioJitterBufferMaxPackets") == ObjectType.Number) {
            final int v = map.getInt("audioJitterBufferMaxPackets");
            if (v > 0) {
                conf.audioJitterBufferMaxPackets = v;
            }
        }

        // iceConnectionReceivingTimeout (private api)
        if (map.hasKey("iceConnectionReceivingTimeout")
                && map.getType("iceConnectionReceivingTimeout") == ObjectType.Number) {
            final int v = map.getInt("iceConnectionReceivingTimeout");
            conf.iceConnectionReceivingTimeout = v;
        }

        // iceBackupCandidatePairPingInterval (private api)
        if (map.hasKey("iceBackupCandidatePairPingInterval")
                && map.getType("iceBackupCandidatePairPingInterval") == ObjectType.Number) {
            final int v = map.getInt("iceBackupCandidatePairPingInterval");
            conf.iceBackupCandidatePairPingInterval = v;
        }

        // audioJitterBufferFastAccelerate (private api)
        if (map.hasKey("audioJitterBufferFastAccelerate")
                && map.getType("audioJitterBufferFastAccelerate") == ObjectType.Boolean) {
            final boolean v = map.getBoolean("audioJitterBufferFastAccelerate");
            conf.audioJitterBufferFastAccelerate = v;
        }

        // pruneTurnPorts (private api)
        if (map.hasKey("pruneTurnPorts")
                && map.getType("pruneTurnPorts") == ObjectType.Boolean) {
            final boolean v = map.getBoolean("pruneTurnPorts");
            conf.pruneTurnPorts = v;
        }

        // presumeWritableWhenFullyRelayed (private api)
        if (map.hasKey("presumeWritableWhenFullyRelayed")
                && map.getType("presumeWritableWhenFullyRelayed") == ObjectType.Boolean) {
            final boolean v = map.getBoolean("presumeWritableWhenFullyRelayed");
            conf.presumeWritableWhenFullyRelayed = v;
        }

        return conf;
    }

    public String peerConnectionInit(
            ConstraintsMap configuration,
            ConstraintsMap constraints) {

        String peerConnectionId = getNextStreamUUID();
        PeerConnectionObserver observer = new PeerConnectionObserver(this, peerConnectionId);
        PeerConnection peerConnection
                = mFactory.createPeerConnection(
                parseRTCConfiguration(configuration),
                parseMediaConstraints(constraints),
                observer);
        observer.setPeerConnection(peerConnection);
        mPeerConnectionObservers.put(peerConnectionId, observer);
        return peerConnectionId;
    }

    String getNextStreamUUID() {
        String uuid;

        do {
            uuid = UUID.randomUUID().toString();
        } while (getStreamForId(uuid) != null);

        return uuid;
    }

    String getNextTrackUUID() {
        String uuid;

        do {
            uuid = UUID.randomUUID().toString();
        } while (getTrackForId(uuid) != null);

        return uuid;
    }

    MediaStream getStreamForId(String id) {
        MediaStream stream = localStreams.get(id);

        if (stream == null) {
            for (Map.Entry<String, PeerConnectionObserver> entry : mPeerConnectionObservers.entrySet()) {
                PeerConnectionObserver pco = entry.getValue();
                stream = pco.remoteStreams.get(id);
                if (stream != null) {
                    break;
                }
            }
        }

        return stream;
    }

    private MediaStreamTrack getTrackForId(String trackId) {
        MediaStreamTrack track = localTracks.get(trackId);

        if (track == null) {
            for (Map.Entry<String, PeerConnectionObserver> entry : mPeerConnectionObservers.entrySet()) {
                PeerConnectionObserver pco = entry.getValue();
                track = pco.remoteTracks.get(trackId);
                if (track != null) {
                    break;
                }
            }
        }

        return track;
    }

    /**
     * Parses a constraint set specified in the form of a JavaScript object into
     * a specific <tt>List</tt> of <tt>MediaConstraints.KeyValuePair</tt>s.
     *
     * @param src The constraint set in the form of a JavaScript object to
     *            parse.
     * @param dst The <tt>List</tt> of <tt>MediaConstraints.KeyValuePair</tt>s
     *            into which the specified <tt>src</tt> is to be parsed.
     */
    private void parseConstraints(
            ConstraintsMap src,
            List<MediaConstraints.KeyValuePair> dst) {

        for (Map.Entry<String, Object> entry : src.toMap().entrySet()) {
            String key = entry.getKey();
            String value = getMapStrValue(src, entry.getKey());
            dst.add(new MediaConstraints.KeyValuePair(key, value));
        }
    }

    private String getMapStrValue(ConstraintsMap map, String key) {
        if(!map.hasKey(key)){
            return null;
        }
        ObjectType type = map.getType(key);
        switch (type) {
            case Boolean:
                return String.valueOf(map.getBoolean(key));
            case Number:
                // Don't know how to distinguish between Int and Double from
                // ReadableType.Number. 'getInt' will fail on double value,
                // while 'getDouble' works for both.
                // return String.valueOf(map.getInt(key));
                return String.valueOf(map.getDouble(key));
            case String:
                return map.getString(key);
            default:
                return null;
        }
    }

    /**
     * Parses mandatory and optional "GUM" constraints described by a specific
     * <tt>ConstraintsMap</tt>.
     *
     * @param constraints A <tt>ConstraintsMap</tt> which represents a JavaScript
     *                    object specifying the constraints to be parsed into a
     *                    <tt>MediaConstraints</tt> instance.
     * @return A new <tt>MediaConstraints</tt> instance initialized with the
     * mandatory and optional constraint keys and values specified by
     * <tt>constraints</tt>.
     */
    MediaConstraints parseMediaConstraints(ConstraintsMap constraints) {
        MediaConstraints mediaConstraints = new MediaConstraints();

        if (constraints.hasKey("mandatory")
                && constraints.getType("mandatory") == ObjectType.Map) {
            parseConstraints(constraints.getMap("mandatory"),
                    mediaConstraints.mandatory);
        } else {
            Log.d(TAG, "mandatory constraints are not a map");
        }

        if (constraints.hasKey("optional")
                && constraints.getType("optional") == ObjectType.Array) {
            ConstraintsArray optional = constraints.getArray("optional");

            for (int i = 0, size = optional.size(); i < size; i++) {
                if (optional.getType(i) == ObjectType.Map) {
                    parseConstraints(
                            optional.getMap(i),
                            mediaConstraints.optional);
                }
            }
        } else {
            Log.d(TAG, "optional constraints are not an array");
        }

        return mediaConstraints;
    }

    public void getUserMedia(ConstraintsMap constraints, Result result) {
        String streamId = getNextStreamUUID();
        MediaStream mediaStream = mFactory.createLocalMediaStream(streamId);

        if (mediaStream == null) {
            // XXX The following does not follow the getUserMedia() algorithm
            // specified by
            // https://www.w3.org/TR/mediacapture-streams/#dom-mediadevices-getusermedia
            // with respect to distinguishing the various causes of failure.
            result.error(
                    /* type */ "getUserMediaFailed",
                    "Failed to create new media stream", null);
            return;
        }

        getUserMediaImpl.getUserMedia(constraints, result, mediaStream);
    }

    public void getDisplayMedia(ConstraintsMap constraints, Result result) {
        String streamId = getNextStreamUUID();
        MediaStream mediaStream = mFactory.createLocalMediaStream(streamId);

        if (mediaStream == null) {
            // XXX The following does not follow the getUserMedia() algorithm
            // specified by
            // https://www.w3.org/TR/mediacapture-streams/#dom-mediadevices-getusermedia
            // with respect to distinguishing the various causes of failure.
            result.error(
                    /* type */ "getDisplayMedia",
                    "Failed to create new media stream", null);
            return;
        }

        getUserMediaImpl.getDisplayMedia(constraints, result, mediaStream);
    }

    public void getSources(Result result) {
        ConstraintsArray array = new ConstraintsArray();
        String[] names = new String[Camera.getNumberOfCameras()];

        for (int i = 0; i < Camera.getNumberOfCameras(); ++i) {
            ConstraintsMap info = getCameraInfo(i);
            if (info != null) {
                array.pushMap(info);
            }
        }

        ConstraintsMap audio = new ConstraintsMap();
        audio.putString("label", "Audio");
        audio.putString("deviceId", "audio-1");
        audio.putString("facing", "");
        audio.putString("kind", "audioinput");
        array.pushMap(audio);
        result.success(array);
    }

    public void mediaStreamTrackStop(final String id) {
        // Is this functionality equivalent to `mediaStreamTrackRelease()` ?
        // if so, we should merge this two and remove track from stream as well.
        MediaStreamTrack track = localTracks.get(id);
        if (track == null) {
            Log.d(TAG, "mediaStreamTrackStop() track is null");
            return;
        }
        track.setEnabled(false);
        if (track.kind().equals("video")) {
            getUserMediaImpl.removeVideoCapturer(id);
        }
        localTracks.remove(id);
        // What exactly does `detached` mean in doc?
        // see: https://www.w3.org/TR/mediacapture-streams/#track-detached
    }

    public void mediaStreamTrackSetEnabled(final String id, final boolean enabled) {
        MediaStreamTrack track = localTracks.get(id);
        if (track == null) {
            Log.d(TAG, "mediaStreamTrackSetEnabled() track is null");
            return;
        } else if (track.enabled() == enabled) {
            return;
        }
        track.setEnabled(enabled);
    }

    public void mediaStreamTrackSwitchCamera(final String id, Result result) {
        MediaStreamTrack track = localTracks.get(id);
        if (track != null) {
            getUserMediaImpl.switchCamera(id);
            result.success(null);
        }else{
            result.error("mediaStreamTrackSwitchCameraFailed", "mediaStreamTrackSwitchCamera() track is null", null);
        }
    }

    public void mediaStreamTrackSetVolume(final String id, final double volume) {
        MediaStreamTrack track = localTracks.get(id);
        if (track != null && track instanceof AudioTrack) {
            Log.d(TAG, "setVolume(): " + id + "," + volume);
            try {
                ((AudioTrack)track).setVolume(volume);
            } catch (Exception e) {
                Log.e(TAG, "setVolume(): error", e);
            }
        } else {
            Log.w(TAG, "setVolume(): track not found: " + id);
        }
    }

    public void mediaStreamTrackRelease(final String streamId, final String _trackId) {
        MediaStream stream = localStreams.get(streamId);
        if (stream == null) {
            Log.d(TAG, "mediaStreamTrackRelease() stream is null");
            return;
        }
        MediaStreamTrack track = localTracks.get(_trackId);
        if (track == null) {
            Log.d(TAG, "mediaStreamTrackRelease() track is null");
            return;
        }
        track.setEnabled(false); // should we do this?
        localTracks.remove(_trackId);
        if (track.kind().equals("audio")) {
            stream.removeTrack((AudioTrack) track);
        } else if (track.kind().equals("video")) {
            stream.removeTrack((VideoTrack) track);
            getUserMediaImpl.removeVideoCapturer(_trackId);
        }
    }

    public ConstraintsMap getCameraInfo(int index) {
        Camera.CameraInfo info = new Camera.CameraInfo();

        try {
            Camera.getCameraInfo(index, info);
        } catch (Exception e) {
            Logging.e("CameraEnumerationAndroid", "getCameraInfo failed on index " + index, e);
            return null;
        }
        ConstraintsMap params = new ConstraintsMap();
        String facing = info.facing == 1 ? "front" : "back";
        params.putString("label", "Camera " + index + ", Facing " + facing + ", Orientation " + info.orientation);
        params.putString("deviceId", "" + index);
        params.putString("facing", facing);
        params.putString("kind", "videoinput");
        return params;
    }

    private MediaConstraints defaultConstraints() {
        MediaConstraints constraints = new MediaConstraints();
        // TODO video media
        constraints.mandatory.add(new MediaConstraints.KeyValuePair("OfferToReceiveAudio", "true"));
        constraints.mandatory.add(new MediaConstraints.KeyValuePair("OfferToReceiveVideo", "true"));
        constraints.optional.add(new MediaConstraints.KeyValuePair("DtlsSrtpKeyAgreement", "true"));
        return constraints;
    }

    public void peerConnectionSetConfiguration(ConstraintsMap configuration, final String id) {
        PeerConnection peerConnection = getPeerConnection(id);
        if (peerConnection == null) {
            Log.d(TAG, "peerConnectionSetConfiguration() peerConnection is null");
            return;
        }
        peerConnection.setConfiguration(parseRTCConfiguration(configuration));
    }

    public void peerConnectionAddStream(final String streamId, final String id, Result result) {
        MediaStream mediaStream = localStreams.get(streamId);
        if (mediaStream == null) {
            Log.d(TAG, "peerConnectionAddStream() mediaStream is null");
            return;
        }
        PeerConnection peerConnection = getPeerConnection(id);
        if (peerConnection != null) {
            boolean res = peerConnection.addStream(mediaStream);
            Log.d(TAG, "addStream" + result);
            result.success(res);
        } else {
            Log.d(TAG, "peerConnectionAddStream() peerConnection is null");
            result.error("peerConnectionAddStreamFailed", "peerConnectionAddStream() peerConnection is null", null);
        }
    }

    public void peerConnectionRemoveStream(final String streamId, final String id, Result result) {
        MediaStream mediaStream = localStreams.get(streamId);
        if (mediaStream == null) {
            Log.d(TAG, "peerConnectionRemoveStream() mediaStream is null");
            return;
        }
        PeerConnection peerConnection = getPeerConnection(id);
        if (peerConnection != null) {
            peerConnection.removeStream(mediaStream);
            result.success(null);
        } else {
            Log.d(TAG, "peerConnectionRemoveStream() peerConnection is null");
            result.error("peerConnectionRemoveStreamFailed", "peerConnectionAddStream() peerConnection is null", null);
        }
    }

    public void peerConnectionCreateOffer(
            String id,
            ConstraintsMap constraints,
            final Result result) {
        PeerConnection peerConnection = getPeerConnection(id);

        if (peerConnection != null) {
            peerConnection.createOffer(new SdpObserver() {
                @Override
                public void onCreateFailure(String s) {
                    result.error("WEBRTC_CREATE_OFFER_ERROR", s, null);
                }

                @Override
                public void onCreateSuccess(final SessionDescription sdp) {
                    ConstraintsMap params = new ConstraintsMap();
                    params.putString("sdp", sdp.description);
                    params.putString("type", sdp.type.canonicalForm());
                    result.success(params.toMap());
                }

                @Override
                public void onSetFailure(String s) {
                }

                @Override
                public void onSetSuccess() {
                }
            }, parseMediaConstraints(constraints));
        } else {
            Log.d(TAG, "peerConnectionCreateOffer() peerConnection is null");
            result.error("WEBRTC_CREATE_OFFER_ERROR", "peerConnection is null", null);
        }
    }

    public void peerConnectionCreateAnswer(
            String id,
            ConstraintsMap constraints,
            final Result result) {
        PeerConnection peerConnection = getPeerConnection(id);

        if (peerConnection != null) {
            peerConnection.createAnswer(new SdpObserver() {
                @Override
                public void onCreateFailure(String s) {
                    result.error("WEBRTC_CREATE_ANSWER_ERROR", s, null);
                }

                @Override
                public void onCreateSuccess(final SessionDescription sdp) {
                    ConstraintsMap params = new ConstraintsMap();
                    params.putString("sdp", sdp.description);
                    params.putString("type", sdp.type.canonicalForm());
                    result.success(params.toMap());
                }

                @Override
                public void onSetFailure(String s) {
                }

                @Override
                public void onSetSuccess() {
                }
            }, parseMediaConstraints(constraints));
        } else {
            Log.d(TAG, "peerConnectionCreateAnswer() peerConnection is null");
            result.error("WEBRTC_CREATE_ANSWER_ERROR", "peerConnection is null", null);
        }
    }

    public void peerConnectionSetLocalDescription(ConstraintsMap sdpMap, final String id, final Result result) {
        PeerConnection peerConnection = getPeerConnection(id);

        Log.d(TAG, "peerConnectionSetLocalDescription() start");
        if (peerConnection != null) {
            SessionDescription sdp = new SessionDescription(
                    SessionDescription.Type.fromCanonicalForm(sdpMap.getString("type")),
                    sdpMap.getString("sdp")
            );

            peerConnection.setLocalDescription(new SdpObserver() {
                @Override
                public void onCreateSuccess(final SessionDescription sdp) {
                }

                @Override
                public void onSetSuccess() {
                    result.success(null);
                }

                @Override
                public void onCreateFailure(String s) {
                }

                @Override
                public void onSetFailure(String s) {
                    result.error("WEBRTC_SET_LOCAL_DESCRIPTION_ERROR", s, null);
                }
            }, sdp);
        } else {
            Log.d(TAG, "peerConnectionSetLocalDescription() peerConnection is null");
            result.error("WEBRTC_SET_LOCAL_DESCRIPTION_ERROR", "peerConnection is null", null);
        }
        Log.d(TAG, "peerConnectionSetLocalDescription() end");
    }

    public void peerConnectionSetRemoteDescription(final ConstraintsMap sdpMap, final String id, final Result result) {
        PeerConnection peerConnection = getPeerConnection(id);
        // final String d = sdpMap.getString("type");

        Log.d(TAG, "peerConnectionSetRemoteDescription() start");
        if (peerConnection != null) {
            SessionDescription sdp = new SessionDescription(
                    SessionDescription.Type.fromCanonicalForm(sdpMap.getString("type")),
                    sdpMap.getString("sdp")
            );

            peerConnection.setRemoteDescription(new SdpObserver() {
                @Override
                public void onCreateSuccess(final SessionDescription sdp) {
                }

                @Override
                public void onSetSuccess() {
                    result.success(null);
                }

                @Override
                public void onCreateFailure(String s) {
                }

                @Override
                public void onSetFailure(String s) {
                    result.error("WEBRTC_SET_REMOTE_DESCRIPTION_ERROR", s, null);
                }
            }, sdp);
        } else {
            Log.d(TAG, "peerConnectionSetRemoteDescription() peerConnection is null");
            result.error("WEBRTC_SET_REMOTE_DESCRIPTION_ERROR", "peerConnection is null", null);
        }
        Log.d(TAG, "peerConnectionSetRemoteDescription() end");
    }

    public void peerConnectionAddICECandidate(ConstraintsMap candidateMap, final String id, final Result result) {
        boolean res = false;
        PeerConnection peerConnection = getPeerConnection(id);
        Log.d(TAG, "peerConnectionAddICECandidate() start");
        if (peerConnection != null) {
            IceCandidate candidate = new IceCandidate(
                    candidateMap.getString("sdpMid"),
                    candidateMap.getInt("sdpMLineIndex"),
                    candidateMap.getString("candidate")
            );
            res = peerConnection.addIceCandidate(candidate);
        } else {
            Log.d(TAG, "peerConnectionAddICECandidate() peerConnection is null");
            result.error("peerConnectionAddICECandidateFailed", "peerConnectionAddICECandidate() peerConnection is null", null);
        }
        result.success(res);
        Log.d(TAG, "peerConnectionAddICECandidate() end");
    }

    public void peerConnectionGetStats(String trackId, String id, final Result result) {
        PeerConnectionObserver pco = mPeerConnectionObservers.get(id);
        if (pco == null || pco.getPeerConnection() == null) {
            Log.d(TAG, "peerConnectionGetStats() peerConnection is null");
        } else {
            pco.getStats(trackId, result);
        }
    }

    public void peerConnectionClose(final String id) {
        PeerConnectionObserver pco = mPeerConnectionObservers.get(id);
        if (pco == null || pco.getPeerConnection() == null) {
            Log.d(TAG, "peerConnectionClose() peerConnection is null");
        } else {
            pco.close();
            mPeerConnectionObservers.remove(id);
        }
    }

    public void mediaStreamRelease(final String id) {
        MediaStream mediaStream = localStreams.get(id);
        if (mediaStream != null) {
            for (VideoTrack track : mediaStream.videoTracks) {
                localTracks.remove(track.id());
                getUserMediaImpl.removeVideoCapturer(track.id());
            }
            for (AudioTrack track : mediaStream.audioTracks) {
                localTracks.remove(track.id());
            }
            localStreams.remove(id);
        } else {
            Log.d(TAG, "mediaStreamRelease() mediaStream is null");
        }
    }

    public void createDataChannel(final String peerConnectionId, String label, ConstraintsMap config, Result result) {
        // Forward to PeerConnectionObserver which deals with DataChannels
        // because DataChannel is owned by PeerConnection.
        PeerConnectionObserver pco
                = mPeerConnectionObservers.get(peerConnectionId);
        if (pco == null || pco.getPeerConnection() == null) {
            Log.d(TAG, "createDataChannel() peerConnection is null");
        } else {
            pco.createDataChannel(label, config, result);
        }
    }

    public void dataChannelSend(String peerConnectionId, int dataChannelId, String data, String type) {
        // Forward to PeerConnectionObserver which deals with DataChannels
        // because DataChannel is owned by PeerConnection.
        PeerConnectionObserver pco
                = mPeerConnectionObservers.get(peerConnectionId);
        if (pco == null || pco.getPeerConnection() == null) {
            Log.d(TAG, "dataChannelSend() peerConnection is null");
        } else {
            pco.dataChannelSend(dataChannelId, data, type);
        }
    }

    public void dataChannelClose(String peerConnectionId, int dataChannelId) {
        // Forward to PeerConnectionObserver which deals with DataChannels
        // because DataChannel is owned by PeerConnection.
        PeerConnectionObserver pco
                = mPeerConnectionObservers.get(peerConnectionId);
        if (pco == null || pco.getPeerConnection() == null) {
            Log.d(TAG, "dataChannelClose() peerConnection is null");
        } else {
            pco.dataChannelClose(dataChannelId);
        }
    }

}
