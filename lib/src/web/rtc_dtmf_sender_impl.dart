import 'dart:html' as html;

import '../interface/rtc_dtmf_sender.dart';

class RTCDTMFSenderWeb extends RTCDTMFSender {
  RTCDTMFSenderWeb(this._jsDtmfSender);
  final html.RtcDtmfSender _jsDtmfSender;

  @override
  Future<void> insertDTMF(String tones,
      {int duration = 100, int interToneGap = 70}) async {
    return _jsDtmfSender.insertDtmf(tones, duration, interToneGap);
  }

  @override
  Future<bool> canInsertDtmf() async {
    return _jsDtmfSender.canInsertDtmf;
  }
}
