// Native regression check: run with the Windows or Linux example runner.
// See Documentation/desktop-peerconnection-disposal.md for instructions.
import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

// Remote audio without an MSID exercises the native OnAddStream/OnRemoveStream
// path. No answer is created, so ICE gathering and media transport never start.
const _remoteOffer = 'v=0\r\n'
    'o=- 1 1 IN IP4 127.0.0.1\r\n'
    's=-\r\n'
    't=0 0\r\n'
    'a=group:BUNDLE 0\r\n'
    'm=audio 9 UDP/TLS/RTP/SAVPF 111\r\n'
    'c=IN IP4 0.0.0.0\r\n'
    'a=ice-ufrag:test\r\n'
    'a=ice-pwd:012345678901234567890123\r\n'
    'a=fingerprint:sha-256 '
    '00:01:02:03:04:05:06:07:08:09:0A:0B:0C:0D:0E:0F:'
    '10:11:12:13:14:15:16:17:18:19:1A:1B:1C:1D:1E:1F\r\n'
    'a=setup:actpass\r\n'
    'a=mid:0\r\n'
    'a=sendonly\r\n'
    'a=rtcp-mux\r\n'
    'a=rtpmap:111 opus/48000/2\r\n';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SizedBox.shrink());
  final watchdog = Timer(const Duration(seconds: 60), () {
    stderr.writeln('FAIL: native PeerConnection disposal timed out');
    exit(1);
  });

  try {
    if (!Platform.isLinux && !Platform.isWindows) {
      throw StateError('This regression check requires Linux or Windows');
    }
    for (var iteration = 1; iteration <= 10; iteration++) {
      final connection = await createPeerConnection({
        'iceServers': <Map<String, dynamic>>[],
        'sdpSemantics': 'unified-plan',
      });
      final remoteStreamAdded = Completer<void>();
      connection.onAddStream = (stream) {
        if (stream.getAudioTracks().isNotEmpty &&
            !remoteStreamAdded.isCompleted) {
          remoteStreamAdded.complete();
        }
      };
      await connection.setRemoteDescription(
        RTCSessionDescription(_remoteOffer, 'offer'),
      );
      await remoteStreamAdded.future.timeout(const Duration(seconds: 5));

      // Cancel the Dart subscription first. The native observer must survive
      // all Close() callbacks even though it is disposed before Dart close().
      stdout.writeln('Disposing PeerConnection $iteration with remote audio');
      await connection.dispose();
      await connection.close();
    }
    stdout.writeln('PASS: 10 native PeerConnections disposed with remote audio');
    watchdog.cancel();
    exit(0);
  } catch (error, stackTrace) {
    stderr.writeln('FAIL: $error\n$stackTrace');
    watchdog.cancel();
    exit(1);
  }
}
