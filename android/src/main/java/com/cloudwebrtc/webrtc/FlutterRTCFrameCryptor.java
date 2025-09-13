package com.cloudwebrtc.webrtc;

import android.util.Log;

import androidx.annotation.NonNull;

import org.webrtc.FrameCryptor;
import org.webrtc.FrameCryptorAlgorithm;
import org.webrtc.FrameCryptorFactory;
import org.webrtc.FrameCryptorKeyProvider;
import org.webrtc.RtpReceiver;
import org.webrtc.RtpSender;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import com.cloudwebrtc.webrtc.utils.AnyThreadSink;
import com.cloudwebrtc.webrtc.utils.ConstraintsMap;
import com.cloudwebrtc.webrtc.utils.ConstraintsArray;

public class FlutterRTCFrameCryptor {

    class FrameCryptorStateObserver  implements FrameCryptor.Observer, EventChannel.StreamHandler {
        public FrameCryptorStateObserver(BinaryMessenger messenger, String frameCryptorId){
            this.frameCryptorId = frameCryptorId;
            eventChannel = new EventChannel(messenger, "FlutterWebRTC/frameCryptorEvent" + frameCryptorId);
            eventChannel.setStreamHandler(new EventChannel.StreamHandler() {
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
            });
        }
        private final EventChannel eventChannel;
        private EventChannel.EventSink eventSink;
        private final ArrayList eventQueue = new ArrayList();
        private final String frameCryptorId;

        @Override
        public void onListen(Object arguments, EventChannel.EventSink events) {
            eventSink = new AnyThreadSink(events);
            for(Object event : eventQueue) {
                eventSink.success(event);
            }
            eventQueue.clear();
        }

        @Override
        public void onCancel(Object arguments) {
            eventSink = null;
        }

        private String  frameCryptorErrorStateToString( FrameCryptor.FrameCryptionState state) {
            switch (state) {
                case NEW:
                    return "new";
                case OK:
                    return "ok";
                case DECRYPTIONFAILED:
                    return "decryptionFailed";
                case ENCRYPTIONFAILED:
                    return "encryptionFailed";
                case INTERNALERROR:
                    return "internalError";
                case KEYRATCHETED:
                    return "keyRatcheted";
                case MISSINGKEY:
                    return "missingKey";
                default:
                    throw new IllegalArgumentException("Unknown FrameCryptorErrorState: " + state);
            }
        }

        @Override
        public void onFrameCryptionStateChanged(String participantId, FrameCryptor.FrameCryptionState state) {
            Map<String, Object> event = new HashMap<>();
            event.put("event", "frameCryptionStateChanged");
            event.put("participantId", participantId);
            event.put("state",frameCryptorErrorStateToString(state));
            if (eventSink != null) {
                eventSink.success(event);
            } else {
                eventQueue.add(event);
            }
        }
    }

    private static final String TAG = "FlutterRTCFrameCryptor";
    private final Map<String, FrameCryptor> frameCryptos = new HashMap<>();
    private final Map<String, FrameCryptorStateObserver> frameCryptoObservers = new HashMap<>();
    private final Map<String, FrameCryptorKeyProvider> keyProviders = new HashMap<>();
    private final StateProvider stateProvider;
    public FlutterRTCFrameCryptor(StateProvider stateProvider) {
        this.stateProvider = stateProvider;
    }
    public boolean handleMethodCall(MethodCall call, @NonNull Result result) {
        String method_name = call.method;
        Map<String, Object> params = (Map<String, Object>) call.arguments;
        if (method_name.equals("frameCryptorFactoryCreateFrameCryptor")) {
            frameCryptorFactoryCreateFrameCryptor(params, result);
          } else if (method_name.equals("frameCryptorSetKeyIndex")) {
            frameCryptorSetKeyIndex(params, result);
          } else if (method_name.equals("frameCryptorGetKeyIndex")) {
            frameCryptorGetKeyIndex(params, result);
          } else if (method_name.equals("frameCryptorSetEnabled")) {
            frameCryptorSetEnabled(params, result);
          } else if (method_name.equals("frameCryptorGetEnabled")) {
            frameCryptorGetEnabled(params, result);
          } else if (method_name.equals("frameCryptorDispose")) {
            frameCryptorDispose(params, result);
          } else if (method_name.equals("frameCryptorFactoryCreateKeyProvider")) {
            frameCryptorFactoryCreateKeyProvider(params, result);
          }else if (method_name.equals("keyProviderSetSharedKey")) {
            keyProviderSetSharedKey(params, result);
          } else if (method_name.equals("keyProviderRatchetSharedKey")) {
            keyProviderRatchetSharedKey(params, result);
          }  else if (method_name.equals("keyProviderExportSharedKey")) {
            keyProviderExportKey(params, result);
          } else if (method_name.equals("keyProviderSetKey")) {
            keyProviderSetKey(params, result);
          } else if (method_name.equals("keyProviderRatchetKey")) {
            keyProviderRatchetKey(params, result);
          } else if (method_name.equals("keyProviderExportKey")) {
            keyProviderExportKey(params, result);
          } else if (method_name.equals("keyProviderSetSifTrailer")) {
            keyProviderSetSifTrailer(params, result);
          } else if (method_name.equals("keyProviderDispose")) {
            keyProviderDispose(params, result);
          } else  {
            return false;
          }
        return true;
    }

