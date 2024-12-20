# End to End Encryption

E2EE is an AES-GCM encryption interface injected before sending the packaged RTP packet and after receiving the RTP packet, ensuring that the data is not eavesdropped when passing through SFU or any public transmission network. It coexists with DTLS-SRTP as two layers of encryption. You can control the key, ratchet and other operations of FrameCryptor yourself to ensure that no third party will monitor your tracks.

## Process of enabling E2EE

1, Prepare the key provider

`ratchetSalt` is used to add to the mixture when ratcheting or deriving AES passwords
`aesKey` aesKey is the plaintext password you entered, which will be used to derive the actual password

```dart
    final aesKey = 'you-private-key-here'.codeUnits;
    final ratchetSalt = 'flutter-webrtc-ratchet-salt';

    var keyProviderOptions = KeyProviderOptions(
      sharedKey: true,
      ratchetSalt: Uint8List.fromList(ratchetSalt.codeUnits),
      ratchetWindowSize: 16,
      failureTolerance: -1,
    );

    var keyProvider = await frameCyrptorFactory.createDefaultKeyProvider(keyProviderOptions);
    /// set shared key for all track, default index is 0
    /// also you can set multiple keys by different indexes
    await keyProvider.setSharedKey(key: aesKey);
```

2,  create PeerConnectioin

when you use E2EE on the web, please add `encodedInsertableStreams`,

``` dart
var pc = await createPeerConnection( {
        'encodedInsertableStreams': true,
        });
```

3, Enable FrameCryptor for RTPSender.

```dart
var stream = await navigator.mediaDevices
        .getUserMedia({'audio': true, 'video': false });
var audioTrack = stream.getAudioTracks();
var sender = await pc.addTrack(audioTrack, stream);

var trackId = audioTrack?.id;
var id = 'audio_' + trackId! + '_sender';

var frameCyrptor =
            await frameCyrptorFactory.createFrameCryptorForRtpSender(
                participantId: id,
                sender: sender,
                algorithm: Algorithm.kAesGcm,
                keyProvider: keyProvider!);
/// print framecyrptor state
frameCyrptor.onFrameCryptorStateChanged = (participantId, state) =>
            print('EN onFrameCryptorStateChanged $participantId $state');

/// set currently shared key index
await frameCyrptor.setKeyIndex(0);

/// enable encryption now.
await frameCyrptor.setEnabled(true);
```

4, Enable FrameCryptor for RTPReceiver

```dart

pc.onTrack((RTCTrackEvent event) async {
    var receiver = event.receiver;
    var trackId = event.track?.id;
    var id = event.track.kind + '_' + trackId! + '_receiver';

    var frameCyrptor =
                await frameCyrptorFactory.createFrameCryptorForRtpReceiver(
                    participantId: id,
                    receiver: receiver,
                    algorithm: Algorithm.kAesGcm,
                    keyProvider: keyProvider);
        
    frameCyrptor.onFrameCryptorStateChanged = (participantId, state) =>
            print('DE onFrameCryptorStateChanged $participantId $state');

    /// set currently shared key index
    await frameCyrptor.setKeyIndex(0);

    /// enable encryption now.
    await frameCyrptor.setEnabled(true);
});
```
