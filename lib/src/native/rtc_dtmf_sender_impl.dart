import 'package:webrtc_interface/webrtc_interface.dart';

import 'utils.dart';

class RTCDTMFSenderNative extends RTCDTMFSender {
  RTCDTMFSenderNative(this._peerConnectionId, this._rtpSenderId);
  // peer connection Id must be defined as a variable where this function will be called.
  final String _peerConnectionId;
  final String _rtpSenderId;

  @override
  Future<void> insertDTMF(String tones,
      {int duration = 100, int interToneGap = 70}) async {
    await WebRTC.invokeMethod('sendDtmf', <String, dynamic>{
      'peerConnectionId': _peerConnectionId,
      'rtpSenderId': _rtpSenderId,
      'tone': tones,
      'duration': duration,
      'gap': interToneGap,
    });
  }

  @override
  Future<bool> canInsertDtmf() async {
    return await WebRTC.invokeMethod('canInsertDtmf', <String, dynamic>{
      'peerConnectionId': _peerConnectionId,
      'rtpSenderId': _rtpSenderId
    });
  }
}
