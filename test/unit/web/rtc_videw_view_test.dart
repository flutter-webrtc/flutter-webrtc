@TestOn('browser')
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'package:flutter_webrtc/src/web/rtc_video_renderer_impl.dart'
    as web_renderer;

void main() {
  test('video is an autoplaying, non-interactive render surface', () {
    final renderer = web_renderer.RTCVideoRenderer();
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
    if (web_renderer.useHtmlElementView) {
      expect(video.style.userSelect, 'none');
    }
    renderer.dispose();
  });

  test('renderer initializes and disposes without a media stream', () async {
    final renderer = RTCVideoRenderer();
    await renderer.initialize();
    await renderer.dispose();
  });
}