    public FrameCryptorAlgorithm frameCryptorAlgorithmFromInt(int algorithm) {
        switch (algorithm) {
            case 0:
                return FrameCryptorAlgorithm.AES_GCM;
            default:
                return FrameCryptorAlgorithm.AES_GCM;
        }
    }

    private void frameCryptorFactoryCreateFrameCryptor(Map<String, Object> params, @NonNull Result result) {
        String keyProviderId = (String) params.get("keyProviderId");
        FrameCryptorKeyProvider keyProvider = keyProviders.get(keyProviderId);
        if (keyProvider == null) {
            result.error("frameCryptorFactoryCreateFrameCryptorFailed", "keyProvider not found", null);
            return;
        }
        String peerConnectionId = (String) params.get("peerConnectionId");
        PeerConnectionObserver pco = stateProvider.getPeerConnectionObserver(peerConnectionId);
        if (pco == null) {
            result.error("frameCryptorFactoryCreateFrameCryptorFailed", "peerConnection not found", null);
            return;
        }
        String participantId = (String) params.get("participantId");
        String type = (String) params.get("type");
        int algorithm = (int) params.get("algorithm");
        String rtpSenderId = (String) params.get("rtpSenderId");
        String rtpReceiverId = (String) params.get("rtpReceiverId");

        if(type.equals("sender")) {
            RtpSender rtpSender = pco.getRtpSenderById(rtpSenderId);

            FrameCryptor frameCryptor = FrameCryptorFactory.createFrameCryptorForRtpSender(stateProvider.getPeerConnectionFactory(),
                    rtpSender,
                    participantId,
                    frameCryptorAlgorithmFromInt(algorithm),
                    keyProvider);
            String frameCryptorId = UUID.randomUUID().toString();
            frameCryptos.put(frameCryptorId, frameCryptor);
            FrameCryptorStateObserver observer = new FrameCryptorStateObserver(stateProvider.getMessenger(), frameCryptorId);
            frameCryptor.setObserver(observer);
            frameCryptoObservers.put(frameCryptorId, observer);
            ConstraintsMap paramsResult = new ConstraintsMap();
            paramsResult.putString("frameCryptorId", frameCryptorId);
            result.success(paramsResult.toMap());
        } else if(type.equals("receiver")) {
            RtpReceiver rtpReceiver = pco.getRtpReceiverById(rtpReceiverId);

            FrameCryptor frameCryptor = FrameCryptorFactory.createFrameCryptorForRtpReceiver(stateProvider.getPeerConnectionFactory(),
                    rtpReceiver,
                    participantId,
                    frameCryptorAlgorithmFromInt(algorithm),
                    keyProvider);
            String frameCryptorId = UUID.randomUUID().toString();
            frameCryptos.put(frameCryptorId, frameCryptor);
            FrameCryptorStateObserver observer = new FrameCryptorStateObserver(stateProvider.getMessenger(), frameCryptorId);
            frameCryptor.setObserver(observer);
            frameCryptoObservers.put(frameCryptorId, observer);
            ConstraintsMap paramsResult = new ConstraintsMap();
            paramsResult.putString("frameCryptorId", frameCryptorId);
            result.success(paramsResult.toMap());
        } else {
            result.error("frameCryptorFactoryCreateFrameCryptorFailed", "type must be sender or receiver", null);
        }
    }

    private void frameCryptorSetKeyIndex(Map<String, Object> params, @NonNull Result result) {
        String frameCryptorId = (String) params.get("frameCryptorId");
        FrameCryptor frameCryptor = frameCryptos.get(frameCryptorId);
        if (frameCryptor == null) {
            result.error("frameCryptorSetKeyIndexFailed", "frameCryptor not found", null);
            return;
        }
        int keyIndex = (int) params.get("keyIndex");
        frameCryptor.setKeyIndex(keyIndex);
        ConstraintsMap paramsResult = new ConstraintsMap();
        paramsResult.putBoolean("result", true);
        result.success(paramsResult.toMap());
    }

