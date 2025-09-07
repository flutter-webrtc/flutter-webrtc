import 'dart:typed_data';

import 'package:webrtc_interface/webrtc_interface.dart';

class DataPacketCryptorImpl implements DataPacketCryptor {
  @override
  Future<EncryptedPacket> encrypt({
    required String participantId,
    required int keyIndex,
    required Uint8List data,
  }) {
    // TODO: implement encrypt
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> decrypt({
    required String participantId,
    required EncryptedPacket encryptedPacket,
  }) async {
    // TODO: implement decrypt
    throw UnimplementedError();
  }

  @override
  Future<void> dispose() {
    // TODO: implement dispose
    throw UnimplementedError();
  }
}

class DataPacketCryptorFactoryImpl implements DataPacketCryptorFactory {
  DataPacketCryptorFactoryImpl._internal();

  static final DataPacketCryptorFactoryImpl instance =
      DataPacketCryptorFactoryImpl._internal();
  @override
  Future<DataPacketCryptor> createDataPacketCryptor(
      {required Algorithm algorithm, required KeyProvider keyProvider}) {
    // TODO: implement createDataPacketCryptor
    throw UnimplementedError();
  }
}

DataPacketCryptorFactory get dataPacketCryptor =>
    DataPacketCryptorFactoryImpl.instance;
