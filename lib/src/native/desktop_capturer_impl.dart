import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

import '../desktop_capturer.dart';
import 'utils.dart';

class DesktopCapturerSourceNative extends DesktopCapturerSource {
  DesktopCapturerSourceNative(
      this._id, this._name, this._thumbnailSize, this._type);
  factory DesktopCapturerSourceNative.fromMap(Map<dynamic, dynamic> map) {
    var sourceType = (map['type'] as String) == 'window'
        ? SourceType.Window
        : SourceType.Screen;
    var source = DesktopCapturerSourceNative(map['id'], map['name'],
        ThumbnailSize.fromMap(map['thumbnailSize']), sourceType);
    source.thumbnail = map['thumbnail'] as Uint8List;
    return source;
  }
  Function(String name)? onNameChanged;
  Function()? onRemoved;
  Function()? onThumbnailChanged;

  Uint8List? _thumbnail;
  String _name;
  final String _id;
  final ThumbnailSize _thumbnailSize;
  final SourceType _type;

  set thumbnail(Uint8List? value) {
    _thumbnail = value;
    onThumbnailChanged?.call();
  }

  set name(String name) {
    _name = name;
  }

  @override
  String get id => _id;

  @override
  String get name => _name;

  @override
  Uint8List? get thumbnail => _thumbnail;

  @override
  ThumbnailSize get thumbnailSize => _thumbnailSize;

  @override
  SourceType get type => _type;
}

class DesktopCapturerNative extends DesktopCapturer {
  DesktopCapturerNative._internal() {
    EventChannel('FlutterWebRTC/desktopSourcesEvent')
        .receiveBroadcastStream()
        .listen(eventListener, onError: errorListener);
  }

  static final DesktopCapturerNative instance =
      DesktopCapturerNative._internal();

  final Map<String, DesktopCapturerSourceNative> _sources = {};

  void eventListener(dynamic event) async {
    final Map<dynamic, dynamic> map = event;
    switch (map['event']) {
      case 'desktopSourceAdded':
        final source = DesktopCapturerSourceNative.fromMap(map);
        if (_sources[source.id] == null) {
          _sources[source.id] = source;
          onAdded.add(source);
        }
        break;
      case 'desktopSourceRemoved':
        final source = _sources[map['id'] as String];
        if (source != null) {
          _sources.remove((source) => source.id == map['id']);
          onRemoved.add(source);
        }
        break;
      case 'desktopSourceThumbnailChanged':
        final source = _sources[map['id'] as String];
        if (source != null) {
          try {
            source.thumbnail = map['thumbnail'] as Uint8List;
            onThumbnailChanged.add(source);
          } catch (e) {
            print('desktopSourceThumbnailChanged: $e');
          }
        }
        break;
      case 'desktopSourceNameChanged':
        final source = _sources[map['id'] as String];
        if (source != null) {
          source.name = map['name'];
          onNameChanged.add(source);
        }
        break;
    }
  }

  void errorListener(Object obj) {
    if (obj is Exception) {
      throw obj;
    }
  }

  @override
  Future<List<DesktopCapturerSource>> getSources(
      {required List<SourceType> types, ThumbnailSize? thumbnailSize}) async {
    final response = await WebRTC.invokeMethod(
      'getDesktopSources',
      <String, dynamic>{
        'types': types.map((type) => desktopSourceTypeToString[type]).toList(),
        if (thumbnailSize != null) 'thumbnailSize': thumbnailSize.toMap(),
      },
    );
    if (response == null) {
      throw Exception('getDesktopSources return null, something wrong');
    }
    /*
    for (var source in response['sources']) {
      var sourceType = (source['type'] as String) == 'window'
          ? SourceType.Window
          : SourceType.Screen;
      var desktopSource = DesktopCapturerSourceNative(
          source['id'],
          source['name'],
          ThumbnailSize.fromMap(source['thumbnailSize']),
          sourceType);
      desktopSource.thumbnail = source['thumbnail'] as Uint8List;
      _sources[desktopSource.id] = desktopSource;
    }
    */
    return _sources.values.toList();
  }

  @override
  Future<bool> updateSources({required List<SourceType> types}) async {
    final response = await WebRTC.invokeMethod(
      'updateDesktopSources',
      <String, dynamic>{
        'types': types.map((type) => desktopSourceTypeToString[type]).toList(),
      },
    );
    if (response == null) {
      throw Exception('updateSources return null, something wrong');
    }
    return response['result'] as bool;
  }

  Future<Uint8List?> getThumbnail(DesktopCapturerSourceNative source) async {
    final response = await WebRTC.invokeMethod(
      'getDesktopSourceThumbnail',
      <String, dynamic>{
        'sourceId': source.id,
        'thumbnailSize': {
          'width': source.thumbnailSize.width,
          'height': source.thumbnailSize.height
        }
      },
    );
    if (response == null || !response is Uint8List?) {
      throw Exception('getDesktopSourceThumbnail return null, something wrong');
    }
    return response as Uint8List?;
  }
}
