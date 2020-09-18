@TestOn('browser')
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/src/web/media_devices_web.dart';
import 'package:flutter_webrtc/src/web/rtc_video_view.dart';

void main() {
  // TODO(wer-mathurin): should revisit after this bug is resolved, https://github.com/flutter/flutter/issues/66045.
  test('should complete succesfully', () async {
    var renderer = RTCVideoRendererWeb();
    await renderer.initialize();
    renderer.srcObject = await MediaDevicesWeb().getUserMedia({});
    await renderer.dispose();
  });
}
