import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// Latency percentiles of a ping-pong run, in microseconds.
class LatencyStats {
  LatencyStats._(this.count, this.min, this.mean, this.p50, this.p90, this.p99,
      this.max);

  factory LatencyStats.fromSamples(List<int> samplesUs) {
    final sorted = List<int>.of(samplesUs)..sort();
    final n = sorted.length;
    int percentile(double p) =>
        sorted[math.max(0, (p / 100 * n).ceil() - 1).clamp(0, n - 1)];
    final sum = sorted.fold<int>(0, (a, b) => a + b);
    return LatencyStats._(n, sorted.first, sum / n, percentile(50),
        percentile(90), percentile(99), sorted.last);
  }

  final int count;
  final int min;
  final double mean;
  final int p50;
  final int p90;
  final int p99;
  final int max;

  Map<String, dynamic> toJson() => {
        'count': count,
        'minUs': min,
        'meanUs': mean.round(),
        'p50Us': p50,
        'p90Us': p90,
        'p99Us': p99,
        'maxUs': max,
      };
}

/// One-way throughput of a burst of messages from caller to callee.
class ThroughputStats {
  ThroughputStats(this.messages, this.bytes, this.elapsedUs,
      {this.runsUs = const []});

  final int messages;
  final int bytes;
  final int elapsedUs;

  /// Elapsed time of every timed run; [elapsedUs] is their median.
  final List<int> runsUs;

  double get messagesPerSecond => messages * 1e6 / elapsedUs;
  double get megabytesPerSecond => bytes / elapsedUs; // bytes/us == MB/s

  Map<String, dynamic> toJson() => {
        'messages': messages,
        'bytes': bytes,
        'elapsedUs': elapsedUs,
        'msgPerSec': messagesPerSecond.round(),
        'MBps': double.parse(megabytesPerSecond.toStringAsFixed(2)),
        'runsUs': runsUs,
      };
}

enum BenchmarkKind { pingPong, throughput }

class BenchmarkScenario {
  const BenchmarkScenario({
    required this.kind,
    required this.payloadSize,
    this.binary = true,
    this.uiLoad = false,
    this.count = 1000,
    this.warmup = 100,
  });

  final BenchmarkKind kind;
  final int payloadSize;
  final bool binary;
  final bool uiLoad;

  /// Measured round trips (ping-pong) or messages sent (throughput).
  final int count;

  /// Round trips run before measuring starts. Ignored for throughput.
  final int warmup;

  String get name =>
      '${kind == BenchmarkKind.pingPong ? 'pingpong' : 'throughput'}'
      '/${binary ? 'binary' : 'text'}/${payloadSize}B'
      '/${uiLoad ? 'ui-load' : 'idle'}';

  /// The default matrix: RTT for small, medium and large messages, text and
  /// binary, with and without UI load, plus one-way throughput.
  static List<BenchmarkScenario> defaultMatrix() {
    final scenarios = <BenchmarkScenario>[];
    for (final uiLoad in [false, true]) {
      for (final size in [16, 1024, 16 * 1024]) {
        scenarios.add(BenchmarkScenario(
            kind: BenchmarkKind.pingPong, payloadSize: size, uiLoad: uiLoad));
      }
      scenarios.add(BenchmarkScenario(
          kind: BenchmarkKind.pingPong,
          payloadSize: 16,
          binary: false,
          uiLoad: uiLoad));
      scenarios.add(BenchmarkScenario(
          kind: BenchmarkKind.throughput,
          payloadSize: 1024,
          count: 5000,
          uiLoad: uiLoad));
      scenarios.add(BenchmarkScenario(
          kind: BenchmarkKind.throughput,
          payloadSize: 16 * 1024,
          count: 500,
          uiLoad: uiLoad));
    }
    return scenarios;
  }
}

class BenchmarkResult {
  BenchmarkResult(this.scenario, {this.latency, this.throughput});

  final BenchmarkScenario scenario;
  final LatencyStats? latency;
  final ThroughputStats? throughput;

