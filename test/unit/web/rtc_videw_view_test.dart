@TestOn('browser')
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' hide RTCVideoRenderer;
import 'package:flutter_webrtc/src/web/rtc_video_renderer_impl.dart';

void main() {
  // TODO(wer-mathurin): should revisit after this bug is resolved, https://github.com/flutter/flutter/issues/66045.
  test('should complete succesfully', () async {
    var renderer = RTCVideoRenderer();
    await renderer.initialize();
    renderer.srcObject = await navigator.getUserMedia({});
    await renderer.dispose();
  });
}
