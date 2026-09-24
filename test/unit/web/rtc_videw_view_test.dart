@TestOn('browser')
library;

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_webrtc/src/web/rtc_video_renderer_impl.dart';
import 'package:flutter_webrtc/src/web/rtc_video_view_impl.dart';
import 'package:webrtc_interface/webrtc_interface.dart';
import 'package:web/web.dart' as web;

class TrackingRenderer extends RTCVideoRenderer {
  bool get observed => hasListeners;
}

class CaptureView extends RTCVideoView {
  CaptureView(super.renderer, {super.key});

  @override
  RTCVideoViewState createState() => CaptureState();
}

class CaptureState extends RTCVideoViewState {
  Completer<ui.Image> pending = Completer<ui.Image>();

  @override
  Future<ui.Image> captureImage(web.HTMLVideoElement element) => pending.future;
}

void main() {
  testWidgets('late texture image is released after unmount', (tester) async {
    if (useHtmlElementView) return;
    final renderer = TrackingRenderer();
    await renderer.initialize();
    final key = GlobalKey<CaptureState>();
    await tester.pumpWidget(MaterialApp(home: CaptureView(renderer, key: key)));
    final state = key.currentState!;
    final pendingCapture = state.captureFrame();
    await tester.pumpWidget(const SizedBox());
    expect(renderer.observed, isFalse);

    final recorder = ui.PictureRecorder();

    final canvas = ui.Canvas(recorder);
    canvas.drawColor(const Color(0xff000000), ui.BlendMode.src);
    final picture = recorder.endRecording();

    final image = await tester.runAsync(() => picture.toImage(1, 1));

    picture.dispose();
    state.pending.complete(image!);
    await pendingCapture;
    expect(image.debugDisposed, isTrue);
    await renderer.dispose();
  });

  testWidgets('failed frame capture can recover on the next frame',
      (tester) async {
    if (useHtmlElementView) return;
    final renderer = RTCVideoRenderer();
    await renderer.initialize();
    final key = GlobalKey<CaptureState>();
    await tester.pumpWidget(MaterialApp(home: CaptureView(renderer, key: key)));
    final state = key.currentState!;
    final failed = state.captureFrame();
    state.pending.completeError(Exception('temporary capture failure'));
    expect(await failed, isFalse);
    state.pending = Completer<ui.Image>();
    final recovered = state.captureFrame();
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder).drawColor(const Color(0xff000000), ui.BlendMode.src);
    final picture = recorder.endRecording();
    final image = await tester.runAsync(() => picture.toImage(1, 1));
    picture.dispose();
    state.pending.complete(image!);
    expect(await recovered, isTrue);
    expect(state.capturedFrame, same(image));
    await tester.pumpWidget(const SizedBox());
    expect(image.debugDisposed, isTrue);
    await renderer.dispose();
  });

  testWidgets('view transfers listeners and capture ownership on replacement',
      (tester) async {
    final first = TrackingRenderer();
    final second = TrackingRenderer();
    await first.initialize();
    await second.initialize();
    final key = GlobalKey<RTCVideoViewState>();
    Widget view(RTCVideoRenderer renderer) => MaterialApp(
          home: RTCVideoView(renderer,
              key: key,
              mirror: true,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
        );

    await tester.pumpWidget(view(first));
    expect(first.observed, isTrue);
    if (useHtmlElementView) {
      expect(key.currentState!.videoElement, isNull);
      expect(key.currentState!.callbackID, isNull);
    } else {
      expect(key.currentState!.videoElement, same(first.findHtmlView()));
    }
    await tester.pumpWidget(view(second));
    expect(first.observed, isFalse);
    expect(second.observed, isTrue);
    if (!useHtmlElementView) {
      expect(key.currentState!.videoElement, same(second.findHtmlView()));
    }
    expect(second.mirror, isTrue);
    await tester.pumpWidget(const SizedBox());
    expect(second.observed, isFalse);
    await first.dispose();
    await second.dispose();
  });

  // TODO(wer-mathurin): should revisit after this bug is resolved, https://github.com/flutter/flutter/issues/66045.
  test('should complete succesfully', () async {
    var renderer = RTCVideoRenderer();
    await renderer.initialize();
    await renderer.dispose();
  });
}