  String get summary {
    if (latency != null) {
      final l = latency!;
      return 'p50 ${l.p50}us  p90 ${l.p90}us  p99 ${l.p99}us  max ${l.max}us';
    }
    final t = throughput!;
    return '${t.messagesPerSecond.round()} msg/s  '
        '${t.megabytesPerSecond.toStringAsFixed(2)} MB/s';
  }

  Map<String, dynamic> toJson() => {
        'scenario': scenario.name,
        if (latency != null) ...latency!.toJson(),
        if (throughput != null) ...throughput!.toJson(),
      };
}

/// Two peer connections in the same process joined by one data channel.
///
/// The callee echoes every message back during ping-pong runs, and counts
/// messages during throughput runs. All timing is taken on the caller side
/// with a single [Stopwatch], so one round trip covers two sends and two
/// receives through the plugin, plus the SCTP loopback in between.
class DataChannelLoopback {
  DataChannelLoopback._(this._pc1, this._pc2);

  final RTCPeerConnection _pc1;
  final RTCPeerConnection _pc2;
  late final RTCDataChannel _caller;
  late final RTCDataChannel _callee;

  final _clock = Stopwatch()..start();

  // Ping-pong state.
  Completer<int>? _pendingEcho;
  int _expectedSeq = -1;

  // Throughput state.
  bool _echo = true;
  int _received = 0;
  int _expected = 0;
  Completer<int>? _burstDone;

  static Future<DataChannelLoopback> open() async {
    final pc1 = await createPeerConnection({'iceServers': []});
    final pc2 = await createPeerConnection({'iceServers': []});
    final loopback = DataChannelLoopback._(pc1, pc2);
    try {
      await loopback._connect();
    } catch (_) {
      await loopback.close();
      rethrow;
    }
    return loopback;
  }

  Future<void> _connect() async {
    _pc1.onIceCandidate = (c) => _pc2.addCandidate(c);
    _pc2.onIceCandidate = (c) => _pc1.addCandidate(c);

    final calleeReady = Completer<RTCDataChannel>();
    _pc2.onDataChannel = (channel) {
      if (!calleeReady.isCompleted) calleeReady.complete(channel);
    };

    _caller = await _pc1.createDataChannel(
        'benchmark', RTCDataChannelInit()..ordered = true);
    final callerOpen = Completer<void>();
    _caller.onDataChannelState = (state) {
      if (state == RTCDataChannelState.RTCDataChannelOpen &&
          !callerOpen.isCompleted) {
        callerOpen.complete();
      }
    };
    _caller.onMessage = _onCallerMessage;

    final offer = await _pc1.createOffer({});
    await _pc1.setLocalDescription(offer);
    await _pc2.setRemoteDescription(offer);
    final answer = await _pc2.createAnswer();
    await _pc2.setLocalDescription(answer);
    await _pc1.setRemoteDescription(answer);

    _callee = await calleeReady.future.timeout(const Duration(seconds: 10));
    _callee.onMessage = _onCalleeMessage;
    if (_caller.state != RTCDataChannelState.RTCDataChannelOpen) {
      await callerOpen.future.timeout(const Duration(seconds: 10));
    }
  }

  void _onCalleeMessage(RTCDataChannelMessage message) {
    if (_echo) {
      _callee.send(message).catchError((Object e) {
        debugPrint('[dc-bench] echo failed: $e');
      });
      return;
    }
    _received++;
    if (_received == _expected) {
      _burstDone?.complete(_clock.elapsedMicroseconds);
    }
  }

  void _onCallerMessage(RTCDataChannelMessage message) {
    final now = _clock.elapsedMicroseconds;
    final pending = _pendingEcho;
    if (pending == null || pending.isCompleted) return;
    if (_seqOf(message) != _expectedSeq) {
      pending.completeError(StateError(
          'out of order echo: got ${_seqOf(message)}, want $_expectedSeq'));
      return;
    }
    pending.complete(now);
  }

  static int _seqOf(RTCDataChannelMessage message) {
    if (message.isBinary) {
      return ByteData.sublistView(message.binary).getUint32(0);
    }
    final text = message.text;
    return int.parse(text.substring(0, text.indexOf(':')));
  }

