import 'rtc_rtp_parameters.dart';
import 'rtc_rtp_sender.dart';
import 'rtc_rtp_receiver.dart';

enum RTCRtpTransceiverDirection {
  RTCRtpTransceiverDirectionSendRecv,
  RTCRtpTransceiverDirectionSendOnly,
  RTCRtpTransceiverDirectionRecvOnly,
  RTCRtpTransceiverDirectionInactive,
}

final typeStringToRtpTransceiverDirection = <String, RTCRtpTransceiverDirection>{
  'sendrecv': RTCRtpTransceiverDirection.RTCRtpTransceiverDirectionSendRecv,
  'sendonly': RTCRtpTransceiverDirection.RTCRtpTransceiverDirectionSendOnly,
  'recvonly': RTCRtpTransceiverDirection.RTCRtpTransceiverDirectionRecvOnly,
  'inactive': RTCRtpTransceiverDirection.RTCRtpTransceiverDirectionInactive,
};

class RTCRtpTransceiverInit {
  RTCRtpTransceiverDirection direction;
  List<String> streamIds;
  List<RTCRtpEncoding> sendEncodings;

  Map<String, dynamic> toMap() {
    return Map();
  }

  factory RTCRtpTransceiverInit.fromMap(Map<String, dynamic> map) {
  }

  RTCRtpTransceiverInit(this.direction, this.streamIds, this.sendEncodings);
}

class RTCRtpTransceiver {
  String _transceiverId;
  bool _stop;
  RTCRtpTransceiverDirection _direction;
  String _mid;
  RTCRtpSender _sender;
  RTCRtpReceiver _receiver;

  factory RTCRtpTransceiver.fromMap(Map<String,dynamic> map) {
        RTCRtpTransceiver transceiver = RTCRtpTransceiver(
        map['transceiverId'],
        typeStringToRtpTransceiverDirection[map['direction']],
        map['mid'],
        RTCRtpSender.fromMap(map["senderInfo"]),
        RTCRtpReceiver.fromMap(map['receiverInfo']));
    return transceiver;
  }

  RTCRtpTransceiver(this._transceiverId, this._direction, this._mid,
      this._sender, this._receiver);

  RTCRtpTransceiverDirection get currentDirection => _direction;

  String get mid => _mid;

  RTCRtpSender get sender => _sender;

  RTCRtpReceiver get receiver => _receiver;

  bool get stoped => _stop;

  void stop() {}
}
