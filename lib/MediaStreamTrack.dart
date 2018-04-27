import 'package:flutter/services.dart';
import 'package:webrtc/WebRTC.dart';

class MediaStreamTrack {
    MethodChannel _channel;
    int _textureId;
    MediaStreamTrack() {
        _channel = WebRTC.methodChannel();
    }
   set enabled(bool enabled){
       _channel.invokeMethod('mediaStreamTrackEnabled',
        <String, dynamic>{'textureId':_textureId,'enabled': enabled });
   }
   bool get enabled => false;
   String get label => '';
   String get kind => '';
   String get id => '';
}