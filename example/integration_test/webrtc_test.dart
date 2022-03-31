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
}
