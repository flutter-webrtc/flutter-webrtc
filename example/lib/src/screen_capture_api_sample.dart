import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc_example/src/widgets/screen_select_dialog.dart';

class ScreenCaptureApiSample extends StatefulWidget {
  static String tag = 'screen_capture_api_sample';

  @override
  _ScreenCaptureApiSampleState createState() => _ScreenCaptureApiSampleState();
}

class _ScreenCaptureApiSampleState extends State<ScreenCaptureApiSample> {
  final Map<String, DesktopCapturerSource> _sources = {};
  final List<StreamSubscription<DesktopCapturerSource>> _subscriptions = [];
  SourceType _sourceType = SourceType.Screen;
  String _status = 'Idle';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _subscriptions.add(desktopCapturer.onAdded.stream.listen((source) {
      _sources[source.id] = source;
      setState(() {});
    }));
    _subscriptions.add(desktopCapturer.onRemoved.stream.listen((source) {
      _sources.remove(source.id);
      setState(() {});
    }));
    _subscriptions.add(desktopCapturer.onThumbnailChanged.stream.listen((_) {
      setState(() {});
    }));
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  Future<void> _requestCapturePermission() async {
    if (!(WebRTC.platformIsAndroid || WebRTC.platformIsMacOS)) {
      setState(() {
        _status = 'Capture permission API not supported on this platform.';
      });
      return;
    }
    setState(() {
      _busy = true;
      _status = 'Requesting capture permission...';
    });
    try {
      final granted = await Helper.requestCapturePermission();
      setState(() {
        _status = granted ? 'Capture permission granted.' : 'Capture permission denied.';
      });
    } catch (e) {
      setState(() {
        _status = 'Capture permission failed: $e';
      });
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  Future<void> _getSources() async {
    setState(() {
      _busy = true;
      _status = 'Loading sources...';
    });
    try {
      final sources = await desktopCapturer.getSources(types: [_sourceType]);
      _sources
        ..clear()
        ..addEntries(sources.map((source) => MapEntry(source.id, source)));
      setState(() {
        _status = 'Loaded ${sources.length} sources.';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to load sources: $e';
      });
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  Future<void> _updateSources() async {
    setState(() {
      _busy = true;
      _status = 'Updating sources...';
    });
    try {
      await desktopCapturer.updateSources(types: [_sourceType]);
      setState(() {
        _status = 'Update requested.';
      });
    } catch (e) {
      setState(() {
        _status = 'Update failed: $e';
      });
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  Widget _buildSourceGrid(SourceType type) {
    final entries = _sources.entries.where((entry) => entry.value.type == type).toList();
    if (entries.isEmpty) {
      return Center(child: Text('No sources found.'));
    }
    return GridView.count(
      crossAxisSpacing: 8,
      crossAxisCount: type == SourceType.Screen ? 2 : 3,
      children: entries
          .map((entry) => ThumbnailWidget(
                onTap: (_) {},
                source: entry.value,
                selected: false,
              ))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Screen Capture APIs'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _busy ? null : _requestCapturePermission,
                  child: Text('Request Permission'),
                ),
                ElevatedButton(
                  onPressed: _busy ? null : _getSources,
                  child: Text('Get Sources'),
                ),
                ElevatedButton(
                  onPressed: _busy ? null : _updateSources,
                  child: Text('Update Sources'),
                ),
                DropdownButton<SourceType>(
                  value: _sourceType,
                  onChanged: _busy
                      ? null
                      : (value) {
                          if (value == null) return;
                          setState(() {
                            _sourceType = value;
                          });
                        },
                  items: const [
                    DropdownMenuItem(
                      value: SourceType.Screen,
                      child: Text('Screen'),
                    ),
                    DropdownMenuItem(
                      value: SourceType.Window,
                      child: Text('Window'),
                    ),
                  ],
                ),
                Text(_status),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: _buildSourceGrid(_sourceType),
            ),
          ),
        ],
      ),
    );
  }
}
