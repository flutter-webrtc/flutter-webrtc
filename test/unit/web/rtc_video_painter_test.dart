@TestOn('browser')
library;

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:webrtc_interface/webrtc_interface.dart';

import 'package:flutter_webrtc/src/web/rtc_video_view_impl.dart';

Future<ui.Image> sourceImage() async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  canvas.drawRect(
    const ui.Rect.fromLTWH(0, 0, 1, 1),
    ui.Paint()..color = const ui.Color(0xffff0000),
  );
  canvas.drawRect(
    const ui.Rect.fromLTWH(1, 0, 1, 1),
    ui.Paint()..color = const ui.Color(0xff0000ff),
  );
  final picture = recorder.endRecording();
  final image = await picture.toImage(2, 1);
  picture.dispose();
  return image;
}

Future<Uint8List> paintPixels(VideoFramePainter painter) async {
  final recorder = ui.PictureRecorder();
  painter.paint(ui.Canvas(recorder), const ui.Size(2, 1));
  final picture = recorder.endRecording();
  final image = await picture.toImage(2, 1);
  picture.dispose();
  final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  image.dispose();
  return data!.buffer.asUint8List();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('contain and cover center the scaled frame directly', () {
    expect(
      VideoFramePainter.destinationRect(
        const ui.Size(4, 2),
        const ui.Size(4, 4),
        RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
      ),
      const ui.Rect.fromLTWH(0, 1, 4, 2),
    );
    expect(
      VideoFramePainter.destinationRect(
        const ui.Size(4, 2),
        const ui.Size(4, 4),
        RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
      ),
      const ui.Rect.fromLTWH(-2, 0, 8, 4),
    );
  });

  test('mirror flips the painted pixels horizontally', () async {
    final metrics = VideoFrameMetrics();
    final state = VideoFrameState(metrics);
    state.replace(await sourceImage());
    final normal = VideoFramePainter(
      state,
      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
      mirror: false,
      filterQuality: ui.FilterQuality.none,
    );
    final mirrored = VideoFramePainter(
      state,
      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
      mirror: true,
      filterQuality: ui.FilterQuality.none,
    );

    final normalPixels = await paintPixels(normal);
    final mirroredPixels = await paintPixels(mirrored);
    expect(normalPixels.sublist(0, 4), [255, 0, 0, 255]);
    expect(mirroredPixels.sublist(0, 4), [0, 0, 255, 255]);
    state.dispose();
  });

  test('painter invalidates only for structural painting changes', () async {
    final state = VideoFrameState(VideoFrameMetrics());
    final painter = VideoFramePainter(
      state,
      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
      mirror: false,
      filterQuality: ui.FilterQuality.low,
    );
    expect(
      VideoFramePainter(
        state,
        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
        mirror: false,
        filterQuality: ui.FilterQuality.low,
      ).shouldRepaint(painter),
      isFalse,
    );
    expect(
      VideoFramePainter(
        state,
        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
        mirror: false,
        filterQuality: ui.FilterQuality.low,
      ).shouldRepaint(painter),
      isTrue,
    );
    expect(
      VideoFramePainter(
        state,
        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
        mirror: true,
        filterQuality: ui.FilterQuality.low,
      ).shouldRepaint(painter),
      isTrue,
    );
    expect(
      VideoFramePainter(
        state,
        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
        mirror: false,
        filterQuality: ui.FilterQuality.high,
      ).shouldRepaint(painter),
      isTrue,
    );
    state.dispose();
  });
}
