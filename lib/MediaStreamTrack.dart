import 'package:flutter/services.dart';
import 'package:webrtc/WebRTC.dart';

class MediaStreamTrack {
    MethodChannel _channel;
    int _trackId;
    MediaStreamTrack() {
        _channel = WebRTC.methodChannel();
    }
   set enabled(bool enabled){
       _channel.invokeMethod('mediaStreamTrackEnabled',
        <String, dynamic>{'trackId':_trackId,'enabled': enabled });
   }
   bool get enabled => false;
   String get label => '';
   String get kind => '';
   String get id => '';
}