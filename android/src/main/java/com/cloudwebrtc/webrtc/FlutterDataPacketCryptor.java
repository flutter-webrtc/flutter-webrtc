package com.cloudwebrtc.webrtc;

import androidx.annotation.NonNull;

import com.cloudwebrtc.webrtc.utils.ConstraintsMap;

import org.webrtc.DataPacketCryptor;
import org.webrtc.DataPacketCryptorFactory;
import org.webrtc.FrameCryptor;
import org.webrtc.FrameCryptorAlgorithm;
import org.webrtc.FrameCryptorKeyProvider;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

class FlutterDataPacketCryptor {
    private static final String TAG = "FlutterDataPacketCryptor";
    private final Map<String, DataPacketCryptor> dataCryptos = new HashMap<>();

    private final FlutterRTCFrameCryptor frameCryptor;

    public FlutterDataPacketCryptor(FlutterRTCFrameCryptor frameCryptor) {
        this.frameCryptor = frameCryptor;
    }

    public boolean handleMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        String method_name = call.method;
        Map<String, Object> params = (Map<String, Object>) call.arguments;
        if (method_name.equals("createDataPacketCryptor")) {
            createDataPacketCryptor(params, result);
        } else if(method_name.equals("dataPacketCryptorEncrypt")) {
            dataPacketCryptorEncrypt(params, result);
        } else if(method_name.equals("dataPacketCryptorDecrypt")) {
            dataPacketCryptorDecrypt(params, result);
        } else if(method_name.equals("dataPacketCryptorDispose")) {
            dataPacketCryptorDispose(params, result);
        } else {
            return false;
        }
        return true;
    }

    private void createDataPacketCryptor(@NonNull Map<String, Object> params, @NonNull MethodChannel.Result result) {
        String keyProviderId = (String) params.get("keyProviderId");
        FrameCryptorKeyProvider keyProvider = frameCryptor.getKeyProvider(keyProviderId);
        if (keyProvider == null) {
            result.error("createDataPacketCryptorFailed", "keyProvider not found", null);
            return;
        }

        if(params.get("algorithm") == null) {
            result.error("createDataPacketCryptorFailed", "algorithm is null", null);
            return;
        }

        int algorithm = (int) params.get("algorithm");

        DataPacketCryptor dataPacketCryptor = DataPacketCryptorFactory.createDataPacketCryptor(
                frameCryptor.frameCryptorAlgorithmFromInt(algorithm),
                keyProvider);
        if(dataPacketCryptor == null) {
            result.error("createDataPacketCryptorFailed", "createDataPacketCryptor failed", null);
            return;
        }

        String dataCryptorId = UUID.randomUUID().toString();
        dataCryptos.put(dataCryptorId, dataPacketCryptor);

        ConstraintsMap paramsResult = new ConstraintsMap();
        paramsResult.putString("dataCryptorId", dataCryptorId);
        result.success(paramsResult.toMap());
    }

    private void dataPacketCryptorEncrypt(@NonNull Map<String, Object> params, @NonNull MethodChannel.Result result) {
        String dataCryptorId = (String) params.get("dataCryptorId");
        if (dataCryptorId == null) {
            result.error("dataPacketCryptorEncryptFailed", "dataCryptorId is null", null);
            return;
        }

        DataPacketCryptor dataPacketCryptor = dataCryptos.get(dataCryptorId);
        if(dataPacketCryptor == null) {
            result.error("dataPacketCryptorEncryptFailed", "dataPacketCryptor not found", null);
            return;
        }

        String participantId = (String) params.get("participantId");
        if (participantId == null) {
            result.error("dataPacketCryptorEncryptFailed", "participantId is null", null);
            return;
        }

        byte[] data = (byte[]) params.get("data");
        if (data == null) {
            result.error("dataPacketCryptorEncryptFailed", "data is null", null);
            return;
        }

        int keyIndex = (int) params.get("keyIndex");
        if( keyIndex < 0 ) {
            result.error("dataPacketCryptorEncryptFailed", "keyIndex is invalid", null);
            return;
        }

        DataPacketCryptor.EncryptedPacket packet = dataPacketCryptor.encrypt(participantId, keyIndex, data);
        ConstraintsMap paramsResult = new ConstraintsMap();
        paramsResult.putInt("keyIndex", packet.keyIndex);
        paramsResult.putByte("data", packet.payload);
        paramsResult.putByte("iv", packet.iv);
        result.success(paramsResult.toMap());
    }

    private void dataPacketCryptorDecrypt(@NonNull Map<String, Object> params, @NonNull MethodChannel.Result result) {
        String dataCryptorId = (String) params.get("dataCryptorId");
        if (dataCryptorId == null) {
            result.error("dataPacketCryptorEncryptFailed", "dataCryptorId is null", null);
            return;
        }

        DataPacketCryptor dataPacketCryptor = dataCryptos.get(dataCryptorId);
        if(dataPacketCryptor == null) {
            result.error("dataPacketCryptorEncryptFailed", "dataPacketCryptor not found", null);
            return;
        }

        String participantId = (String) params.get("participantId");
        if (participantId == null) {
            result.error("dataPacketCryptorEncryptFailed", "participantId is null", null);
            return;
        }

        byte[] data = (byte[]) params.get("data");
        if (data == null) {
            result.error("dataPacketCryptorEncryptFailed", "data is null", null);
            return;
        }

        byte[] iv = (byte[]) params.get("iv");
        if (iv == null) {
            result.error("dataPacketCryptorEncryptFailed", "iv is null", null);
            return;
        }

        int keyIndex = (int) params.get("keyIndex");
        if( keyIndex < 0 ) {
            result.error("dataPacketCryptorEncryptFailed", "keyIndex is invalid", null);
            return;
        }
        DataPacketCryptor.EncryptedPacket encryptedPacket = new DataPacketCryptor.EncryptedPacket(data, iv, keyIndex);
        byte[] decrypted = dataPacketCryptor.decrypt(participantId, encryptedPacket);
        if(decrypted == null) {
            result.error("dataPacketCryptorDecryptFailed", "decrypt failed", null);
            return;
        }

        ConstraintsMap paramsResult = new ConstraintsMap();
        paramsResult.putByte("data", decrypted);
        result.success(paramsResult.toMap());
    }

    private void dataPacketCryptorDispose(@NonNull Map<String, Object> params, @NonNull MethodChannel.Result result) {
        String dataCryptorId = (String) params.get("dataCryptorId");
        if (dataCryptorId == null) {
            result.error("dataPacketCryptorDisposeFailed", "dataCryptorId is null", null);
            return;
        }

        DataPacketCryptor dataPacketCryptor = dataCryptos.remove(dataCryptorId);
        if(dataPacketCryptor == null) {
            result.error("dataPacketCryptorDisposeFailed", "dataPacketCryptor not found", null);
            return;
        }

        if (dataPacketCryptor != null) {
            dataPacketCryptor.dispose();
        }
        result.success(null);
    }
}
