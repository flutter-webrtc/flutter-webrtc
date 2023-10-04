import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter_test/flutter_test.dart';
import 'package:medea_flutter_webrtc/medea_flutter_webrtc.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await enableFakeMedia();
  });

  testWidgets('Add transceiver', (WidgetTester tester) async {
    var pc = await PeerConnection.create(IceTransportType.all, []);
    var trans = await pc.addTransceiver(
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));

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

    var p1 = SendEncodingParameters("h", true);
    p1.maxBitrate = 1200 * 1024;
    p1.maxFramerate = 30;
    videoInit1.sendEncodings.add(p1);

    var p2 = SendEncodingParameters("m", true);
    p2.maxBitrate = 600 * 1024;
    p2.maxFramerate = 30;
    p2.scaleResolutionDownBy = 2;
    videoInit1.sendEncodings.add(p2);

    var p3 = SendEncodingParameters("l", true);
    p3.maxBitrate = 300 * 1024;
    p3.scaleResolutionDownBy = 4;
    videoInit1.sendEncodings.add(p3);

    var videoTrans1 = await pc.addTransceiver(MediaKind.video, videoInit1);
    var response = await pc.createOffer();

    expect(response.description.contains('a=mid:0'), isTrue);
    expect(response.description.contains('m=video'), isTrue);
    expect(response.description.contains('sendonly'), isTrue);
    expect(response.description.contains('a=rid:h send'), isTrue);
    expect(response.description.contains('a=rid:m send'), isTrue);
    expect(response.description.contains('a=rid:l send'), isTrue);
    expect(response.description.contains('a=simulcast:send h;m;l'), isTrue);

    await pc.close();
    await videoTrans1.dispose();
  });

  testWidgets('Get transceivers', (WidgetTester tester) async {
    var pc = await PeerConnection.create(IceTransportType.all, []);
    var t1 = await pc.addTransceiver(
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));
    var t2 = await pc.addTransceiver(
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));

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
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));

    var direction = await trans.getDirection();
    expect(direction, equals(TransceiverDirection.sendRecv));

    await pc.close();
    await trans.dispose();
  });

  testWidgets('Set transceiver direction', (WidgetTester tester) async {
    var pc = await PeerConnection.create(IceTransportType.all, []);
    var trans = await pc.addTransceiver(
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));

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
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));

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
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));

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
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));

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
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));

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
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));

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
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));

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
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));

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

  testWidgets('Track Onended not working after stop()',
      (WidgetTester tester) async {
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
        MediaKind.audio, RtpTransceiverInit(TransceiverDirection.sendOnly));

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

    var videoTrack =
        tracks.firstWhere((track) => track.kind() == MediaKind.video);
    var audioTrack =
        tracks.firstWhere((track) => track.kind() == MediaKind.audio);

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
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendOnly));
    var audioTransceiver = await pc1.addTransceiver(
        MediaKind.audio, RtpTransceiverInit(TransceiverDirection.sendOnly));

    videoTransceiver.sender.replaceTrack(videoTrack);
    audioTransceiver.sender.replaceTrack(audioTrack);

    var offer = await pc1.createOffer();
    await pc1.setLocalDescription(offer);
    await pc2.setRemoteDescription(offer);

    var answer = await pc2.createAnswer();
    await pc2.setLocalDescription(answer);
    await pc1.setRemoteDescription(answer);

    await Future.wait(futures.map((e) => e.future))
        .timeout(const Duration(seconds: 5));

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
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendOnly));
    var t2 = await pc1.addTransceiver(
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendOnly));

    var tracks = await getUserMedia(caps);

    var videoTrack =
        tracks.firstWhere((track) => track.kind() == MediaKind.video);
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
    bool hasVideo =
        tracksAudioOnly.any((track) => track.kind() == MediaKind.video);
    bool hasAudio =
        tracksAudioOnly.any((track) => track.kind() == MediaKind.audio);
    expect(hasVideo, isFalse);
    expect(hasAudio, isTrue);

    var tracksVideoDeviceOnly = await getUserMedia(capsVideoDeviceOnly);
    hasVideo =
        tracksVideoDeviceOnly.any((track) => track.kind() == MediaKind.video);
    hasAudio =
        tracksVideoDeviceOnly.any((track) => track.kind() == MediaKind.audio);
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
      var server =
          IceServer(['stun:stun.l.google.com:19302'], 'username', 'password');
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
          MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));
      var t2 = await pc1.addTransceiver(
          MediaKind.audio, RtpTransceiverInit(TransceiverDirection.sendRecv));

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
          MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));
      var t2 = await pc1.addTransceiver(
          MediaKind.audio, RtpTransceiverInit(TransceiverDirection.sendRecv));

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
          MediaKind.video, RtpTransceiverInit(beforeDirection));
      await transceiver.setRecv(true);
      expect(await transceiver.getDirection(), afterDirection);

      await transceiver.dispose();
    };

    // ignore: prefer_function_declarations_over_variables
    var testDisableRecv = (beforeDirection, afterDirection) async {
      var transceiver = await pc.addTransceiver(
          MediaKind.video, RtpTransceiverInit(beforeDirection));
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

    for (var value = testEnable.removeAt(0);
        testEnable.isNotEmpty;
        value = testEnable.removeAt(0)) {
      await testEnableRecv(value[0], value[1]);
    }

    for (var value = testDisable.removeAt(0);
        testDisable.isNotEmpty;
        value = testDisable.removeAt(0)) {
      await testDisableRecv(value[0], value[1]);
    }

    await pc.close();
  });

  testWidgets('Set send direction', (WidgetTester tester) async {
    var pc = await PeerConnection.create(IceTransportType.all, []);
    // ignore: prefer_function_declarations_over_variables
    var testEnableRecv = (beforeDirection, afterDirection) async {
      var transceiver = await pc.addTransceiver(
          MediaKind.video, RtpTransceiverInit(beforeDirection));
      await transceiver.setSend(true);
      expect(await transceiver.getDirection(), afterDirection);

      await transceiver.dispose();
    };

    // ignore: prefer_function_declarations_over_variables
    var testDisableRecv = (beforeDirection, afterDirection) async {
      var transceiver = await pc.addTransceiver(
          MediaKind.video, RtpTransceiverInit(beforeDirection));
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

    for (var value = testEnable.removeAt(0);
        testEnable.isNotEmpty;
        value = testEnable.removeAt(0)) {
      await testEnableRecv(value[0], value[1]);
    }

    for (var value = testDisable.removeAt(0);
        testDisable.isNotEmpty;
        value = testDisable.removeAt(0)) {
      await testDisableRecv(value[0], value[1]);
    }

    await pc.close();
  });

  testWidgets('Handles still work after Peer close',
      (WidgetTester tester) async {
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
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendOnly));

    var atrans = await pc1.addTransceiver(
        MediaKind.audio, RtpTransceiverInit(TransceiverDirection.sendOnly));

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
        tracks.firstWhere((track) => track.kind() == MediaKind.video));

    await atrans.sender.replaceTrack(
        tracks.firstWhere((track) => track.kind() == MediaKind.audio));

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

  testWidgets('on_track when peer has transceiver.',
      (WidgetTester tester) async {
    var pc1 = await PeerConnection.create(IceTransportType.all, []);
    var pc2 = await PeerConnection.create(IceTransportType.all, []);

    var t1 = await pc1.addTransceiver(
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));
    var t2 = await pc2.addTransceiver(
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));

    var offer = await pc1.createOffer();
    await pc1.setLocalDescription(offer);
    await pc2.setRemoteDescription(offer);

    await pc1.close();
    await pc2.close();
    await t1.dispose();
    await t2.dispose();
  });

  testWidgets('Peer connection get stats.', (WidgetTester tester) async {
    // TODO: Support stats for iOS platform.
    if (Platform.isIOS) {
      return;
    }
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
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));
    var tAudio = await pc1.addTransceiver(
        MediaKind.audio, RtpTransceiverInit(TransceiverDirection.sendRecv));

    var offer = await pc1.createOffer();
    await pc1.setLocalDescription(offer);
    await pc2.setRemoteDescription(offer);

    var answer = await pc2.createAnswer();
    await pc2.setLocalDescription(answer);
    await pc1.setRemoteDescription(answer);

    var senderStats = await pc1.getStats();
    var receiverStats = await pc2.getStats();

    expect(senderStats.where((e) => e.type is RtcOutboundRtpStreamStats).length,
        2);
    expect(senderStats.where((e) => e.type is RtcTransportStats).length, 1);

    expect(
        receiverStats.where((e) => e.type is RtcInboundRtpStreamStats).length,
        2);
    expect(receiverStats.where((e) => e.type is RtcTransportStats).length, 1);

    await pc1.close();
    await pc2.close();
    await tVideo.dispose();
    await tAudio.dispose();
  });
}
