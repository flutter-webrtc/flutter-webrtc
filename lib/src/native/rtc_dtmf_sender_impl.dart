import '../interface/rtc_dtmf_sender.dart';
import 'utils.dart';

class RTCDTMFSenderNative extends RTCDTMFSender {
  RTCDTMFSenderNative(this._peerConnectionId, this._rtpSenderId);
  // peer connection Id must be defined as a variable where this function will be called.
  final String _peerConnectionId;
  final String _rtpSenderId;
  final _channel = WebRTC.methodChannel();

  @override
  Future<void> insertDTMF(String tones,
      {int duration = 100, int interToneGap = 70}) async {
    await _channel.invokeMethod('sendDtmf', <String, dynamic>{
      'peerConnectionId': _peerConnectionId,
      'rtpSenderId': _rtpSenderId,
      'tone': tones,
      'duration': duration,
      'gap': interToneGap,
    });
  }

  @override
  Future<bool> canInsertDtmf() async {
    return await _channel.invokeMethod('canInsertDtmf', <String, dynamic>{
      'peerConnectionId': _peerConnectionId,
      'rtpSenderId': _rtpSenderId
    });
  }
}
