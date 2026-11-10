import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/*
 * Video processor sample.
 *
 * The black and white filter runs in native code, and the runners register the
 * channel below:
 * - Windows, Linux and eLinux attach an RTCVideoProcessor to the camera track
 *   through FlutterWebRTCBase::AddVideoProcessor; see
 *   cpp/video_processor_sample.cpp.
 * - iOS and macOS attach an ExternalVideoProcessingDelegate through
 *   -[LocalVideoTrack addProcessing:]; see darwin/VideoProcessorSample.m.
 * - Android attaches an ExternalVideoFrameProcessing through
 *   LocalVideoTrack.addProcessor; see VideoProcessorSample.java in the
 *   Android runner.
 * The filter applies to the local preview and to what a peer connection would
 * send.
 */
class VideoProcessorSample extends StatefulWidget {
  static String tag = 'video_processor_sample';

  @override
  _VideoProcessorSampleState createState() => _VideoProcessorSampleState();
}

class _VideoProcessorSampleState extends State<VideoProcessorSample> {
  static const _channel =
      MethodChannel('flutter_webrtc_example/video_processor');

  final _localRenderer = RTCVideoRenderer();
  MediaStream? _localStream;
  bool _grayscale = false;
  String? _error;

  // eLinux reports itself as Linux.
  bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  String? get _trackId => _localStream?.getVideoTracks().firstOrNull?.id;

  @override
  void initState() {
    super.initState();
    _localRenderer.initialize();
  }

  @override
  void deactivate() {
    super.deactivate();
    _stop();
    _localRenderer.dispose();
  }

  Future<void> _start() async {
    try {
      final stream = await navigator.mediaDevices.getUserMedia({
        'audio': false,
        'video': {
          'mandatory': {'minWidth': '1280', 'minHeight': '720'},
        },
      });
      _localStream = stream;
      _localRenderer.srcObject = stream;
      setState(() => _error = null);
      await _setGrayscale(_grayscale);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _stop() async {
    final stream = _localStream;
    if (stream == null) return;
    final trackId = _trackId;
    _localStream = null;
    // Detach the processor before the track goes away.
    if (trackId != null) {
      await _channel.invokeMethod('remove', {'trackId': trackId});
    }
    _localRenderer.srcObject = null;
    for (final track in stream.getTracks()) {
      await track.stop();
    }
    await stream.dispose();
    if (mounted) setState(() {});
  }

  Future<void> _setGrayscale(bool enabled) async {
    setState(() => _grayscale = enabled);
    final trackId = _trackId;
    if (trackId == null) return;
    try {
      await _channel.invokeMethod(
          'setGrayscale', {'trackId': trackId, 'enabled': enabled});
    } on PlatformException catch (e) {
      setState(() => _error = '${e.code}: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final running = _localStream != null;
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Processor'),
        actions: [
          if (_supported)
            IconButton(
              tooltip: running ? 'Stop' : 'Start',
              icon: Icon(running ? Icons.stop : Icons.play_arrow),
              onPressed: running ? _stop : _start,
            ),
        ],
      ),
      body: !_supported
          ? Center(
              child: Text('This sample needs the native code of the Windows, '
                  'Linux, eLinux, Android, iOS and macOS runners '
                  '(cpp/video_processor_sample.cpp, '
                  'darwin/VideoProcessorSample.m).'))
          : Column(
              children: [
                SwitchListTile(
                  title: Text('Black and white filter'),
                  subtitle: Text('Removes the color of the camera frames'),
                  value: _grayscale,
                  onChanged: _setGrayscale,
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(_error!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                  ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(color: Colors.black54),
                    child: running
                        ? RTCVideoView(_localRenderer)
                        : Center(
                            child: Text('Press ▶ to start the camera',
                                style: TextStyle(color: Colors.white70))),
                  ),
                ),
              ],
            ),
    );
  }
}
