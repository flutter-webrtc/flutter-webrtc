@TestOn('browser')
library;

import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/src/web/rtc_video_view_impl.dart';

void main() {
  test('texture painter invalidates only when its rendering inputs change',
      () async {
    Future<ui.Image> makeImage() async {
      final recorder = ui.PictureRecorder();
      ui.Canvas(recorder)
          .drawColor(const ui.Color(0xff000000), ui.BlendMode.src);
      final picture = recorder.endRecording();
      final image = await picture.toImage(1, 1);
      picture.dispose();
      return image;
    }

    final first = await makeImage();
    final next = await makeImage();
    final painter = VideoFramePainter(first, false, ui.FilterQuality.low);
    expect(
        VideoFramePainter(first, false, ui.FilterQuality.low)
            .shouldRepaint(painter),
        isFalse);
    expect(
        VideoFramePainter(next, false, ui.FilterQuality.low)
            .shouldRepaint(painter),
        isTrue);
    expect(
        VideoFramePainter(first, true, ui.FilterQuality.low)
            .shouldRepaint(painter),
        isTrue);
    expect(
        VideoFramePainter(first, false, ui.FilterQuality.high)
            .shouldRepaint(painter),
        isTrue);
    first.dispose();
    next.dispose();
  });
}