    private void frameCryptorGetKeyIndex(Map<String, Object> params, @NonNull Result result) {
        String frameCryptorId = (String) params.get("frameCryptorId");
        FrameCryptor frameCryptor = frameCryptos.get(frameCryptorId);
        if (frameCryptor == null) {
            result.error("frameCryptorGetKeyIndexFailed", "frameCryptor not found", null);
            return;
        }
        int keyIndex = frameCryptor.getKeyIndex();
        ConstraintsMap paramsResult = new ConstraintsMap();
        paramsResult.putInt("keyIndex", keyIndex);
        result.success(paramsResult.toMap());
    }

    private void frameCryptorSetEnabled(Map<String, Object> params, @NonNull Result result) {
        String frameCryptorId = (String) params.get("frameCryptorId");
        FrameCryptor frameCryptor = frameCryptos.get(frameCryptorId);
        if (frameCryptor == null) {
            result.error("frameCryptorSetEnabledFailed", "frameCryptor not found", null);
            return;
        }
        boolean enabled = (boolean) params.get("enabled");
        frameCryptor.setEnabled(enabled);

        ConstraintsMap paramsResult = new ConstraintsMap();
        paramsResult.putBoolean("result", enabled);
        result.success(paramsResult.toMap());
    }

    private void frameCryptorGetEnabled(Map<String, Object> params, @NonNull Result result) {
        String frameCryptorId = (String) params.get("frameCryptorId");
        FrameCryptor frameCryptor = frameCryptos.get(frameCryptorId);
        if (frameCryptor == null) {
            result.error("frameCryptorGetEnabledFailed", "frameCryptor not found", null);
            return;
        }
        boolean enabled = frameCryptor.isEnabled();
        ConstraintsMap paramsResult = new ConstraintsMap();
        paramsResult.putBoolean("enabled", enabled);
        result.success(paramsResult.toMap());
    }

    private void frameCryptorDispose(Map<String, Object> params, @NonNull Result result) {
        String frameCryptorId = (String) params.get("frameCryptorId");
        FrameCryptor frameCryptor = frameCryptos.get(frameCryptorId);
        if (frameCryptor == null) {
            result.error("frameCryptorDisposeFailed", "frameCryptor not found", null);
            return;
        }
        frameCryptor.dispose();
        frameCryptos.remove(frameCryptorId);
        frameCryptoObservers.remove(frameCryptorId);
        ConstraintsMap paramsResult = new ConstraintsMap();
        paramsResult.putString("result", "success");
        result.success(paramsResult.toMap());
    }

    private void frameCryptorFactoryCreateKeyProvider(Map<String, Object> params, @NonNull Result result) {
        String keyProviderId = UUID.randomUUID().toString();
        Map<String, Object> keyProviderOptions = (Map<String, Object>) params.get("keyProviderOptions");
        boolean sharedKey = (boolean) keyProviderOptions.get("sharedKey");
        int ratchetWindowSize = (int) keyProviderOptions.get("ratchetWindowSize");
        int failureTolerance = (int) keyProviderOptions.get("failureTolerance");
        byte[] ratchetSalt = ( byte[]) keyProviderOptions.get("ratchetSalt");
        byte[] uncryptedMagicBytes = new byte[0];
        if(keyProviderOptions.containsKey("uncryptedMagicBytes")) {
            uncryptedMagicBytes = ( byte[]) keyProviderOptions.get("uncryptedMagicBytes");
        }
        int keyRingSize = (int) keyProviderOptions.get("keyRingSize");
        boolean discardFrameWhenCryptorNotReady = (boolean) keyProviderOptions.get("discardFrameWhenCryptorNotReady");
        FrameCryptorKeyProvider keyProvider = FrameCryptorFactory.createFrameCryptorKeyProvider(sharedKey, ratchetSalt, ratchetWindowSize, uncryptedMagicBytes, failureTolerance, keyRingSize, discardFrameWhenCryptorNotReady);
        ConstraintsMap paramsResult = new ConstraintsMap();
        keyProviders.put(keyProviderId, keyProvider);
        paramsResult.putString("keyProviderId", keyProviderId);
        result.success(paramsResult.toMap());
    }

    private void keyProviderSetSharedKey(Map<String, Object> params, @NonNull Result result) {
        String keyProviderId = (String) params.get("keyProviderId");
        FrameCryptorKeyProvider keyProvider = keyProviders.get(keyProviderId);
        if (keyProvider == null) {
            result.error("keyProviderSetKeySharedFailed", "keyProvider not found", null);
            return;
        }
        int keyIndex = (int) params.get("keyIndex");
        byte[] key = ( byte[]) params.get("key");
        keyProvider.setSharedKey(keyIndex, key);

        ConstraintsMap paramsResult = new ConstraintsMap();
        paramsResult.putBoolean("result", true);
        result.success(paramsResult.toMap());
    }

