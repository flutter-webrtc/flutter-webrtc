# Web video renderer benchmark

`rtc_video_renderer_benchmark_test.dart` drives 1, 4, 6, or 8 independent
640×360 canvas-backed `MediaStream`s at 30 generated frames per second. It is
excluded from normal test runs by the `benchmark` tag.

The harness reports one JSON record per video count with:

- texture imports, paint invalidations, paints, and skipped frames;
- `RTCVideoView` builds during the measured interval;
- maximum concurrent imports per video;
- browser playback-quality counters;
- JS heap delta when Chromium exposes `performance.memory`;
- Flutter frame timings when the runner exposes them.

Run the optimized texture path with CanvasKit:

```bash
flutter test --platform chrome --run-skipped --tags benchmark \
  --dart-define=WEBRTC_BENCHMARK_SECONDS=5 \
  --dart-define=WEBRTC_BENCHMARK_RENDERER=CanvasKit \
  test/benchmark/web/rtc_video_renderer_benchmark_test.dart
```

Run multithreaded Skwasm (cross-origin isolation is enabled by default):

```bash
flutter test --platform chrome --wasm --run-skipped --tags benchmark \
  --dart-define=WEBRTC_BENCHMARK_SECONDS=5 \
  --dart-define=WEBRTC_BENCHMARK_RENDERER=Skwasm-MT \
  test/benchmark/web/rtc_video_renderer_benchmark_test.dart
```

Run the single-threaded Skwasm fallback in the test runner:

```bash
flutter test --platform chrome --wasm --no-cross-origin-isolation \
  --run-skipped --tags benchmark \
  --dart-define=WEBRTC_BENCHMARK_SECONDS=5 \
  --dart-define=WEBRTC_BENCHMARK_RENDERER=Skwasm-ST \
  test/benchmark/web/rtc_video_renderer_benchmark_test.dart
```

For a built application, select single-threaded Skwasm with Flutter's public
engine initialization option `forceSingleThreadedSkwasm`; do not depend on the
lack of cross-origin isolation as application configuration.

Run the HTML platform-view reference:

```bash
flutter test --platform chrome --run-skipped --tags benchmark \
  --dart-define=WEBRTC_USE_HTML_ELEMENT_VIEW=true \
  --dart-define=WEBRTC_BENCHMARK_SECONDS=5 \
  --dart-define=WEBRTC_BENCHMARK_RENDERER=HTML-platform-view \
  test/benchmark/web/rtc_video_renderer_benchmark_test.dart
```

Override the matrix with, for example,
`--dart-define=WEBRTC_BENCHMARK_COUNTS=1,6`.

## Baseline and current functional results

Measured on Flutter 3.47.5 and Chrome on macOS. The source generated 30 frames
per second. Values below are operations during the measured interval.

| Renderer | Videos | Widget builds/s | Imports/s | Paint invalidations/s | Max imports/video |
|---|---:|---:|---:|---:|---:|
| Parent commit texture + CanvasKit | 1 | 30 | not instrumented | not instrumented | not instrumented |
| Parent commit texture + CanvasKit | 4 | 120 | not instrumented | not instrumented | not instrumented |
| Parent commit texture + CanvasKit | 6 | 180 | not instrumented | not instrumented | not instrumented |
| Optimized texture + CanvasKit | 1 | 0 | 30 | 30 | 1 |
| Optimized texture + CanvasKit | 4 | 0 | 120 | 120 | 1 |
| Optimized texture + CanvasKit | 6 | 0 | 180 | 180 | 1 |
| Optimized texture + Skwasm MT | 1 | 0 | 30 | 30 | 1 |
| Optimized texture + Skwasm MT | 4 | 0 | 120 | 120 | 1 |
| Optimized texture + Skwasm MT | 6 | 0 | 180 | 180 | 1 |
| Optimized texture + Skwasm ST | 1 | 0 | 30 | 30 | 1 |
| Optimized texture + Skwasm ST | 4 | 0 | 120 | 120 | 1 |
| Optimized texture + Skwasm ST | 6 | 0 | 180 | 180 | 1 |
| HTML platform view | 1/4/6 | 0 | 0 | 0 | 0 |

The 8-video optimized CanvasKit sample also produced 240 imports and 240 paint
invalidations per second, zero `RTCVideoView` builds, and at most one import per
video.

These are functional pipeline invariants, not CPU comparisons. This test runner
paces every generated frame and did not emit `FrameTiming` samples in the runs
above. Chromium's canvas playback counters reported generated canvas frames as
dropped even when every texture import completed, and unforced JS heap deltas
varied with garbage collection. Therefore elapsed time, playback dropped-frame
counts, heap deltas, and unavailable Flutter build/raster timings must not be
used to claim relative renderer performance.

For CPU, heat, and production frame-time comparisons, run a profile/release Web
build in an isolated browser session and record Chrome Performance traces for
each renderer configuration. Use repeated samples and the same video count,
resolution, generated frame cadence, browser version, and cross-origin
isolation settings.

## Public texture API boundary

Flutter 3.47.5 exposes `ui_web.createImageFromTextureSource`, which returns a
new `ui.Image`. It does not expose a public mutable external texture handle.
CanvasKit has an internal lazy GPU texture-source path, while multithreaded
Skwasm must turn a non-transferable `HTMLVideoElement` into a transferable
representation such as `ImageBitmap`. This package cannot safely bypass either
implementation.

A future public API would need an owned, renderer-neutral lifecycle such as:

```text
WebExternalTexture.create(source)
WebExternalTexture.update(source)
WebExternalTexture.dispose()
```

It would also need explicit frame-availability, ownership, worker-transfer, and
resource-retirement semantics. Until then, one public `ui.Image` import per
presented texture frame remains the unavoidable boundary.
