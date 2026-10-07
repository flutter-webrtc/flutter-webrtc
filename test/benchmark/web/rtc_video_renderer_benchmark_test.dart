@TestOn('browser')
@Tags(['benchmark'])
library;

import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:dart_webrtc/dart_webrtc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart' as web;

import 'package:flutter_webrtc/src/web/rtc_video_renderer_impl.dart';
import 'package:flutter_webrtc/src/web/rtc_video_view_impl.dart';

const benchmarkCounts = String.fromEnvironment(
  'WEBRTC_BENCHMARK_COUNTS',
  defaultValue: '1,4,6,8',
);
const benchmarkSeconds = int.fromEnvironment(
  'WEBRTC_BENCHMARK_SECONDS',
  defaultValue: 5,
);
const benchmarkRenderer = String.fromEnvironment(
  'WEBRTC_BENCHMARK_RENDERER',
  defaultValue: 'flutter-test-default',
);

class BenchmarkVideoView extends RTCVideoView {
  BenchmarkVideoView(super.renderer, {super.key});

  @override
  BenchmarkVideoViewState createState() => BenchmarkVideoViewState();
}

class BenchmarkVideoViewState extends RTCVideoViewState {
  int benchmarkBuilds = 0;

  @override
  Widget build(BuildContext context) {
    benchmarkBuilds++;
    return super.build(context);
  }
}

int frameMetric(BenchmarkVideoViewState state, String name) {
  try {
    final dynamic metrics = (state as dynamic).frameMetrics;
    return switch (name) {
      'importedFrames' => metrics.importedFrames as int,
      'paintInvalidations' => metrics.paintInvalidations as int,
      'paintedFrames' => metrics.paintedFrames as int,
      'skippedFrames' => metrics.skippedFrames as int,
      'maxConcurrentImports' => metrics.maxConcurrentImports as int,
      _ => 0,
    };
  } on NoSuchMethodError {
    return 0;
  }
}

class CanvasVideoSource {
  CanvasVideoSource(int index)
      : canvas = web.HTMLCanvasElement()
          ..width = 640
          ..height = 360,
        _index = index {
    final browserStream = canvas.captureStream(0);
    stream = MediaStreamWeb(browserStream, 'local');
    _track = browserStream.getVideoTracks().toDart.single
        as web.CanvasCaptureMediaStreamTrack;
    drawNextFrame();
  }

  final web.HTMLCanvasElement canvas;
  final int _index;
  late final MediaStreamWeb stream;
  late final web.CanvasCaptureMediaStreamTrack _track;
  int _frame = 0;

  void drawNextFrame() {
    final context = canvas.context2D;
    context.fillStyle =
        'rgb(${(_frame * 3 + _index * 31) % 255}, 40, 120)'.toJS;
    context.fillRect(0, 0, 640, 360);
    context.fillStyle = 'white'.toJS;
    context.fillRect((_frame * 7 % 608).toDouble(), 16, 32, 328);
    _track.requestFrame();
    _frame++;
  }

  void dispose() {
    _track.stop();
  }
}

int? usedJsHeapBytes() {
  try {
    final memory =
        web.window.performance.getProperty('memory'.toJS) as JSObject;
    final used = memory.getProperty('usedJSHeapSize'.toJS) as JSNumber;
    return used.toDartInt;
  } catch (_) {
    return null;
  }
}

