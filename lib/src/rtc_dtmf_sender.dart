import 'package:flutter/services.dart';

import 'utils.dart';

class RTCDTMFSender {
  RTCDTMFSender(this._peerConnectionId);
  // peer connection Id must be defined as a variable where this function will be called.
  final String _peerConnectionId;
  final MethodChannel _channel = WebRTC.methodChannel();

  ///  tones:A String containing the DTMF codes to be transmitted to the recipient.
  ///          Specifying an empty string as the tones parameter clears the tone
  ///          buffer, aborting any currently queued tones. A "," character inserts
  ///          a two second delay.
  ///  duration: This value must be between 40 ms and 6000 ms (6 seconds).
  ///          The default is 100 ms.
  ///  interToneGap: The length of time, in milliseconds, to wait between tones.
  ///          The browser will enforce a minimum value of 30 ms (that is,
  ///          if you specify a lower value, 30 ms will be used instead);
  ///          the default is 70 ms.
  Future<void> insertDTMF(String tones,
      {int duration = 100, int interToneGap = 70}) async {
    await _channel.invokeMethod('sendDtmf', <String, dynamic>{
      'peerConnectionId': _peerConnectionId,
      'tone': tones,
      'duration': duration,
      'gap': interToneGap,
    });
  }
}
