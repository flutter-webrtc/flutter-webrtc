@TestOn('browser')
library;

import 'dart:async';
import 'dart:js_interop';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dart_webrtc/dart_webrtc.dart';
import 'package:web/web.dart' as web;

import 'package:flutter_webrtc/src/web/rtc_video_renderer_impl.dart';
import 'package:flutter_webrtc/src/web/rtc_video_view_impl.dart';

class TrackingRenderer extends RTCVideoRenderer {
  bool get observed => hasListeners;
}

class CaptureView extends RTCVideoView {
  CaptureView(super.renderer, {super.key});

  @override
  RTCVideoViewState createState() => CaptureState();
}

class CaptureState extends RTCVideoViewState {
  final pending = <Completer<ui.Image>>[];

  @override
  Future<ui.Image> captureImage(web.HTMLVideoElement element) {
    final completer = Completer<ui.Image>();
    pending.add(completer);
    return completer.future;
  }
}

MediaStreamWeb canvasStream() {
  final canvas = web.HTMLCanvasElement()
    ..width = 16
    ..height = 9;
  return MediaStreamWeb(canvas.captureStream(0), 'local');
}

Future<ui.Image> makeImage(WidgetTester tester,
    [int width = 2, int height = 1]) async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawColor(const Color(0xff000000), ui.BlendMode.src);
  final picture = recorder.endRecording();
  final image = await tester.runAsync(() => picture.toImage(width, height));
  picture.dispose();
  return image!;
}

Future<(TrackingRenderer, CaptureState)> pumpCaptureView(
  WidgetTester tester, {
  void Function()? onFirstFrame,
}) async {
  final renderer = TrackingRenderer();
  renderer.srcObject = canvasStream();
  renderer.onFirstFrameRendered = onFirstFrame;
  await renderer.initialize();
  final key = GlobalKey<CaptureState>();
  await tester.pumpWidget(MaterialApp(home: CaptureView(renderer, key: key)));
  return (renderer, key.currentState!);
}

