@TestOn('browser')
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc/src/web/rtc_video_renderer_impl.dart'
    show useHtmlElementView;

void main() {
  test('video is an autoplaying, non-interactive render surface', () {
    final renderer = RTCVideoRenderer();
    final video = renderer.createElement();
    expect(video.autoplay, isTrue);
    expect(video.controls, isFalse);
    expect(video.hasAttribute('playsinline'), isTrue);
    expect(video.style.pointerEvents, 'none');
    expect(video.hasAttribute('disablepictureinpicture'), isTrue);
    expect(video.hasAttribute('disableremoteplayback'), isTrue);
    expect(
      video.getAttribute('controlsList'),
      'nodownload nofullscreen noremoteplayback',
    );
    if (useHtmlElementView) {
      expect(video.style.userSelect, 'none');
    }
    renderer.dispose();
  });

  // TODO(wer-mathurin): should revisit after this bug is resolved, https://github.com/flutter/flutter/issues/66045.
  test('should complete succesfully', () async {
    var renderer = RTCVideoRenderer();
    await renderer.initialize();
    renderer.srcObject = await MediaDevices.getUserMedia({});
    await renderer.dispose();
  });
}