    private void keyProviderRatchetSharedKey(Map<String, Object> params, @NonNull Result result) {
        String keyProviderId = (String) params.get("keyProviderId");
        FrameCryptorKeyProvider keyProvider = keyProviders.get(keyProviderId);
        if (keyProvider == null) {
            result.error("keyProviderRatchetSharedKeyFailed", "keyProvider not found", null);
            return;
        }
        int keyIndex = (int) params.get("keyIndex");

        byte[] newKey = keyProvider.ratchetSharedKey(keyIndex);

        ConstraintsMap paramsResult = new ConstraintsMap();
        paramsResult.putByte("result", newKey);
        result.success(paramsResult.toMap());
    }

    private void keyProviderExportSharedKey(Map<String, Object> params, @NonNull Result result) {
        String keyProviderId = (String) params.get("keyProviderId");
        FrameCryptorKeyProvider keyProvider = keyProviders.get(keyProviderId);
        if (keyProvider == null) {
            result.error("keyProviderExportSharedKeyFailed", "keyProvider not found", null);
            return;
        }
        int keyIndex = (int) params.get("keyIndex");

        byte[] key = keyProvider.exportSharedKey(keyIndex);

        ConstraintsMap paramsResult = new ConstraintsMap();
        paramsResult.putByte("result", key);
        result.success(paramsResult.toMap());
    }

    private void keyProviderSetKey(Map<String, Object> params, @NonNull Result result) {
        String keyProviderId = (String) params.get("keyProviderId");
        FrameCryptorKeyProvider keyProvider = keyProviders.get(keyProviderId);
        if (keyProvider == null) {
            result.error("keyProviderSetKeyFailed", "keyProvider not found", null);
            return;
        }
        int keyIndex = (int) params.get("keyIndex");
        String participantId = (String) params.get("participantId");
        byte[] key = ( byte[]) params.get("key");
        keyProvider.setKey(participantId, keyIndex, key);

        ConstraintsMap paramsResult = new ConstraintsMap();
        paramsResult.putBoolean("result", true);
        result.success(paramsResult.toMap());
    }

    private void keyProviderRatchetKey(Map<String, Object> params, @NonNull Result result) {
        String keyProviderId = (String) params.get("keyProviderId");
        FrameCryptorKeyProvider keyProvider = keyProviders.get(keyProviderId);
        if (keyProvider == null) {
            result.error("keyProviderSetKeysFailed", "keyProvider not found", null);
            return;
        }
        String participantId = (String) params.get("participantId");
        int keyIndex = (int) params.get("keyIndex");

        byte[] newKey = keyProvider.ratchetKey(participantId, keyIndex);

        ConstraintsMap paramsResult = new ConstraintsMap();
        paramsResult.putByte("result", newKey);
        result.success(paramsResult.toMap());
    }

    private void keyProviderExportKey(Map<String, Object> params, @NonNull Result result) {
        String keyProviderId = (String) params.get("keyProviderId");
        FrameCryptorKeyProvider keyProvider = keyProviders.get(keyProviderId);
        if (keyProvider == null) {
            result.error("keyProviderExportKeyFailed", "keyProvider not found", null);
            return;
        }
        String participantId = (String) params.get("participantId");
        int keyIndex = (int) params.get("keyIndex");

        byte[] key = keyProvider.exportKey(participantId, keyIndex);

        ConstraintsMap paramsResult = new ConstraintsMap();
        paramsResult.putByte("result", key);
        result.success(paramsResult.toMap());
    }

    private void keyProviderSetSifTrailer(Map<String, Object> params, @NonNull Result result) {
        String keyProviderId = (String) params.get("keyProviderId");
        FrameCryptorKeyProvider keyProvider = keyProviders.get(keyProviderId);
        if (keyProvider == null) {
            result.error("keyProviderSetSifTrailerFailed", "keyProvider not found", null);
            return;
        }
        byte[] sifTrailer = ( byte[]) params.get("sifTrailer");
        keyProvider.setSifTrailer(sifTrailer);

        ConstraintsMap paramsResult = new ConstraintsMap();
        paramsResult.putBoolean("result", true);
        result.success(paramsResult.toMap());
    }

    private void keyProviderDispose(Map<String, Object> params, @NonNull Result result) {
        String keyProviderId = (String) params.get("keyProviderId");
        FrameCryptorKeyProvider keyProvider = keyProviders.get(keyProviderId);
        if (keyProvider == null) {
            result.error("keyProviderDisposeFailed", "keyProvider not found", null);
            return;
        }
        keyProvider.dispose();
        keyProviders.remove(keyProviderId);
        ConstraintsMap paramsResult = new ConstraintsMap();
        paramsResult.putString("result", "success");
        result.success(paramsResult.toMap());
    }

    public FrameCryptorKeyProvider getKeyProvider(String id) {
        return keyProviders.get(id);
    }
}
