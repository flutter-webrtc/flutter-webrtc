import 'model/rtc_dtmf_sender.dart';
import 'utils.dart';

class RTCDTMFSenderNative extends RTCDTMFSender {
  RTCDTMFSenderNative(this._peerConnectionId);
  // peer connection Id must be defined as a variable where this function will be called.
  final String _peerConnectionId;
  final _channel = WebRTC.methodChannel();

  @override
  Future<void> sendDtmf(String tones,
      {int duration = 100, int interToneGap = 70}) async {
    await _channel.invokeMethod('sendDtmf', <String, dynamic>{
      'peerConnectionId': _peerConnectionId,
      'tone': tones,
      'duration': duration,
      'gap': interToneGap,
    });
  }
}
