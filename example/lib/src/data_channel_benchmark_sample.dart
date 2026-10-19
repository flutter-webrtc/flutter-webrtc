import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
// ignore: implementation_imports
import 'package:flutter_webrtc/src/native/rtc_data_channel_ffi.dart';

import 'data_channel_benchmark.dart';

/// Measures data channel round-trip latency and throughput between two
/// loopback peer connections. Run it in profile or release mode; debug mode
/// numbers are dominated by the JIT.
class DataChannelBenchmarkSample extends StatefulWidget {
  const DataChannelBenchmarkSample({this.autoRun = false, this.onFinished});

  static String tag = 'data_channel_benchmark';

  /// Start the default matrix as soon as the page is shown.
  final bool autoRun;

  /// Called with the JSON report once a run of the matrix completes.
  final void Function(Map<String, dynamic> report)? onFinished;

  @override
  State<DataChannelBenchmarkSample> createState() =>
      _DataChannelBenchmarkSampleState();
}

class _DataChannelBenchmarkSampleState
    extends State<DataChannelBenchmarkSample> {
  final _results = <BenchmarkResult>[];
  bool _running = false;
  bool _uiLoad = false;
  String _status = 'Idle';
  double _progress = 0;
  Map<String, dynamic>? _report;

  @override
  void initState() {
    super.initState();
    if (widget.autoRun) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _runMatrix());
    }
  }

  Future<void> _runMatrix() async {
    if (_running) return;
    setState(() {
      _running = true;
      _results.clear();
      _report = null;
    });
    DataChannelLoopback? loopback;
    try {
      setState(() => _status = 'Connecting');
      loopback = await DataChannelLoopback.open();
      for (final scenario in BenchmarkScenario.defaultMatrix()) {
        if (!mounted) return;
        setState(() {
          _uiLoad = scenario.uiLoad;
          _status = scenario.name;
          _progress = 0;
        });
        // Let the load widget run a few frames before measuring.
        await Future<void>.delayed(const Duration(milliseconds: 300));
        final result = await loopback.run(scenario, onProgress: (p) {
          if (mounted && !_uiLoad) setState(() => _progress = p);
        });
        debugPrint('[dc-bench] ${jsonEncode(result.toJson())}');
        if (!mounted) return;
        setState(() => _results.add(result));
      }
      final report = <String, dynamic>{
        'platform': defaultTargetPlatform.name,
        'mode': kReleaseMode
            ? 'release'
            : kProfileMode
                ? 'profile'
                : 'debug',
        'transport': DataChannelFfi.enabled && DataChannelFfi.instance != null
            ? 'ffi'
            : 'method-channel',
        'timestamp': DateTime.now().toIso8601String(),
        'results': _results.map((r) => r.toJson()).toList(),
      };
      debugPrint('[dc-bench] REPORT ${jsonEncode(report)}');
      _report = report;
      _status = 'Done';
      widget.onFinished?.call(report);
    } catch (e, st) {
      debugPrint('[dc-bench] failed: $e\n$st');
      _status = 'Failed: $e';
    } finally {
      await loopback?.close();
      if (mounted) {
        setState(() {
          _running = false;
          _uiLoad = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Channel Benchmark'),
        actions: [
          IconButton(
            tooltip: 'Copy JSON report',
            icon: const Icon(Icons.copy),
            onPressed: _report == null
                ? null
                : () => Clipboard.setData(
                    ClipboardData(text: jsonEncode(_report))),
          ),
        ],
      ),
      body: Column(
        children: [
          if (kDebugMode)
            Container(
              width: double.infinity,
              color: Colors.amber,
              padding: const EdgeInsets.all(8),
              child: const Text(
                  'Debug mode: numbers are not representative. '
                  'Run with --profile or --release.'),
            ),
          ListTile(
            title: Text(_status),
            subtitle: _running ? LinearProgressIndicator(value: _progress) : null,
          ),
          SizedBox(height: 120, child: _UiLoad(active: _uiLoad)),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, i) => ListTile(
                dense: true,
                title: Text(_results[i].scenario.name),
                subtitle: Text(_results[i].summary,
                    style: const TextStyle(fontFamily: 'monospace')),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _running ? null : _runMatrix,
        icon: const Icon(Icons.speed),
        label: Text(_running ? 'Running' : 'Run all'),
      ),
    );
  }
}

/// Keeps the UI isolate busy while active: rebuilds a grid every frame and
/// burns [_burn] of CPU in each build, which is about half a 60 Hz frame.
class _UiLoad extends StatefulWidget {
  const _UiLoad({required this.active});

  final bool active;

  @override
  State<_UiLoad> createState() => _UiLoadState();
}

class _UiLoadState extends State<_UiLoad> with SingleTickerProviderStateMixin {
  static const _burn = Duration(milliseconds: 8);
  late final Ticker _ticker = createTicker((_) => setState(() => _frame++));
  int _frame = 0;

  @override
  void initState() {
    super.initState();
    if (widget.active) _ticker.start();
  }

  @override
  void didUpdateWidget(_UiLoad oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_ticker.isActive) _ticker.start();
    if (!widget.active && _ticker.isActive) _ticker.stop();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) {
      return const Center(child: Text('UI load: off'));
    }
    final sw = Stopwatch()..start();
    while (sw.elapsed < _burn) {}
    return GridView.count(
      crossAxisCount: 20,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(
          200,
          (i) => Container(
              color: Colors.primaries[(i + _frame) % Colors.primaries.length])),
    );
  }
}
