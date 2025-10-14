import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class DataPacketCryptorSample extends StatefulWidget {
  static String tag = 'data_packet_cryptor_sample';

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<DataPacketCryptorSample> {
  final DataPacketCryptorFactory _dataPacketCryptorFactory =
      dataPacketCryptorFactory;
  KeyProvider? _keySharedProvider;
  DataPacketCryptor? _dataPacketCryptor;
  final demoRatchetSalt = 'flutter-webrtc-ratchet-salt';

  final aesKey = Uint8List.fromList([
    200,
    244,
    58,
    72,
    214,
    245,
    86,
    82,
    192,
    127,
    23,
    153,
    167,
    172,
    122,
    234,
    140,
    70,
    175,
    74,
    61,
    11,
    134,
    58,
    185,
    102,
    172,
    17,
    11,
    6,
    119,
    253
  ]);

  @override
  void initState() {
    print('Init State');
    super.initState();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  void _onTestFunc() async {
    var keyProviderOptions = KeyProviderOptions(
      sharedKey: false,
      ratchetSalt: Uint8List.fromList(demoRatchetSalt.codeUnits),
      ratchetWindowSize: 16,
      failureTolerance: -1,
    );

    _keySharedProvider ??=
        await frameCryptorFactory.createDefaultKeyProvider(keyProviderOptions);

    var participantId = 'participantId_1';

    await _keySharedProvider?.setKey(
        participantId: participantId, index: 0, key: aesKey);

    _dataPacketCryptor ??=
        await _dataPacketCryptorFactory.createDataPacketCryptor(
            algorithm: Algorithm.kAesGcm, keyProvider: _keySharedProvider!);

    var data = Uint8List.fromList('Hello world!'.codeUnits);
    print('plain data: $data');
    var encryptedPacket = await _dataPacketCryptor?.encrypt(
        participantId: participantId, keyIndex: 0, data: data);
    print(
        'encrypted data: ${encryptedPacket?.data}, keyIndex: ${encryptedPacket?.keyIndex}, iv: ${encryptedPacket?.iv}');
    var decryptedData = await _dataPacketCryptor?.decrypt(
        participantId: participantId, encryptedPacket: encryptedPacket!);
    print('decrypted data: $decryptedData');
    print('decrypted string: ${String.fromCharCodes(decryptedData!)}');
    await _dataPacketCryptor?.dispose();
    _dataPacketCryptor = null;
    await _keySharedProvider?.dispose();
    _keySharedProvider = null;
  }

  @override
  Widget build(BuildContext context) {
    var widgets = <Widget>[
      Text('data cryptor sample'),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('Data packet cryptor sample'),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(color: Colors.black54),
                child: orientation == Orientation.portrait
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: widgets)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: widgets),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: OverflowBar(
                  children: [
                    FloatingActionButton(
                        heroTag: null,
                        tooltip: 'test',
                        onPressed: _onTestFunc,
                        child: Icon(Icons.play_arrow)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
