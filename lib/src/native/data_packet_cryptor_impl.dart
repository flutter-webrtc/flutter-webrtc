import 'dart:typed_data';

import 'package:webrtc_interface/webrtc_interface.dart';

import 'utils.dart';

class DataPacketCryptorImpl implements DataPacketCryptor {
  DataPacketCryptorImpl({required this.algorithm, required this.dataCryptorId});
  final Algorithm algorithm;
  final String dataCryptorId;

  @override
  Future<EncryptedPacket> encrypt({
    required String participantId,
    required int keyIndex,
    required Uint8List data,
  }) {
    try {
      return WebRTC.invokeMethod('dataPacketCryptorEncrypt', {
        'dataCryptorId': dataCryptorId,
        'participantId': participantId,
        'keyIndex': keyIndex,
        'data': data,
      }).then((response) {
        return EncryptedPacket(
          data: response['data'],
          keyIndex: response['keyIndex'],
          iv: response['iv'],
        );
      });
    } catch (e) {
      throw Exception('encryptDataPacket failed: $e');
    }
  }

  @override
  Future<Uint8List> decrypt({
    required String participantId,
    required EncryptedPacket encryptedPacket,
  }) async {
    try {
      final response = await WebRTC.invokeMethod('dataPacketCryptorDecrypt', {
        'dataCryptorId': dataCryptorId,
        'participantId': participantId,
        'data': encryptedPacket.data,
        'keyIndex': encryptedPacket.keyIndex,
        'iv': encryptedPacket.iv,
      });
      return response['data'];
    } catch (e) {
      throw Exception('decryptDataPacket failed: $e');
    }
  }

  @override
  Future<void> dispose() {
    return WebRTC.invokeMethod('dataPacketCryptorDispose', {
      'dataCryptorId': dataCryptorId,
    });
  }
}

class DataPacketCryptorFactoryImpl implements DataPacketCryptorFactory {
  DataPacketCryptorFactoryImpl._internal();

  static final DataPacketCryptorFactoryImpl instance =
      DataPacketCryptorFactoryImpl._internal();
  @override
  Future<DataPacketCryptor> createDataPacketCryptor(
      {required Algorithm algorithm, required KeyProvider keyProvider}) async {
    try {
      final response = await WebRTC.invokeMethod('createDataPacketCryptor', {
        'algorithm': algorithm.index,
        'keyProviderId': keyProvider.id,
      });
      return DataPacketCryptorImpl(
        algorithm: algorithm,
        dataCryptorId: response['dataCryptorId'],
      );
    } catch (e) {
      throw Exception('createDataPacketCryptor failed: $e');
    }
  }
}
