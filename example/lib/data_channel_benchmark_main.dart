import 'dart:io';

import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:flutter_webrtc/src/native/rtc_data_channel_ffi.dart';

import 'src/data_channel_benchmark_sample.dart';

/// Runs the data channel benchmark matrix on launch and prints a JSON report
/// prefixed with `[dc-bench] REPORT`.
///
///   flutter run --profile -t lib/data_channel_benchmark_main.dart -d macos
///
/// Pass `--dart-define=DC_BENCH_EXIT=true` to quit once the report is printed,
/// which is handy for scripted runs on desktop, and
/// `--dart-define=DC_BENCH_TRANSPORT=method-channel` to measure the channel
/// transport on a platform that supports FFI.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DataChannelFfi.enabled =
      const String.fromEnvironment('DC_BENCH_TRANSPORT') != 'method-channel';
  const exitWhenDone = bool.fromEnvironment('DC_BENCH_EXIT');
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: DataChannelBenchmarkSample(
      autoRun: true,
      onFinished: exitWhenDone ? (_) => exit(0) : null,
    ),
  ));
}