void main() {
  testWidgets('frame delivery repaints without rebuilding the video widget',
      (tester) async {
    if (useHtmlElementView) return;
    final (renderer, state) = await pumpCaptureView(tester);
    final builds = state.frameMetrics.widgetBuilds;

    final capture = state.captureFrame();
    expect(state.pending, hasLength(1));
    state.pending.single.complete(await makeImage(tester));
    await capture;
    expect(state.frameMetrics.widgetBuilds, builds);
    expect(state.frameMetrics.paintInvalidations, 1);

    await tester.pump();
    expect(state.frameMetrics.widgetBuilds, builds);
    expect(state.frameMetrics.paintedFrames, greaterThan(0));
    await tester.pumpWidget(const SizedBox());
    await renderer.dispose();
  });

  testWidgets('frame imports never overlap and pending frames coalesce',
      (tester) async {
    if (useHtmlElementView) return;
    final (renderer, state) = await pumpCaptureView(tester);

    final firstCapture = state.captureFrame();
    await state.captureFrame();
    await state.captureFrame();
    expect(state.pending, hasLength(1));
    expect(state.frameMetrics.concurrentImports, 1);
    expect(state.frameMetrics.skippedFrames, 1);

    state.pending.first.complete(await makeImage(tester));
    await firstCapture;
    await tester.pump();
    expect(state.pending, hasLength(2));
    expect(state.frameMetrics.maxConcurrentImports, 1);

    state.pending.last.complete(await makeImage(tester));
    await tester.pump();
    expect(state.frameMetrics.importedFrames, 2);
    expect(state.frameMetrics.maxConcurrentImports, 1);
    await tester.pumpWidget(const SizedBox());
    await renderer.dispose();
  });

  testWidgets('source replacement rejects a stale imported image',
      (tester) async {
    if (useHtmlElementView) return;
    final (renderer, state) = await pumpCaptureView(tester);
    final capture = state.captureFrame();
    final stale = await makeImage(tester);

    renderer.srcObject = canvasStream();
    state.pending.single.complete(stale);
    await capture;

    expect(stale.debugDisposed, isTrue);
    expect(state.frameState.image, isNull);
    await tester.pumpWidget(const SizedBox());
    await renderer.dispose();
  });

  testWidgets('renderer replacement rejects the old renderer frame',
      (tester) async {
    if (useHtmlElementView) return;
    final first = TrackingRenderer()..srcObject = canvasStream();
    final second = TrackingRenderer()..srcObject = canvasStream();
    await first.initialize();
    await second.initialize();
    final key = GlobalKey<CaptureState>();
    await tester.pumpWidget(MaterialApp(home: CaptureView(first, key: key)));
    final state = key.currentState!;
    final capture = state.captureFrame();
    final stale = await makeImage(tester);

    await tester.pumpWidget(MaterialApp(home: CaptureView(second, key: key)));
    state.pending.single.complete(stale);
    await capture;

    expect(stale.debugDisposed, isTrue);
    expect(state.frameState.image, isNull);
    expect(first.observed, isFalse);
    expect(second.observed, isTrue);
    await tester.pumpWidget(const SizedBox());
    await first.dispose();
    await second.dispose();
  });

  testWidgets('late frame after disposal is released', (tester) async {
    if (useHtmlElementView) return;
    final (renderer, state) = await pumpCaptureView(tester);
    final capture = state.captureFrame();
    final late = await makeImage(tester);

    await tester.pumpWidget(const SizedBox());
    state.pending.single.complete(late);
    await capture;

    expect(late.debugDisposed, isTrue);
    expect(renderer.observed, isFalse);
    await renderer.dispose();
  });

  testWidgets('first-frame callback fires once for each source generation',
      (tester) async {
    if (useHtmlElementView) return;
    var firstFrames = 0;
    final (renderer, state) = await pumpCaptureView(
      tester,
      onFirstFrame: () => firstFrames++,
    );

    var capture = state.captureFrame();
    state.pending.last.complete(await makeImage(tester));
    await capture;
    expect(firstFrames, 0);
    await tester.pump();
    expect(firstFrames, 1);
    capture = state.captureFrame();
    state.pending.last.complete(await makeImage(tester));
    await capture;
    await tester.pump();
    expect(firstFrames, 1);

    renderer.srcObject = canvasStream();
    capture = state.captureFrame();
    state.pending.last.complete(await makeImage(tester));
    await capture;
    expect(firstFrames, 1);
    await tester.pump();
    expect(firstFrames, 2);
    await tester.pumpWidget(const SizedBox());
    await renderer.dispose();
  });

  testWidgets('previous image retires after its replacement is painted',
      (tester) async {
    if (useHtmlElementView) return;
    final (renderer, state) = await pumpCaptureView(tester);

    var capture = state.captureFrame();
    final first = await makeImage(tester);
    state.pending.last.complete(first);
    await capture;
    await tester.pump();

    capture = state.captureFrame();
    final second = await makeImage(tester);
    state.pending.last.complete(second);
    await capture;
    expect(first.debugDisposed, isFalse);
    await tester.pump();
    expect(first.debugDisposed, isTrue);

    await tester.pumpWidget(const SizedBox());
    expect(second.debugDisposed, isTrue);
    await renderer.dispose();
  });

  testWidgets('clearing and restoring the source owns one frame loop',
      (tester) async {
    if (useHtmlElementView) return;
    final (renderer, state) = await pumpCaptureView(tester);
    expect(state.callbackID, isNotNull);

    renderer.srcObject = null;
    await tester.pump();
    expect(state.callbackID, isNull);
    expect(state.videoElement, isNull);

    renderer.srcObject = canvasStream();
    await tester.pump();
    expect(state.callbackID, isNotNull);
    expect(state.videoElement, same(renderer.findHtmlView()));
    await tester.pumpWidget(const SizedBox());
    await renderer.dispose();
  });

  testWidgets('track removal stops and restoration resumes one frame loop',
      (tester) async {
    if (useHtmlElementView) return;
    final source = canvasStream();
    final renderer = TrackingRenderer()..srcObject = source;
    await renderer.initialize();
    final key = GlobalKey<CaptureState>();
    await tester.pumpWidget(MaterialApp(home: CaptureView(renderer, key: key)));
    final state = key.currentState!;
    final track = source.jsStream.getVideoTracks().toDart.single;
    expect(state.callbackID, isNotNull);

    source.jsStream
      ..removeTrack(track)
      ..dispatchEvent(web.Event('removetrack'));
    await tester.pump();
    expect(state.callbackID, isNull);
    expect(state.videoElement, isNull);

    source.jsStream
      ..addTrack(track)
      ..dispatchEvent(web.Event('addtrack'));
    await tester.pump();
    expect(state.callbackID, isNotNull);
    expect(state.videoElement, same(renderer.findHtmlView()));
    await tester.pumpWidget(const SizedBox());
    await renderer.dispose();
  });

  testWidgets('renderer keeps its element and browser stream across sources',
      (tester) async {
    final renderer = RTCVideoRenderer();
    final first = canvasStream();
    final second = canvasStream();
    renderer.srcObject = first;
    await renderer.initialize();
    final element = renderer.createElement();
    final browserStream = element.srcObject as web.MediaStream;
    final firstTrack = first.jsStream.getVideoTracks().toDart.single;
    expect(browserStream.getVideoTracks().toDart.single.id, firstTrack.id);

    renderer.srcObject = second;
    await tester.pump();
    final secondTrack = second.jsStream.getVideoTracks().toDart.single;
    expect(renderer.createElement(), same(element));
    expect(element.srcObject, same(browserStream));
    expect(browserStream.getVideoTracks().toDart.single.id, secondTrack.id);

    renderer.srcObject = null;
    await tester.pump();
    expect(element.srcObject, same(browserStream));
    expect(browserStream.getVideoTracks().toDart, isEmpty);
    await renderer.dispose();
  });

  testWidgets('HTML mode does not start the texture frame pipeline',
      (tester) async {
    if (!useHtmlElementView) return;
    final renderer = TrackingRenderer()..srcObject = canvasStream();
    await renderer.initialize();
    final key = GlobalKey<RTCVideoViewState>();
    await tester.pumpWidget(
      MaterialApp(home: RTCVideoView(renderer, key: key)),
    );

    expect(key.currentState!.videoElement, isNull);
    expect(key.currentState!.callbackID, isNull);
    expect(key.currentState!.frameMetrics.importedFrames, 0);
    await tester.pumpWidget(const SizedBox());
    await renderer.dispose();
  });
}
