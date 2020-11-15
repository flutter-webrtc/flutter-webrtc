import 'package:dart_webrtc/dart_webrtc.dart' as dart_webrtc;

import '../interface/rtc_dtmf_sender.dart';

class RTCDTMFSenderWeb extends RTCDTMFSender {
  RTCDTMFSenderWeb(this._jsDtmfSender);
  final dart_webrtc.RTCDTMFSender _jsDtmfSender;

  @override
  Future<void> insertDTMF(String tones,
      {int duration = 100, int interToneGap = 70}) async {
    return _jsDtmfSender.insertDTMF(tones, duration, interToneGap);
  }
}
