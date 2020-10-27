import 'dart:html' as html;
import 'dart:js';

import '../interface/rtc_dtmf_sender.dart';

class RTCDTMFSenderWeb extends RTCDTMFSender {
  RTCDTMFSenderWeb(this._jsDtmfSender);
  factory RTCDTMFSenderWeb.fromJsObject(String pcId, Object jsObject) {
    return RTCDTMFSenderWeb(null);
  }
  final html.RtcDtmfSender _jsDtmfSender;
  Object _jsObj;

  @override
  Future<void> insertDTMF(String tones,
      {int duration = 100, int interToneGap = 70}) async {
    return _jsDtmfSender.insertDtmf(tones, duration, interToneGap);
  }
}
