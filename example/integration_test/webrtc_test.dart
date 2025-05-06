import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter_test/flutter_test.dart';
import 'package:medea_flutter_webrtc/medea_flutter_webrtc.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      await initFfiBridge();
      await enableFakeMedia();
    }
  });

  testWidgets('Add transceiver', (WidgetTester tester) async {
    var pc = await PeerConnection.create(IceTransportType.all, []);
    var trans = await pc.addTransceiver(
      MediaKind.video,
      RtpTransceiverInit(TransceiverDirection.sendRecv),
    );

    expect(trans.mid, isNull);

    var response = await pc.createOffer();

    expect(response.description.contains('m=video'), isTrue);
    expect(response.description.contains('sendrecv'), isTrue);

    await pc.close();
    await trans.dispose();
  });

  testWidgets('Add transceiver with simulcast', (WidgetTester tester) async {
    var pc = await PeerConnection.create(IceTransportType.all, []);

    var videoInit1 = RtpTransceiverInit(TransceiverDirection.sendOnly);

    var h = SendEncodingParameters.create(
      "h",
      true,
      maxBitrate: 1200 * 1024,
      maxFramerate: 30,
    );
    var m = SendEncodingParameters.create(
      "m",
      true,
      maxBitrate: 600 * 1024,
      maxFramerate: 30,
      scaleResolutionDownBy: 2,
    );
    var l = SendEncodingParameters.create(
      "l",
      true,
      maxBitrate: 300 * 1024,
      scaleResolutionDownBy: 4,
    );

    videoInit1.sendEncodings.add(h);
    videoInit1.sendEncodings.add(m);
    videoInit1.sendEncodings.add(l);

    var videoTrans1 = await pc.addTransceiver(MediaKind.video, videoInit1);
    var response = await pc.createOffer();

    expect(response.description.contains('a=mid:0'), isTrue);
    expect(response.description.contains('m=video'), isTrue);
    expect(response.description.contains('sendonly'), isTrue);
    expect(response.description.contains('a=rid:h send'), isTrue);
    expect(response.description.contains('a=rid:m send'), isTrue);
    expect(response.description.contains('a=rid:l send'), isTrue);
    expect(response.description.contains('a=simulcast:send h;m;l'), isTrue);

    var params = await videoTrans1.sender.getParameters();

    expect(params.encodings.length, 3);

    expect(params.encodings[0].rid, h.rid);
    expect(params.encodings[0].active, h.active);
    expect(params.encodings[0].maxBitrate, h.maxBitrate);
    expect(params.encodings[0].scaleResolutionDownBy, h.scaleResolutionDownBy);

    expect(params.encodings[1].rid, m.rid);
    expect(params.encodings[1].active, m.active);
    expect(params.encodings[1].maxBitrate, m.maxBitrate);
    expect(params.encodings[1].scaleResolutionDownBy, m.scaleResolutionDownBy);

    expect(params.encodings[2].rid, l.rid);
    expect(params.encodings[2].active, l.active);
    expect(params.encodings[2].maxBitrate, l.maxBitrate);
    expect(params.encodings[2].scaleResolutionDownBy, l.scaleResolutionDownBy);

    await pc.close();
    await videoTrans1.dispose();
  });

  testWidgets('Get/set sender parameters', (WidgetTester tester) async {
    var pc = await PeerConnection.create(IceTransportType.all, []);

    var videoInit1 = RtpTransceiverInit(TransceiverDirection.sendOnly);

    var h = SendEncodingParameters.create(
      "h",
      true,
      maxBitrate: 1200 * 1024,
      maxFramerate: 30,
    );
    var m = SendEncodingParameters.create(
      "m",
      true,
      maxBitrate: 600 * 1024,
      maxFramerate: 20,
      scaleResolutionDownBy: 2,
      scalabilityMode: "L2T2",
    );
    var l = SendEncodingParameters.create(
      "l",
      true,
      maxBitrate: 300 * 1024,
      maxFramerate: 10,
      scaleResolutionDownBy: 4,
      scalabilityMode: "L1T2",
    );

    videoInit1.sendEncodings.add(h);
    videoInit1.sendEncodings.add(m);
    videoInit1.sendEncodings.add(l);

    var videoTrans1 = await pc.addTransceiver(MediaKind.video, videoInit1);

    var parameters = await videoTrans1.sender.getParameters();

    // assert initial values
    expect(parameters.encodings[0].rid, h.rid);
    expect(parameters.encodings[0].active, h.active);
    expect(parameters.encodings[0].maxFramerate, h.maxFramerate);
    expect(parameters.encodings[0].maxBitrate, h.maxBitrate);
    expect(parameters.encodings[0].scalabilityMode, h.scalabilityMode);
    expect(
      parameters.encodings[0].scaleResolutionDownBy,
      h.scaleResolutionDownBy,
    );

    expect(parameters.encodings[1].rid, m.rid);
    expect(parameters.encodings[1].active, m.active);
    expect(parameters.encodings[1].maxFramerate, m.maxFramerate);
    expect(parameters.encodings[1].maxBitrate, m.maxBitrate);
    expect(parameters.encodings[1].scalabilityMode, m.scalabilityMode);
    expect(
      parameters.encodings[1].scaleResolutionDownBy,
      m.scaleResolutionDownBy,
    );

    expect(parameters.encodings[2].rid, l.rid);
    expect(parameters.encodings[2].active, l.active);
    expect(parameters.encodings[2].maxFramerate, l.maxFramerate);
    expect(parameters.encodings[2].maxBitrate, l.maxBitrate);
    expect(parameters.encodings[2].scalabilityMode, l.scalabilityMode);
    expect(
      parameters.encodings[2].scaleResolutionDownBy,
      l.scaleResolutionDownBy,
    );

    // set new values
    parameters.encodings[0].maxFramerate = 25;
    parameters.encodings[0].maxBitrate = 800 * 1024;
    parameters.encodings[0].scaleResolutionDownBy = 2;
    parameters.encodings[0].scalabilityMode = "S3T3";

    parameters.encodings[1].maxFramerate = 15;
    parameters.encodings[1].maxBitrate = 400 * 1024;
    parameters.encodings[1].scaleResolutionDownBy = 4;
    parameters.encodings[1].scalabilityMode = "L2T1";

    parameters.encodings[2].maxFramerate = 5;
    parameters.encodings[2].maxBitrate = 200 * 1024;
    parameters.encodings[2].scaleResolutionDownBy = 8;

    await videoTrans1.sender.setParameters(parameters);
    var parameters2 = await videoTrans1.sender.getParameters();

    // assert new values
    expect(parameters2.encodings[0].active, true);
    expect(parameters2.encodings[0].maxFramerate, 25);
    expect(parameters2.encodings[0].maxBitrate, 800 * 1024);
    expect(parameters2.encodings[0].scaleResolutionDownBy, 2);
    expect(parameters2.encodings[0].scalabilityMode, "S3T3");

    expect(parameters2.encodings[1].active, true);
    expect(parameters2.encodings[1].maxFramerate, 15);
    expect(parameters2.encodings[1].maxBitrate, 400 * 1024);
    expect(parameters2.encodings[1].scaleResolutionDownBy, 4);
    expect(parameters2.encodings[1].scalabilityMode, "L2T1");

    expect(parameters2.encodings[2].active, true);
    expect(parameters2.encodings[2].maxFramerate, 5);
    expect(parameters2.encodings[2].maxBitrate, 200 * 1024);
    expect(parameters2.encodings[2].scaleResolutionDownBy, 8);
    expect(parameters2.encodings[2].scalabilityMode, "L1T2");

    await pc.close();
    await videoTrans1.dispose();
  });

  testWidgets('Correct codecs', (WidgetTester tester) async {
    var server = IceServer(['stun:stun.l.google.com:19302']);
    var pc1 = await PeerConnection.create(IceTransportType.all, [server]);

    var videoTransceiver = await pc1.addTransceiver(
      MediaKind.video,
      RtpTransceiverInit(TransceiverDirection.sendOnly),
    );

    var offer = (await pc1.createOffer()).description;

    var codecs = ['VP8/90000', 'VP9/90000', 'AV1/90000'];

    for (var codec in codecs) {
      var reg = RegExp(r'a=rtpmap:\d{2,3} ' + codec);
      expect(offer.contains(reg), isTrue);

      var rtpmaps = reg
          .allMatches(offer)
          .map((e) => RegExp(r'\d{2,3}').firstMatch(e[0]!)![0]!);

      for (var rtpmap in rtpmaps) {
        var fbPref = 'a=rtcp-fb:$rtpmap ';

        for (var fb in [
          'goog-remb',
          'transport-cc',
          'ccm fir',
          'nack',
          'nack pli',
        ]) {
          expect(offer.contains(fbPref + fb), isTrue);
        }
      }
    }

    await pc1.close();
    await videoTransceiver.dispose();
  });

  testWidgets('Video codec info', (WidgetTester tester) async {
    var decoders = await PeerConnection.videoDecoders();
    expect(
      decoders.where((dec) => dec.codec == VideoCodec.VP8).length,
      isNonZero,
    );
    expect(
      decoders.where((dec) => dec.codec == VideoCodec.VP9).length,
      isNonZero,
    );
    expect(
      decoders.where((dec) => dec.codec == VideoCodec.AV1).length,
      isNonZero,
    );
    if (!Platform.isAndroid && !Platform.isIOS) {
      expect(
        decoders.where((dec) => dec.codec == VideoCodec.H264).length,
        isZero,
      );
      expect(
        decoders.where((enc) => enc.codec == VideoCodec.H265).length,
        isZero,
      );
    }

    var encoders = await PeerConnection.videoEncoders();
    expect(
      encoders.where((enc) => enc.codec == VideoCodec.VP8).length,
      isNonZero,
    );
    expect(
      encoders.where((enc) => enc.codec == VideoCodec.VP9).length,
      isNonZero,
    );
    expect(
      encoders.where((enc) => enc.codec == VideoCodec.AV1).length,
      isNonZero,
    );
    if (!Platform.isAndroid && !Platform.isIOS) {
      expect(
        encoders.where((enc) => enc.codec == VideoCodec.H264).length,
        isZero,
      );
      expect(
        encoders.where((enc) => enc.codec == VideoCodec.H265).length,
        isZero,
      );
    }
  });

  testWidgets('Get video capabilities', (WidgetTester tester) async {
    var senderCapabilities = await RtpSender.getCapabilities(MediaKind.video);
    var receiverCapabilities = await RtpReceiver.getCapabilities(
      MediaKind.video,
    );

    var mimeTypes = [
      'video/rtx',
      'video/red',
      'video/ulpfec',
      'video/VP9',
      'video/VP8',
      'video/AV1',
    ];

    if (!Platform.isAndroid && !Platform.isIOS) {
      expect(
        senderCapabilities.codecs
            .where((cap) => cap.mimeType == 'video/H264')
            .firstOrNull,
        isNull,
      );
      expect(
        senderCapabilities.codecs
            .where((cap) => cap.mimeType == 'video/H265')
            .firstOrNull,
        isNull,
      );
      expect(
        receiverCapabilities.codecs
            .where((cap) => cap.mimeType == 'video/H264')
            .firstOrNull,
        isNull,
      );
      expect(
        receiverCapabilities.codecs
            .where((cap) => cap.mimeType == 'video/H265')
            .firstOrNull,
        isNull,
      );
    }

    for (var mimeType in mimeTypes) {
      expect(
        senderCapabilities.codecs
            .where((cap) => cap.mimeType == mimeType)
            .firstOrNull,
        isNotNull,
      );
      expect(
        receiverCapabilities.codecs
            .where((cap) => cap.mimeType == mimeType)
            .firstOrNull,
        isNotNull,
      );
    }
  });

  testWidgets('Get audio capabilities', (WidgetTester tester) async {
    var senderCapabilities = await RtpSender.getCapabilities(MediaKind.audio);
    var receiverCapabilities = await RtpReceiver.getCapabilities(
      MediaKind.audio,
    );

    var mimeTypes = [
      'audio/opus',
      'audio/red',
      'audio/G722',
      'audio/PCMU',
      'audio/PCMA',
      'audio/CN',
      'audio/telephone-event',
    ];

    for (var mimeType in mimeTypes) {
      expect(
        senderCapabilities.codecs
            .where((cap) => cap.mimeType == mimeType)
            .firstOrNull,
        isNotNull,
      );
      expect(
        receiverCapabilities.codecs
            .where((cap) => cap.mimeType == mimeType)
            .firstOrNull,
        isNotNull,
      );
    }
  });

  testWidgets('SetCodecPreferences', (WidgetTester tester) async {
    var pc1 = await PeerConnection.create(IceTransportType.all, []);
    var pc2 = await PeerConnection.create(IceTransportType.all, []);

    var vtrans = await pc1.addTransceiver(
      MediaKind.video,
      RtpTransceiverInit(TransceiverDirection.sendRecv),
    );

    var capabilities = await RtpSender.getCapabilities(MediaKind.video);

    var names = capabilities.codecs.map((c) => c.name).toList();
    expect(names.contains("VP9"), isTrue);
    expect(names.contains("VP8"), isTrue);
    expect(names.contains("AV1"), isTrue);
    if (!Platform.isAndroid && !Platform.isIOS) {
      expect(names.contains("H264"), isFalse);
      expect(names.contains("H265"), isFalse);
    }

    var vp8Preferences =
        capabilities.codecs.where((element) {
          return element.name == 'VP8';
        }).toList();

    await vtrans.setCodecPreferences(vp8Preferences);

    var offer = await pc1.createOffer();

    expect(offer.description.contains("VP8"), isTrue);
    expect(offer.description.contains("H264"), isFalse);
    expect(offer.description.contains("VP9"), isFalse);
    expect(offer.description.contains("AV1"), isFalse);

    await pc2.setRemoteDescription(offer);

    var answer = await pc2.createAnswer();

    expect(answer.description.contains("VP8"), isTrue);
    expect(answer.description.contains("H264"), isFalse);
    expect(answer.description.contains("VP9"), isFalse);
    expect(answer.description.contains("AV1"), isFalse);

    await pc1.close();
    await pc2.close();
    await vtrans.dispose();
  });

  testWidgets('Get transceivers', (WidgetTester tester) async {
    var pc = await PeerConnection.create(IceTransportType.all, []);
    var t1 = await pc.addTransceiver(
      MediaKind.video,
      RtpTransceiverInit(TransceiverDirection.sendRecv),
    );
    var t2 = await pc.addTransceiver(
      MediaKind.video,
      RtpTransceiverInit(TransceiverDirection.sendRecv),
    );

    var before = await pc.getTransceivers();

    expect(before[0].mid, isNull);
    expect(before[1].mid, isNull);

    var offer = await pc.createOffer();
    await pc.setLocalDescription(offer);

    var after = await pc.getTransceivers();

    expect(after[0].mid!.length, isNonZero);
    expect(after[1].mid!.length, isNonZero);
    expect(after[0].mid!, isNot(equals(after[1].mid)));

    expect(before[0].mid!.length, isNonZero);
    expect(before[1].mid!.length, isNonZero);
    expect(before[0].mid!, isNot(equals(before[1].mid!)));

    await pc.close();

    await t1.dispose();
    await t2.dispose();
    for (var e in before) {
      await e.dispose();
    }
    for (var e in after) {
      await e.dispose();
    }
  });

  testWidgets('Get transceiver direction', (WidgetTester tester) async {
    var pc = await PeerConnection.create(IceTransportType.all, []);
    var trans = await pc.addTransceiver(
      MediaKind.video,
      RtpTransceiverInit(TransceiverDirection.sendRecv),
    );

    var direction = await trans.getDirection();
    expect(direction, equals(TransceiverDirection.sendRecv));

    await pc.close();
    await trans.dispose();
  });

  testWidgets('Set transceiver direction', (WidgetTester tester) async {
    var pc = await PeerConnection.create(IceTransportType.all, []);
    var trans = await pc.addTransceiver(
      MediaKind.video,
      RtpTransceiverInit(TransceiverDirection.sendRecv),
    );

    var direction = await trans.getDirection();

    expect(direction, equals(TransceiverDirection.sendRecv));

    for (var dir in TransceiverDirection.values) {
      if (dir == TransceiverDirection.stopped) {
        continue;
      }

      await trans.setDirection(dir);

      direction = await trans.getDirection();

      expect(direction, equals(dir));
    }

    await pc.close();
    await trans.dispose();
  });

  testWidgets('Stop transceiver', (WidgetTester tester) async {
    var pc = await PeerConnection.create(IceTransportType.all, []);
    var trans = await pc.addTransceiver(
      MediaKind.video,
      RtpTransceiverInit(TransceiverDirection.sendRecv),
    );

    var direction = await trans.getDirection();

    expect(direction, equals(TransceiverDirection.sendRecv));

    await trans.stop();

    direction = await trans.getDirection();

    expect(direction, equals(TransceiverDirection.stopped));

    await pc.close();
    await trans.dispose();
  });

  testWidgets('Get transceiver mid', (WidgetTester tester) async {
    var pc = await PeerConnection.create(IceTransportType.all, []);
    var trans = await pc.addTransceiver(
      MediaKind.video,
      RtpTransceiverInit(TransceiverDirection.sendRecv),
    );

    expect(trans.mid, isNull);

    var sess = await pc.createOffer();
    await pc.setLocalDescription(sess);

    expect(trans.mid, equals('0'));

    await pc.close();
    await trans.dispose();
  });

  testWidgets('Add Ice Candidate', (WidgetTester tester) async {
    var pc1 = await PeerConnection.create(IceTransportType.all, []);
    var pc2 = await PeerConnection.create(IceTransportType.all, []);
    final completer = Completer<void>();

    pc1.onIceCandidate((candidate) async {
      if (!completer.isCompleted) {
        completer.complete();
      }
      if (!pc2.closed) {
        await pc2.addIceCandidate(candidate);
      }
    });

    pc2.onIceCandidate((candidate) async {
      if (!completer.isCompleted) {
        completer.complete();
      }
      if (!pc1.closed) {
        await pc1.addIceCandidate(candidate);
      }
    });
    var t = await pc1.addTransceiver(
      MediaKind.video,
      RtpTransceiverInit(TransceiverDirection.sendRecv),
    );

    var offer = await pc1.createOffer();
    await pc1.setLocalDescription(offer);
    await pc2.setRemoteDescription(offer);

    var answer = await pc2.createAnswer();
    await pc2.setLocalDescription(answer);
    await pc1.setRemoteDescription(answer);

    await completer.future.timeout(const Duration(seconds: 1));

    await pc1.close();
    await pc2.close();
    await t.dispose();
  });

  testWidgets('Restart Ice', (WidgetTester tester) async {
    var pc1 = await PeerConnection.create(IceTransportType.all, []);
    var pc2 = await PeerConnection.create(IceTransportType.all, []);

    var tx = StreamController<int>();
    var rx = StreamIterator(tx.stream);

    var eventsCount = 0;
    pc1.onNegotiationNeeded(() {
      eventsCount++;
      tx.add(eventsCount);
    });

    var t = await pc1.addTransceiver(
      MediaKind.video,
      RtpTransceiverInit(TransceiverDirection.sendRecv),
    );

    var offer = await pc1.createOffer();
    await pc1.setLocalDescription(offer);
    await pc2.setRemoteDescription(offer);

    var answer = await pc2.createAnswer();
    await pc2.setLocalDescription(answer);
    await pc1.setRemoteDescription(answer);

    pc1.onIceCandidate((candidate) async {
      if (!pc2.closed) {
        await pc2.addIceCandidate(candidate);
      }
    });

    pc2.onIceCandidate((candidate) async {
      if (!pc1.closed) {
        await pc1.addIceCandidate(candidate);
      }
    });

    expect(await rx.moveNext(), isTrue);
    expect(rx.current, equals(1));

    await pc1.restartIce();

    expect(await rx.moveNext(), isTrue);
    expect(rx.current, equals(2));

    await pc1.close();
    await pc2.close();
    await t.dispose();
  });

  testWidgets('Ice state PeerConnection', (WidgetTester tester) async {
    var pc1 = await PeerConnection.create(IceTransportType.all, []);
    var pc2 = await PeerConnection.create(IceTransportType.all, []);

    var tx = StreamController<PeerConnectionState>();
    var rx = StreamIterator(tx.stream);

    pc1.onConnectionStateChange((state) {
      tx.add(state);
    });

    var t = await pc1.addTransceiver(
      MediaKind.video,
      RtpTransceiverInit(TransceiverDirection.sendRecv),
    );

    var offer = await pc1.createOffer();
    await pc1.setLocalDescription(offer);
    await pc2.setRemoteDescription(offer);

    var answer = await pc2.createAnswer();
    await pc2.setLocalDescription(answer);
    await pc1.setRemoteDescription(answer);

    pc1.onIceCandidate((candidate) async {
      if (!pc2.closed) {
        await pc2.addIceCandidate(candidate);
      }
    });
    pc2.onIceCandidate((candidate) async {
      if (!pc1.closed) {
        await pc1.addIceCandidate(candidate);
      }
    });

    expect(await rx.moveNext(), isTrue);
    expect(rx.current, equals(PeerConnectionState.connecting));

    expect(await rx.moveNext(), isTrue);
    expect(rx.current, equals(PeerConnectionState.connected));

    await pc1.close();

    expect(await rx.moveNext(), isTrue);
    expect(rx.current, equals(PeerConnectionState.closed));

    await pc2.close();
    await t.dispose();
  });

  testWidgets('Peer connection event on track', (WidgetTester tester) async {
    var pc1 = await PeerConnection.create(IceTransportType.all, []);
    var t = await pc1.addTransceiver(
      MediaKind.video,
      RtpTransceiverInit(TransceiverDirection.sendRecv),
    );

    var pc2 = await PeerConnection.create(IceTransportType.all, []);
    final completer = Completer<void>();
    pc2.onTrack((track, transceiver) async {
      completer.complete();
      await track.stop();
      await track.dispose();
      await transceiver.dispose();
    });
    await pc2.setRemoteDescription(await pc1.createOffer());
    await completer.future.timeout(const Duration(seconds: 1));

    await pc1.close();
    await pc2.close();
    await t.dispose();
  });

  testWidgets('Track Onended', (WidgetTester tester) async {
    var pc1 = await PeerConnection.create(IceTransportType.all, []);
    var tr = await pc1.addTransceiver(
      MediaKind.video,
      RtpTransceiverInit(TransceiverDirection.sendRecv),
    );

    var pc2 = await PeerConnection.create(IceTransportType.all, []);
    final completer = Completer<void>();
    pc2.onTrack((track, transceiver) async {
      track.onEnded(() async {
        completer.complete();
        await track.stop();
        await track.dispose();
      });
      await transceiver.dispose();
    });

    await pc2.setRemoteDescription(await pc1.createOffer());
    var transceivers = await pc2.getTransceivers();
    await transceivers[0].stop();
    await completer.future.timeout(const Duration(seconds: 10));

    for (var t in transceivers) {
      await t.dispose();
    }
    await pc1.close();
    await pc2.close();
    await tr.dispose();
  });

  testWidgets('Track Onended not working after stop()', (
    WidgetTester tester,
  ) async {
    var capsAudioOnly = DeviceConstraints();
    capsAudioOnly.audio.mandatory = AudioConstraints();

    var tracksAudioOnly = await getUserMedia(capsAudioOnly);
    expect(tracksAudioOnly.length, equals(1));

    var track = tracksAudioOnly[0];

    final completer = Completer<void>();
    track.onEnded(() {
      completer.complete();
    });

    var server = IceServer(['stun:stun.l.google.com:19302']);
    var pc1 = await PeerConnection.create(IceTransportType.all, [server]);
    var pc2 = await PeerConnection.create(IceTransportType.all, [server]);

    pc1.onIceCandidate((IceCandidate candidate) async {
      if (!pc2.closed) {
        await pc2.addIceCandidate(candidate);
      }
    });

    pc2.onIceCandidate((IceCandidate candidate) async {
      if (!pc1.closed) {
        await pc1.addIceCandidate(candidate);
      }
    });

    var audioTransceiver = await pc1.addTransceiver(
      MediaKind.audio,
      RtpTransceiverInit(TransceiverDirection.sendOnly),
    );

    audioTransceiver.sender.replaceTrack(track);

    var offer = await pc1.createOffer();
    await pc1.setLocalDescription(offer);
    await pc2.setRemoteDescription(offer);

    var answer = await pc2.createAnswer();
    await pc2.setLocalDescription(answer);
    await pc1.setRemoteDescription(answer);

    expect(await track.state(), equals(MediaStreamTrackState.live));

    await track.stop();

    try {
      await completer.future.timeout(const Duration(seconds: 3));
      throw Exception('Completer completed');
    } catch (e) {
      expect(e is TimeoutException, isTrue);
      expect(await track.state(), equals(MediaStreamTrackState.ended));
    }

    await pc1.close();
    await pc2.close();
    await audioTransceiver.dispose();
    await track.dispose();
  });

  testWidgets('Connect two peers', (WidgetTester tester) async {
    var caps = DeviceConstraints();
    caps.audio.mandatory = AudioConstraints();
    caps.video.mandatory = DeviceVideoConstraints();
    caps.video.mandatory!.width = 640;
    caps.video.mandatory!.height = 480;
    caps.video.mandatory!.fps = 30;

    var tracks = await getUserMedia(caps);

    var videoTrack = tracks.firstWhere(
      (track) => track.kind() == MediaKind.video,
    );
    var audioTrack = tracks.firstWhere(
      (track) => track.kind() == MediaKind.audio,
    );

    var server = IceServer(['stun:stun.l.google.com:19302']);
    var pc1 = await PeerConnection.create(IceTransportType.all, [server]);
    var pc2 = await PeerConnection.create(IceTransportType.all, [server]);

    var futures = List<Completer>.generate(6, (_) => Completer());
    pc1.onConnectionStateChange((state) {
      if (state == PeerConnectionState.connected) {
        futures[0].complete();
      }
    });

    pc2.onConnectionStateChange((state) {
      if (state == PeerConnectionState.connected) {
        futures[1].complete();
      }
    });

    pc2.onTrack((track, trans) async {
      if (track.kind() == MediaKind.video) {
        futures[2].complete();
      } else {
        futures[3].complete();
      }
      await track.stop();
      await track.dispose();
      await trans.dispose();
    });

    pc1.onIceCandidate((IceCandidate candidate) async {
      if (!pc2.closed) {
        await pc2.addIceCandidate(candidate);
      }

      if (!futures[4].isCompleted) {
        futures[4].complete();
      }
    });

    pc2.onIceCandidate((IceCandidate candidate) async {
      if (!pc1.closed) {
        await pc1.addIceCandidate(candidate);
      }

      if (!futures[5].isCompleted) {
        futures[5].complete();
      }
    });

    var videoTransceiver = await pc1.addTransceiver(
      MediaKind.video,
      RtpTransceiverInit(TransceiverDirection.sendOnly),
    );
    var audioTransceiver = await pc1.addTransceiver(
      MediaKind.audio,
      RtpTransceiverInit(TransceiverDirection.sendOnly),
    );

    videoTransceiver.sender.replaceTrack(videoTrack);
    audioTransceiver.sender.replaceTrack(audioTrack);

    var offer = await pc1.createOffer();
    await pc1.setLocalDescription(offer);
    await pc2.setRemoteDescription(offer);

    var answer = await pc2.createAnswer();
    await pc2.setLocalDescription(answer);
    await pc1.setRemoteDescription(answer);

    await Future.wait(
      futures.map((e) => e.future),
    ).timeout(const Duration(seconds: 5));

    await pc1.close();
    await pc2.close();
    await videoTrack.stop();
    await audioTrack.stop();
    await videoTrack.dispose();
    await audioTrack.dispose();
    await videoTransceiver.dispose();
    await audioTransceiver.dispose();
  });

  testWidgets('Clone track', (WidgetTester tester) async {
    var caps = DeviceConstraints();
    caps.video.mandatory = DeviceVideoConstraints();
    caps.video.mandatory!.width = 640;
    caps.video.mandatory!.height = 480;
    caps.video.mandatory!.fps = 30;

    var pc1 = await PeerConnection.create(IceTransportType.all, []);
    var pc2 = await PeerConnection.create(IceTransportType.all, []);
    var onEndedComplete = Completer();
    pc2.onTrack((track, transceiver) {
      if (transceiver.mid == '0') {
        track.onEnded(() async {
          onEndedComplete.complete();
          await track.stop();
          await track.dispose();
          await transceiver.dispose();
        });
      }
    });

    var t1 = await pc1.addTransceiver(
      MediaKind.video,
      RtpTransceiverInit(TransceiverDirection.sendOnly),
    );
    var t2 = await pc1.addTransceiver(
      MediaKind.video,
      RtpTransceiverInit(TransceiverDirection.sendOnly),
    );

    var tracks = await getUserMedia(caps);

    var videoTrack = tracks.firstWhere(
      (track) => track.kind() == MediaKind.video,
    );
    var cloneVideoTrack = await videoTrack.clone();
    await cloneVideoTrack.setEnabled(false);

    await t1.sender.replaceTrack(videoTrack);
    await t2.sender.replaceTrack(cloneVideoTrack);

    await pc2.setRemoteDescription(await pc1.createOffer());

    var transceivers = await pc2.getTransceivers();
    await transceivers.firstWhere((t) => t.mid == '0').stop();

    await onEndedComplete.future.timeout(const Duration(seconds: 10));
    expect(videoTrack.id(), isNot(equals(cloneVideoTrack.id())));
    expect(videoTrack.isEnabled(), isNot(equals(cloneVideoTrack.isEnabled())));

    await pc1.close();
    await pc2.close();
    await t1.dispose();
    await t2.dispose();
    for (var t in tracks) {
      await t.stop();
      await t.dispose();
    }
    for (var t in transceivers) {
      await t.dispose();
    }
    await cloneVideoTrack.stop();
    await cloneVideoTrack.dispose();
  });

  testWidgets('Media stream constraints', (WidgetTester tester) async {
    var capsVideoDeviceOnly = DeviceConstraints();
    capsVideoDeviceOnly.video.mandatory = DeviceVideoConstraints();
    capsVideoDeviceOnly.video.mandatory!.width = 640;
    capsVideoDeviceOnly.video.mandatory!.height = 480;
    capsVideoDeviceOnly.video.mandatory!.fps = 30;

    var capsAudioOnly = DeviceConstraints();
    capsAudioOnly.audio.mandatory = AudioConstraints();

    var capsVideoAudio = DeviceConstraints();
    capsVideoAudio.audio.mandatory = AudioConstraints();
    capsVideoAudio.video.mandatory = DeviceVideoConstraints();
    capsVideoAudio.video.mandatory!.width = 640;
    capsVideoAudio.video.mandatory!.height = 480;
    capsVideoAudio.video.mandatory!.fps = 30;

    var tracksAudioOnly = await getUserMedia(capsAudioOnly);
    bool hasVideo = tracksAudioOnly.any(
      (track) => track.kind() == MediaKind.video,
    );
    bool hasAudio = tracksAudioOnly.any(
      (track) => track.kind() == MediaKind.audio,
    );
    expect(hasVideo, isFalse);
    expect(hasAudio, isTrue);

    var tracksVideoDeviceOnly = await getUserMedia(capsVideoDeviceOnly);
    hasVideo = tracksVideoDeviceOnly.any(
      (track) => track.kind() == MediaKind.video,
    );
    hasAudio = tracksVideoDeviceOnly.any(
      (track) => track.kind() == MediaKind.audio,
    );
    expect(hasVideo, isTrue);
    expect(hasAudio, isFalse);

    var tracksVideoAudio = await getUserMedia(capsVideoAudio);
    hasVideo = tracksVideoAudio.any((track) => track.kind() == MediaKind.video);
    hasAudio = tracksVideoAudio.any((track) => track.kind() == MediaKind.audio);
    expect(hasVideo, isTrue);
    expect(hasAudio, isTrue);

    var tracks = tracksAudioOnly + tracksVideoDeviceOnly + tracksVideoAudio;
    for (var t in tracks) {
      await t.stop();
      await t.dispose();
    }
  });

  testWidgets('ICE transport types', (WidgetTester tester) async {
    // IceTransportType.all, STUN server
    {
      var server = IceServer(
        ['stun:stun.l.google.com:19302'],
        'username',
        'password',
      );
      var pc1 = await PeerConnection.create(IceTransportType.all, [server]);
      var pc2 = await PeerConnection.create(IceTransportType.all, [server]);

      var hasRelay = false;
      var hasSrflx = false;
      var hasHost = false;

      onIceCandidate(IceCandidate candidate) {
        if (candidate.candidate.contains('typ host')) {
          hasHost = true;
        } else if (candidate.candidate.contains('typ srflx')) {
          hasSrflx = true;
        } else if (candidate.candidate.contains('typ relay')) {
          hasRelay = true;
        }
      }

      pc1.onIceCandidate(onIceCandidate);
      pc2.onIceCandidate(onIceCandidate);

      var t1 = await pc1.addTransceiver(
        MediaKind.video,
        RtpTransceiverInit(TransceiverDirection.sendRecv),
      );
      var t2 = await pc1.addTransceiver(
        MediaKind.audio,
        RtpTransceiverInit(TransceiverDirection.sendRecv),
      );

      var offer = await pc1.createOffer();
      await pc1.setLocalDescription(offer);
      await pc2.setRemoteDescription(offer);

      var answer = await pc2.createAnswer();
      await pc2.setLocalDescription(answer);
      await pc1.setRemoteDescription(answer);

      await Future.delayed(const Duration(seconds: 5));

      expect(hasRelay, isFalse);
      expect(hasSrflx, isTrue);
      expect(hasHost, isTrue);

      await pc1.close();
      await pc2.close();
      await t1.dispose();
      await t2.dispose();
    }

    // IceTransportType.relay without server
    {
      var pc1 = await PeerConnection.create(IceTransportType.relay, []);
      var pc2 = await PeerConnection.create(IceTransportType.relay, []);

      var candidatesFired = 0;
      pc1.onIceCandidate((candidate) async {
        candidatesFired++;
      });
      pc2.onIceCandidate((candidate) async {
        candidatesFired++;
      });

      var t1 = await pc1.addTransceiver(
        MediaKind.video,
        RtpTransceiverInit(TransceiverDirection.sendRecv),
      );
      var t2 = await pc1.addTransceiver(
        MediaKind.audio,
        RtpTransceiverInit(TransceiverDirection.sendRecv),
      );

      var offer = await pc1.createOffer();
      await pc1.setLocalDescription(offer);
      await pc2.setRemoteDescription(offer);

      var answer = await pc2.createAnswer();
      await pc2.setLocalDescription(answer);
      await pc1.setRemoteDescription(answer);

      await Future.delayed(const Duration(seconds: 5));

      expect(candidatesFired, equals(0));

      await pc1.close();
      await pc2.close();
      await t1.dispose();
      await t2.dispose();
    }
  });

  testWidgets('Set recv direction', (WidgetTester tester) async {
    var pc = await PeerConnection.create(IceTransportType.all, []);
    // ignore: prefer_function_declarations_over_variables
    var testEnableRecv = (beforeDirection, afterDirection) async {
      var transceiver = await pc.addTransceiver(
        MediaKind.video,
        RtpTransceiverInit(beforeDirection),
      );
      await transceiver.setRecv(true);
      expect(await transceiver.getDirection(), afterDirection);

      await transceiver.dispose();
    };

    // ignore: prefer_function_declarations_over_variables
    var testDisableRecv = (beforeDirection, afterDirection) async {
      var transceiver = await pc.addTransceiver(
        MediaKind.video,
        RtpTransceiverInit(beforeDirection),
      );
      await transceiver.setRecv(false);
      expect(await transceiver.getDirection(), afterDirection);

      await transceiver.dispose();
    };

    var testEnable = [
      [TransceiverDirection.inactive, TransceiverDirection.recvOnly],
      [TransceiverDirection.recvOnly, TransceiverDirection.recvOnly],
      [TransceiverDirection.sendOnly, TransceiverDirection.sendRecv],
      [TransceiverDirection.sendRecv, TransceiverDirection.sendRecv],
    ];

    var testDisable = [
      [TransceiverDirection.inactive, TransceiverDirection.inactive],
      [TransceiverDirection.recvOnly, TransceiverDirection.inactive],
      [TransceiverDirection.sendOnly, TransceiverDirection.sendOnly],
      [TransceiverDirection.sendRecv, TransceiverDirection.sendOnly],
    ];

    for (
      var value = testEnable.removeAt(0);
      testEnable.isNotEmpty;
      value = testEnable.removeAt(0)
    ) {
      await testEnableRecv(value[0], value[1]);
    }

    for (
      var value = testDisable.removeAt(0);
      testDisable.isNotEmpty;
      value = testDisable.removeAt(0)
    ) {
      await testDisableRecv(value[0], value[1]);
    }

    await pc.close();
  });

  testWidgets('Set send direction', (WidgetTester tester) async {
    var pc = await PeerConnection.create(IceTransportType.all, []);
    // ignore: prefer_function_declarations_over_variables
    var testEnableRecv = (beforeDirection, afterDirection) async {
      var transceiver = await pc.addTransceiver(
        MediaKind.video,
        RtpTransceiverInit(beforeDirection),
      );
      await transceiver.setSend(true);
      expect(await transceiver.getDirection(), afterDirection);

      await transceiver.dispose();
    };

    // ignore: prefer_function_declarations_over_variables
    var testDisableRecv = (beforeDirection, afterDirection) async {
      var transceiver = await pc.addTransceiver(
        MediaKind.video,
        RtpTransceiverInit(beforeDirection),
      );
      await transceiver.setSend(false);
      expect(await transceiver.getDirection(), afterDirection);

      await transceiver.dispose();
    };

    var testEnable = [
      [TransceiverDirection.inactive, TransceiverDirection.sendOnly],
      [TransceiverDirection.sendOnly, TransceiverDirection.sendOnly],
      [TransceiverDirection.recvOnly, TransceiverDirection.sendRecv],
      [TransceiverDirection.sendRecv, TransceiverDirection.sendRecv],
    ];

    var testDisable = [
      [TransceiverDirection.inactive, TransceiverDirection.inactive],
      [TransceiverDirection.sendOnly, TransceiverDirection.inactive],
      [TransceiverDirection.recvOnly, TransceiverDirection.recvOnly],
      [TransceiverDirection.sendRecv, TransceiverDirection.recvOnly],
    ];

    for (
      var value = testEnable.removeAt(0);
      testEnable.isNotEmpty;
      value = testEnable.removeAt(0)
    ) {
      await testEnableRecv(value[0], value[1]);
    }

    for (
      var value = testDisable.removeAt(0);
      testDisable.isNotEmpty;
      value = testDisable.removeAt(0)
    ) {
      await testDisableRecv(value[0], value[1]);
    }

    await pc.close();
  });

  testWidgets('Handles still work after Peer close', (
    WidgetTester tester,
  ) async {
    var caps = DeviceConstraints();
    caps.audio.mandatory = AudioConstraints();
    caps.video.mandatory = DeviceVideoConstraints();
    caps.video.mandatory!.width = 640;
    caps.video.mandatory!.height = 480;
    caps.video.mandatory!.fps = 30;

    var tracks = await getUserMedia(caps);

    var server = IceServer(['stun:stun.l.google.com:19302']);
    var pc1 = await PeerConnection.create(IceTransportType.all, [server]);
    var pc2 = await PeerConnection.create(IceTransportType.all, [server]);

    var remoteTracks = List<MediaStreamTrack>.empty(growable: true);
    var remoteTransceiver = List<RtpTransceiver>.empty(growable: true);
    pc2.onTrack((track, trans) async {
      remoteTracks.add(track);
      remoteTransceiver.add(trans);
    });

    var vtrans = await pc1.addTransceiver(
      MediaKind.video,
      RtpTransceiverInit(TransceiverDirection.sendOnly),
    );

    var atrans = await pc1.addTransceiver(
      MediaKind.audio,
      RtpTransceiverInit(TransceiverDirection.sendOnly),
    );

    var offer = await pc1.createOffer();
    await pc1.setLocalDescription(offer);
    await pc2.setRemoteDescription(offer);

    var answer = await pc2.createAnswer();
    await pc2.setLocalDescription(answer);
    await pc1.setRemoteDescription(answer);

    pc1.onIceCandidate((IceCandidate candidate) async {
      if (!pc2.closed) {
        await pc2.addIceCandidate(candidate);
      }
    });

    pc2.onIceCandidate((IceCandidate candidate) async {
      if (!pc1.closed) {
        await pc1.addIceCandidate(candidate);
      }
    });

    await vtrans.sender.replaceTrack(
      tracks.firstWhere((track) => track.kind() == MediaKind.video),
    );

    await atrans.sender.replaceTrack(
      tracks.firstWhere((track) => track.kind() == MediaKind.audio),
    );

    await pc1.close();
    await pc2.close();

    for (var track in remoteTracks) {
      expect(await track.state(), MediaStreamTrackState.ended);
    }

    for (var transceiver in remoteTransceiver) {
      await transceiver.syncMid();
      expect(await transceiver.getDirection(), TransceiverDirection.stopped);
    }
  });

  testWidgets('Video dimensions', (WidgetTester tester) async {
    // iOS simulator does not have camera
    if (!Platform.isIOS) {
      var caps = DeviceConstraints();
      caps.video.mandatory = DeviceVideoConstraints();
      caps.video.mandatory!.width = 640;
      caps.video.mandatory!.height = 480;

      var track = (await getUserMedia(caps))[0];

      var w = await track.width();
      var h = await track.height();

      expect(w, equals(640));
      expect(h, equals(480));

      await track.dispose();
    }

    // Desktop only, since screen sharing is unimplemented on mobile platforms.
    if (!Platform.isAndroid && !Platform.isIOS) {
      var caps = DisplayConstraints();
      caps.video.mandatory = DeviceVideoConstraints();
      caps.video.mandatory!.width = 320;
      caps.video.mandatory!.height = 240;

      var track = (await getDisplayMedia(caps))[0];

      var w = await track.width();
      var h = await track.height();

      expect(w, equals(320));
      expect(h, equals(240));

      await track.dispose();
    }
  });

  testWidgets('on_track when peer has transceiver.', (
    WidgetTester tester,
  ) async {
    var pc1 = await PeerConnection.create(IceTransportType.all, []);
    var pc2 = await PeerConnection.create(IceTransportType.all, []);

    var t1 = await pc1.addTransceiver(
      MediaKind.video,
      RtpTransceiverInit(TransceiverDirection.sendRecv),
    );
    var t2 = await pc2.addTransceiver(
      MediaKind.video,
      RtpTransceiverInit(TransceiverDirection.sendRecv),
    );

    var offer = await pc1.createOffer();
    await pc1.setLocalDescription(offer);
    await pc2.setRemoteDescription(offer);

    await pc1.close();
    await pc2.close();
    await t1.dispose();
    await t2.dispose();
  });

  testWidgets('Peer connection get stats.', (WidgetTester tester) async {
    var pc1 = await PeerConnection.create(IceTransportType.all, []);
    var pc2 = await PeerConnection.create(IceTransportType.all, []);

    pc1.onIceCandidate((candidate) async {
      if (!pc2.closed) {
        await pc2.addIceCandidate(candidate);
      }
    });

    pc2.onIceCandidate((candidate) async {
      if (!pc1.closed) {
        await pc1.addIceCandidate(candidate);
      }
    });
    var tVideo = await pc1.addTransceiver(
      MediaKind.video,
      RtpTransceiverInit(TransceiverDirection.sendRecv),
    );
    var tAudio = await pc1.addTransceiver(
      MediaKind.audio,
      RtpTransceiverInit(TransceiverDirection.sendRecv),
    );

    var offer = await pc1.createOffer();
    await pc1.setLocalDescription(offer);
    await pc2.setRemoteDescription(offer);

    var answer = await pc2.createAnswer();
    await pc2.setLocalDescription(answer);
    await pc1.setRemoteDescription(answer);

    var senderStats = await pc1.getStats();
    var receiverStats = await pc2.getStats();

    expect(
      senderStats.where((e) => e.type is RtcOutboundRtpStreamStats).length,
      2,
    );
    expect(senderStats.where((e) => e.type is RtcTransportStats).length, 1);

    expect(
      receiverStats.where((e) => e.type is RtcInboundRtpStreamStats).length,
      2,
    );
    expect(receiverStats.where((e) => e.type is RtcTransportStats).length, 1);

    await pc1.close();
    await pc2.close();
    await tVideo.dispose();
    await tAudio.dispose();
  });

  testWidgets('Audio processing in get user media', (
    WidgetTester tester,
  ) async {
    if (Platform.isAndroid || Platform.isIOS) {
      // Only supported on desktop.

      var capsAudioOnly = DeviceConstraints();
      capsAudioOnly.audio.mandatory = AudioConstraints();

      var track = (await getUserMedia(capsAudioOnly))[0];
      expect(track.isAudioProcessingAvailable(), isFalse);
      try {
        await track.setNoiseSuppressionEnabled(true);
        fail("exception not thrown");
      } catch (e) {
        expect(e, isInstanceOf<UnsupportedError>());
      }
      try {
        await track.isNoiseSuppressionEnabled();
        fail("exception not thrown");
      } catch (e) {
        expect(e, isInstanceOf<UnsupportedError>());
      }

      await track.stop();

      return;
    }

    {
      // Does not work for video tracks
      var capsVideoOnly = DeviceConstraints();
      capsVideoOnly.video.mandatory = DeviceVideoConstraints();

      var track = (await getUserMedia(capsVideoOnly))[0];
      expect(track.isAudioProcessingAvailable(), isFalse);
      expect(track.setNoiseSuppressionEnabled(true), throwsUnsupportedError);
      expect(track.isNoiseSuppressionEnabled(), throwsUnsupportedError);

      await track.stop();
    }

    {
      // Everything is enabled by default
      var capsAudioOnly = DeviceConstraints();
      capsAudioOnly.audio.mandatory = AudioConstraints();

      var track = (await getUserMedia(capsAudioOnly))[0];
      expect(track.isAudioProcessingAvailable(), isTrue);

      expect(await track.isNoiseSuppressionEnabled(), isTrue);
      expect(await track.isHighPassFilterEnabled(), isTrue);
      expect(await track.isEchoCancellationEnabled(), isTrue);
      expect(await track.isAutoGainControlEnabled(), isTrue);
      expect(
        (await track.getNoiseSuppressionLevel()).index,
        equals(NoiseSuppressionLevel.veryHigh.index),
      );

      await track.stop();
    }

    {
      // Disable via gum
      var capsAudioOnly = DeviceConstraints();
      capsAudioOnly.audio.mandatory = AudioConstraints();
      capsAudioOnly.audio.mandatory!.noiseSuppression = false;
      capsAudioOnly.audio.mandatory!.highPassFilter = false;
      capsAudioOnly.audio.mandatory!.echoCancellation = false;
      capsAudioOnly.audio.mandatory!.autoGainControl = false;
      capsAudioOnly.audio.mandatory!.noiseSuppressionLevel =
          NoiseSuppressionLevel.low;

      var track = (await getUserMedia(capsAudioOnly))[0];

      expect(await track.isNoiseSuppressionEnabled(), isFalse);
      expect(await track.isHighPassFilterEnabled(), isFalse);
      expect(await track.isEchoCancellationEnabled(), isFalse);
      expect(await track.isAutoGainControlEnabled(), isFalse);
      expect(
        (await track.getNoiseSuppressionLevel()).index,
        equals(NoiseSuppressionLevel.low.index),
      );

      await track.stop();
    }

    {
      // Disable in runtime
      var capsAudioOnly = DeviceConstraints();
      capsAudioOnly.audio.mandatory = AudioConstraints();

      var track = (await getUserMedia(capsAudioOnly))[0];

      await track.setNoiseSuppressionEnabled(false);
      await track.setHighPassFilterEnabled(false);
      await track.setEchoCancellationEnabled(false);
      await track.setAutoGainControlEnabled(false);
      await track.setNoiseSuppressionLevel(NoiseSuppressionLevel.low);

      expect(await track.isNoiseSuppressionEnabled(), isFalse);
      expect(await track.isHighPassFilterEnabled(), isFalse);
      expect(await track.isEchoCancellationEnabled(), isFalse);
      expect(await track.isAutoGainControlEnabled(), isFalse);
      expect(
        (await track.getNoiseSuppressionLevel()).index,
        equals(NoiseSuppressionLevel.low.index),
      );

      await track.stop();
    }

    {
      // Enable in runtime
      var capsAudioOnly = DeviceConstraints();
      capsAudioOnly.audio.mandatory = AudioConstraints();
      capsAudioOnly.audio.mandatory!.noiseSuppression = false;
      capsAudioOnly.audio.mandatory!.highPassFilter = false;
      capsAudioOnly.audio.mandatory!.echoCancellation = false;
      capsAudioOnly.audio.mandatory!.autoGainControl = false;
      capsAudioOnly.audio.mandatory!.noiseSuppressionLevel =
          NoiseSuppressionLevel.low;

      var track = (await getUserMedia(capsAudioOnly))[0];

      await track.setNoiseSuppressionEnabled(true);
      await track.setHighPassFilterEnabled(true);
      await track.setEchoCancellationEnabled(true);
      await track.setAutoGainControlEnabled(true);
      await track.setNoiseSuppressionLevel(NoiseSuppressionLevel.veryHigh);

      expect(await track.isNoiseSuppressionEnabled(), isTrue);
      expect(await track.isHighPassFilterEnabled(), isTrue);
      expect(await track.isEchoCancellationEnabled(), isTrue);
      expect(await track.isAutoGainControlEnabled(), isTrue);
      expect(
        (await track.getNoiseSuppressionLevel()).index,
        equals(NoiseSuppressionLevel.veryHigh.index),
      );

      await track.stop();
    }
  });
}