void main() {
  testWidgets('deterministic multi-video rendering benchmark', (tester) async {
    final counts = benchmarkCounts.split(',').map(int.parse);
    await tester.binding.setSurfaceSize(const Size(1280, 960));
    for (final count in counts) {
      final sources = List.generate(count, CanvasVideoSource.new);
      final renderers = <RTCVideoRenderer>[];
      final keys = <GlobalKey<BenchmarkVideoViewState>>[];
      for (var index = 0; index < count; index++) {
        final renderer = RTCVideoRenderer()..srcObject = sources[index].stream;
        await renderer.initialize();
        renderers.add(renderer);
        keys.add(GlobalKey<BenchmarkVideoViewState>());
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Wrap(
            children: [
              for (var index = 0; index < count; index++)
                SizedBox(
                  width: count == 1 ? 1280 : 320,
                  height: count == 1 ? 720 : 360,
                  child: BenchmarkVideoView(
                    renderers[index],
                    key: keys[index],
                  ),
                ),
            ],
          ),
        ),
      );
      for (var frame = 0; frame < 30; frame++) {
        for (final source in sources) {
          source.drawNextFrame();
        }
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 33)),
        );
        await tester.pump();
      }

      final states = keys.map((key) => key.currentState!).toList();
      final importedBefore = states.fold<int>(
        0,
        (total, state) => total + frameMetric(state, 'importedFrames'),
      );
      final invalidationsBefore = states.fold<int>(
        0,
        (total, state) => total + frameMetric(state, 'paintInvalidations'),
      );
      final paintsBefore = states.fold<int>(
        0,
        (total, state) => total + frameMetric(state, 'paintedFrames'),
      );
      final skippedBefore = states.fold<int>(
        0,
        (total, state) => total + frameMetric(state, 'skippedFrames'),
      );
      final buildsBefore = states.fold<int>(
        0,
        (total, state) => total + state.benchmarkBuilds,
      );
      final playbackBefore = renderers
          .map((renderer) => renderer.findHtmlView()!.getVideoPlaybackQuality())
          .toList();
      final timings = <FrameTiming>[];
      void collectTimings(List<FrameTiming> values) => timings.addAll(values);
      SchedulerBinding.instance.addTimingsCallback(collectTimings);
      final heapBefore = usedJsHeapBytes();
      final stopwatch = Stopwatch()..start();
      for (var frame = 0; frame < benchmarkSeconds * 30; frame++) {
        for (final source in sources) {
          source.drawNextFrame();
        }
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 33)),
        );
        await tester.pump();
      }
      stopwatch.stop();
      final heapAfter = usedJsHeapBytes();
      SchedulerBinding.instance.removeTimingsCallback(collectTimings);

      final playback = <Map<String, int>>[];
      for (var index = 0; index < renderers.length; index++) {
        final quality =
            renderers[index].findHtmlView()!.getVideoPlaybackQuality();
        playback.add({
          'totalFrames':
              quality.totalVideoFrames - playbackBefore[index].totalVideoFrames,
          'droppedFrames': quality.droppedVideoFrames -
              playbackBefore[index].droppedVideoFrames,
        });
      }
      final report = <String, Object?>{
        'renderer': benchmarkRenderer,
        'htmlElementView': useHtmlElementView,
        'videos': count,
        'durationMs': stopwatch.elapsedMilliseconds,
        'importedFrames': states.fold<int>(
              0,
              (total, state) => total + frameMetric(state, 'importedFrames'),
            ) -
            importedBefore,
        'paintInvalidations': states.fold<int>(
              0,
              (total, state) =>
                  total + frameMetric(state, 'paintInvalidations'),
            ) -
            invalidationsBefore,
        'paintedFrames': states.fold<int>(
              0,
              (total, state) => total + frameMetric(state, 'paintedFrames'),
            ) -
            paintsBefore,
        'skippedFrames': states.fold<int>(
              0,
              (total, state) => total + frameMetric(state, 'skippedFrames'),
            ) -
            skippedBefore,
        'widgetBuilds': states.fold<int>(
              0,
              (total, state) => total + state.benchmarkBuilds,
            ) -
            buildsBefore,
        'maxConcurrentImportsPerVideo': states.fold<int>(
          0,
          (maximum, state) => mathMax(
            maximum,
            frameMetric(state, 'maxConcurrentImports'),
          ),
        ),
        'flutterFrameCount': timings.length,
        'averageBuildMicros': timings.isEmpty
            ? null
            : timings.fold<int>(
                  0,
                  (total, timing) =>
                      total + timing.buildDuration.inMicroseconds,
                ) /
                timings.length,
        'averageRasterMicros': timings.isEmpty
            ? null
            : timings.fold<int>(
                  0,
                  (total, timing) =>
                      total + timing.rasterDuration.inMicroseconds,
                ) /
                timings.length,
        'jsHeapDeltaBytes': heapBefore == null || heapAfter == null
            ? null
            : heapAfter - heapBefore,
        'playback': playback,
      };
      // One JSON object per sample makes repeated runs easy to aggregate.
      // ignore: avoid_print
      print('WEBRTC_TEXTURE_BENCHMARK ${jsonEncode(report)}');

      await tester.pumpWidget(const SizedBox());
      for (final renderer in renderers) {
        await renderer.dispose();
      }
      for (final source in sources) {
        source.dispose();
      }
    }
    await tester.binding.setSurfaceSize(null);
  }, timeout: const Timeout(Duration(minutes: 5)));
}

int mathMax(int first, int second) => first > second ? first : second;
