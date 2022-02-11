import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Add transceiver', (WidgetTester tester) async {
    var pc = await createPeerConnection({});
    var init = RTCRtpTransceiverInit();
    init.direction = TransceiverDirection.SendRecv;

    var trans = await pc.addTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeVideo, init: init);

    expect(trans.mid.isEmpty, isTrue);

    var response = await pc.createOffer();

    expect(response.sdp!.contains('m=video'), isTrue);
    expect(response.sdp!.contains('sendrecv'), isTrue);
  });

  testWidgets('Get transceivers', (WidgetTester tester) async {
    var pc = await createPeerConnection({});
    var init = RTCRtpTransceiverInit();
    init.direction = TransceiverDirection.SendRecv;

    await pc.addTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeVideo, init: init);
    await pc.addTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeAudio, init: init);

    var before = await pc.getTransceivers();

    expect(before[0].mid.isEmpty, isTrue);
    expect(before[1].mid.isEmpty, isTrue);

    var offer = await pc.createOffer();
    await pc.setLocalDescription(offer);

    var after = await pc.getTransceivers();

    expect(after[0].mid, equals('0'));
    expect(after[1].mid, equals('1'));
  });
}