  static RTCDataChannelMessage _message(int seq, int size, bool binary) {
    if (binary) {
      final bytes = Uint8List(math.max(size, 4));
      ByteData.sublistView(bytes).setUint32(0, seq);
      return RTCDataChannelMessage.fromBinary(bytes);
    }
    final prefix = '$seq:';
    return RTCDataChannelMessage(
        prefix + 'x' * math.max(0, size - prefix.length));
  }

  Future<BenchmarkResult> run(BenchmarkScenario scenario,
      {void Function(double progress)? onProgress}) {
    switch (scenario.kind) {
      case BenchmarkKind.pingPong:
        return _runPingPong(scenario, onProgress);
      case BenchmarkKind.throughput:
        return _runThroughput(scenario, onProgress);
    }
  }

  Future<BenchmarkResult> _runPingPong(BenchmarkScenario scenario,
      void Function(double progress)? onProgress) async {
    _echo = true;
    final total = scenario.warmup + scenario.count;
    final samples = <int>[];
    // Build every message up front so allocation is not part of the RTT.
    final messages = List.generate(
        total, (i) => _message(i, scenario.payloadSize, scenario.binary));
    for (var i = 0; i < total; i++) {
      final pending = Completer<int>();
      _pendingEcho = pending;
      _expectedSeq = i;
      final start = _clock.elapsedMicroseconds;
      unawaited(_caller.send(messages[i]).catchError((Object e) {
        if (!pending.isCompleted) pending.completeError(e);
      }));
      final end = await pending.future.timeout(const Duration(seconds: 5));
      if (i >= scenario.warmup) samples.add(end - start);
      if (onProgress != null && i % 50 == 0) onProgress(i / total);
    }
    _pendingEcho = null;
    return BenchmarkResult(scenario,
        latency: LatencyStats.fromSamples(samples));
  }

  /// Timed bursts per throughput scenario; the median one is reported.
  static const _throughputRuns = 3;

  Future<BenchmarkResult> _runThroughput(BenchmarkScenario scenario,
      void Function(double progress)? onProgress) async {
    final messages = List.generate(scenario.count,
        (i) => _message(i, scenario.payloadSize, scenario.binary));
    final bytes = messages.fold<int>(
        0,
        (sum, m) =>
            sum + (m.isBinary ? m.binary.length : utf8.encode(m.text).length));
    // An untimed burst first, so SCTP has opened its congestion window before
    // the timed runs. Without it the first large-message burst can stall.
    await _burst(messages.sublist(0, math.max(1, messages.length ~/ 10)));
    final runs = <int>[];
    for (var r = 0; r < _throughputRuns; r++) {
      runs.add(await _burst(messages,
          onProgress: onProgress == null
              ? null
              : (p) => onProgress((r + p) / _throughputRuns)));
    }
    final sorted = List<int>.of(runs)..sort();
    return BenchmarkResult(scenario,
        throughput: ThroughputStats(
            scenario.count, bytes, sorted[sorted.length ~/ 2],
            runsUs: runs));
  }

  /// Sends [messages] back to back and returns the microseconds from the
  /// first send to the callee receiving the last message.
  Future<int> _burst(List<RTCDataChannelMessage> messages,
      {void Function(double progress)? onProgress}) async {
    _echo = false;
    _received = 0;
    _expected = messages.length;
    final done = Completer<int>();
    _burstDone = done;
    try {
      final start = _clock.elapsedMicroseconds;
      for (var i = 0; i < messages.length; i++) {
        // Awaiting each send keeps the SCTP send buffer from overflowing,
        // which would close the channel. It is also how most apps send.
        await _caller.send(messages[i]);
        if (onProgress != null && i % 100 == 0) {
          onProgress(i / messages.length);
        }
      }
      final end = await done.future.timeout(const Duration(seconds: 30));
      return end - start;
    } finally {
      _burstDone = null;
      _echo = true;
    }
  }

  Future<void> close() async {
    await _pc1.close();
    await _pc2.close();
    await _pc1.dispose();
    await _pc2.dispose();
  }
}
