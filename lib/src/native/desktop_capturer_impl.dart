import 'dart:typed_data';

import '../desktop_capturer.dart';
import 'utils.dart';

class DesktopCapturerSourceNative extends DesktopCapturerSource {
  DesktopCapturerSourceNative(
      this._id, this._name, this._thumbnailSize, this._type);
  Function(String name)? onNameChanged;
  Function()? onRemoved;
  Function()? onThumbnailChanged;

  Uint8List? _thumbnail;
  final String _id;
  final String _name;
  final ThumbnailSize _thumbnailSize;
  final SourceType _type;

  set thumbnail(Uint8List? value) {
    _thumbnail = value;
    onThumbnailChanged?.call();
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
  DesktopCapturerNative._internal();
  static final DesktopCapturerNative instance =
      DesktopCapturerNative._internal();

  @override
  Future<List<DesktopCapturerSource>> getSources(
      {required List<SourceType> types, ThumbnailSize? thumbnailSize}) async {
    final response = await WebRTC.invokeMethod(
      'getDesktopSources',
      <String, dynamic>{
        'types': types.map((type) => desktopSourceTypeToString[type]).toList()
      },
    );
    if (response == null) {
      throw Exception('getDesktopSources return null, something wrong');
    }
    var sources = <DesktopCapturerSourceNative>[];
    for (var source in response['sources']) {
      var sourceType = (source['type'] as String) == 'window'
          ? SourceType.Window
          : SourceType.Screen;
      var desktopSource = DesktopCapturerSourceNative(
          source['id'],
          source['name'],
          ThumbnailSize.fromMap(source['thumbnailSize']),
          sourceType);
      try {
        desktopSource.thumbnail = await getThumbnail(desktopSource);
      } catch (e) {
        print(e);
      }

      sources.add(desktopSource);
    }
    return sources;
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
    if (response == null) {
      throw Exception('getDesktopSourceThumbnail return null, something wrong');
    }
    return response as Uint8List?;
  }
}
