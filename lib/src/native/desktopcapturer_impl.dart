import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

import 'package:webrtc_interface/webrtc_interface.dart';
import 'utils.dart';

class DesktopCapturerSourceNative implements DesktopCapturerSource {

  DesktopCapturerSourceNative(this.id_, this.name_, this.type_);

  factory DesktopCapturerSourceNative.fromMap(Map<dynamic, dynamic> map) {
    return DesktopCapturerSourceNative(
        map['id'],
        map['name'],
        map['type'] == 0 ? SourceType.kWindow : SourceType.kScreen);
  }

  String id_;
  String name_;
  Uint8List bytes = Uint8List.fromList([1, 0, 0, 128]);
  ThumbnailSize thumbnailSize_ = ThumbnailSize(0, 0);
  SourceType type_;

  @override
  String get id => id_;

  @override
  String get name => name_;

  @override
  Uint8List get thumbnail => bytes;

  @override
  ThumbnailSize get thumbnailSize => thumbnailSize_;

  @override
  SourceType get type => type_;

}

class DesktopCapturerNative implements DesktopCapturer {

  Future<List<DesktopCapturerSourceNative>> _enumerateScreens() async {
    try {
      final response = await WebRTC.invokeMethod(
        'enumerateScreens',
      );
      if (response == null) {
        throw Exception('enumerateScreens return null, something wrong');
      }

      return (response as List<dynamic>)
          .map((e) => DesktopCapturerSourceNative.fromMap(e))
          .toList();

    } on PlatformException catch (e) {
      throw 'Unable to enumerateScreens: ${e.message}';
    }
  }

  Future<List<DesktopCapturerSourceNative>> _enumerateWindows() async {
    try {
      final response = await WebRTC.invokeMethod(
        'enumerateWindows',
      );
      if (response == null) {
        throw Exception('enumerateWindows return null, something wrong');
      }

      return (response as List<dynamic>)
          .map((e) => DesktopCapturerSourceNative.fromMap(e))
          .toList();

    } on PlatformException catch (e) {
      throw 'Unable to enumerateWindows: ${e.message}';
    }
  }

  @override
  Future<List<DesktopCapturerSource>> getSources({required List<SourceType> types, ThumbnailSize? thumbnailSize}) async {

    if (!WebRTC.platformIsWindows) {
      throw UnimplementedError();
    }

    var screens = List<DesktopCapturerSource>.empty(growable: true);
    if (types.contains(SourceType.kScreen)) {
      await _enumerateScreens();
    }

    var windows = List<DesktopCapturerSource>.empty(growable: true);
    if (types.contains(SourceType.kWindow)) {
      windows.addAll(await _enumerateWindows());
    }

    return List.from(screens)..addAll(windows);
  }
}