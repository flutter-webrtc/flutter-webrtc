import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Add transceiver', (WidgetTester tester) async {
    var pc = await PeerConnection.create(IceTransportType.all, []);
    var trans = await pc.addTransceiver(
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));

    expect(trans.mid, isNull);

    var response = await pc.createOffer();

    expect(response.description.contains('m=video'), isTrue);
    expect(response.description.contains('sendrecv'), isTrue);
  });

  testWidgets('Get transceivers', (WidgetTester tester) async {
    var pc = await PeerConnection.create(IceTransportType.all, []);
    await pc.addTransceiver(
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));
    await pc.addTransceiver(
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));

    var before = await pc.getTransceivers();

    expect(before[0].mid, isNull);
    expect(before[1].mid, isNull);

    var offer = await pc.createOffer();
    await pc.setLocalDescription(offer);

    var after = await pc.getTransceivers();

    expect(after[0].mid, equals('0'));
    expect(after[1].mid, equals('1'));
    expect(before[0].mid, equals('0'));
    expect(before[1].mid, equals('1'));
  });

  testWidgets('Get transceiver direction', (WidgetTester tester) async {
    var pc = await PeerConnection.create(IceTransportType.all, []);
    var trans = await pc.addTransceiver(
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));

    var direction = await trans.getDirection();
    expect(direction, equals(TransceiverDirection.sendRecv));
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
  });

  testWidgets('Get transceiver mid', (WidgetTester tester) async {
    var pc = await PeerConnection.create(IceTransportType.all, []);
    var trans = await pc.addTransceiver(
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));

    expect(trans.mid, isNull);

    var sess = await pc.createOffer();
    await pc.setLocalDescription(sess);

    expect(trans.mid, equals('0'));
  });

  testWidgets('Add Ice Candidate', (WidgetTester tester) async {
    var pc1 = await PeerConnection.create(IceTransportType.all, []);
    var pc2 = await PeerConnection.create(IceTransportType.all, []);

    pc1.onIceCandidate((candidate) async {
      await pc2.addIceCandidate(candidate);
    });

    pc2.onIceCandidate((candidate) async {
      await pc1.addIceCandidate(candidate);
    });
    await pc1.addTransceiver(
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));

    var offer = await pc1.createOffer();
    await pc1.setLocalDescription(offer);
    await pc2.setRemoteDescription(offer);

    var answer = await pc2.createAnswer();
    await pc2.setLocalDescription(answer);
    await pc1.setRemoteDescription(answer);
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

    await pc1.addTransceiver(
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));

    var offer = await pc1.createOffer();
    await pc1.setLocalDescription(offer);
    await pc2.setRemoteDescription(offer);

    var answer = await pc2.createAnswer();
    await pc2.setLocalDescription(answer);
    await pc1.setRemoteDescription(answer);

    pc1.onIceCandidate((candidate) async {
      await pc2.addIceCandidate(candidate);
    });

    pc2.onIceCandidate((candidate) async {
      await pc1.addIceCandidate(candidate);
    });

    expect(await rx.moveNext(), isTrue);
    expect(rx.current, equals(1));

    await pc1.restartIce();

    expect(await rx.moveNext(), isTrue);
    expect(rx.current, equals(2));
  });

  testWidgets('Ice state PeerConnection', (WidgetTester tester) async {
    var pc1 = await PeerConnection.create(IceTransportType.all, []);
    var pc2 = await PeerConnection.create(IceTransportType.all, []);

    var tx = StreamController<PeerConnectionState>();
    var rx = StreamIterator(tx.stream);

    pc1.onConnectionStateChange((state) {
      tx.add(state);
    });

    await pc1.addTransceiver(
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));

    var offer = await pc1.createOffer();
    await pc1.setLocalDescription(offer);
    await pc2.setRemoteDescription(offer);

    var answer = await pc2.createAnswer();
    await pc2.setLocalDescription(answer);
    await pc1.setRemoteDescription(answer);

    pc1.onIceCandidate((candidate) async {
      await pc2.addIceCandidate(candidate);
    });
    pc2.onIceCandidate((candidate) async {
      await pc1.addIceCandidate(candidate);
    });

    expect(await rx.moveNext(), isTrue);
    expect(rx.current, equals(PeerConnectionState.connecting));

    expect(await rx.moveNext(), isTrue);
    expect(rx.current, equals(PeerConnectionState.connected));

    await pc1.close();

    expect(await rx.moveNext(), isTrue);
    expect(rx.current, equals(PeerConnectionState.closed));
  });

  testWidgets('Peer connection event on track', (WidgetTester tester) async {
    var pc1 = await PeerConnection.create(IceTransportType.all, []);
    await pc1.addTransceiver(
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));

    var pc2 = await PeerConnection.create(IceTransportType.all, []);
    final completer = Completer<void>();
    pc2.onTrack((track, transceiver) {
      completer.complete();
    });
    await pc2.setRemoteDescription(await pc1.createOffer());
    await completer.future.timeout(const Duration(seconds: 1));
  });

  testWidgets('Track Onended', (WidgetTester tester) async {
    var pc1 = await PeerConnection.create(IceTransportType.all, []);
    await pc1.addTransceiver(
        MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));

    var pc2 = await PeerConnection.create(IceTransportType.all, []);
    final completer = Completer<void>();
    pc2.onTrack((track, transceiver) {
      track.onEnded(() {
        completer.complete();
      });
    });

    await pc2.setRemoteDescription(await pc1.createOffer());
    await (await pc2.getTransceivers())[0].stop();
    await completer.future.timeout(const Duration(seconds: 3));
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
      await pc2.addIceCandidate(candidate);
    });

    pc2.onIceCandidate((IceCandidate candidate) async {
      await pc1.addIceCandidate(candidate);
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
    });

    pc1.onIceCandidate((IceCandidate candidate) async {
      await pc2.addIceCandidate(candidate);

      if (!futures[4].isCompleted) {
        futures[4].complete();
      }
    });

    pc2.onIceCandidate((IceCandidate candidate) async {
      await pc1.addIceCandidate(candidate);

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
      track.onEnded(() {
        onEndedComplete.complete();
      });
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

    await (await pc2.getTransceivers())[0].stop();

    await onEndedComplete.future;
    expect(videoTrack.id(), isNot(equals(cloneVideoTrack.id())));
    expect(videoTrack.isEnabled(), isNot(equals(cloneVideoTrack.isEnabled())));
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

      await pc1.addTransceiver(
          MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));
      await pc1.addTransceiver(
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

      await pc1.addTransceiver(
          MediaKind.video, RtpTransceiverInit(TransceiverDirection.sendRecv));
      await pc1.addTransceiver(
          MediaKind.audio, RtpTransceiverInit(TransceiverDirection.sendRecv));

      var offer = await pc1.createOffer();
      await pc1.setLocalDescription(offer);
      await pc2.setRemoteDescription(offer);

      var answer = await pc2.createAnswer();
      await pc2.setLocalDescription(answer);
      await pc1.setRemoteDescription(answer);

      await Future.delayed(const Duration(seconds: 5));

      expect(candidatesFired, equals(0));
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
    };

    // ignore: prefer_function_declarations_over_variables
    var testDisableRecv = (beforeDirection, afterDirection) async {
      var transceiver = await pc.addTransceiver(
          MediaKind.video, RtpTransceiverInit(beforeDirection));
      await transceiver.setRecv(false);
      expect(await transceiver.getDirection(), afterDirection);
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
  });

  testWidgets('Set send direction', (WidgetTester tester) async {
    var pc = await PeerConnection.create(IceTransportType.all, []);
    // ignore: prefer_function_declarations_over_variables
    var testEnableRecv = (beforeDirection, afterDirection) async {
      var transceiver = await pc.addTransceiver(
          MediaKind.video, RtpTransceiverInit(beforeDirection));
      await transceiver.setSend(true);
      expect(await transceiver.getDirection(), afterDirection);
    };

    // ignore: prefer_function_declarations_over_variables
    var testDisableRecv = (beforeDirection, afterDirection) async {
      var transceiver = await pc.addTransceiver(
          MediaKind.video, RtpTransceiverInit(beforeDirection));
      await transceiver.setSend(false);
      expect(await transceiver.getDirection(), afterDirection);
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
  });
}
