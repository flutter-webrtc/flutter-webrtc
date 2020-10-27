import 'dart:async';

import 'enums.dart';
import 'media_stream.dart';
import 'rtc_rtp_parameters.dart';
import 'rtc_rtp_receiver.dart';
import 'rtc_rtp_sender.dart';

List<RTCRtpEncoding> listToRtpEncodings(List<Map<String, dynamic>> list) {
  return list.map((e) => RTCRtpEncoding.fromMap(e)).toList();
}

class RTCRtpTransceiverInit {
  RTCRtpTransceiverInit({
    this.direction,
    this.streams,
    this.sendEncodings,
  });
  TransceiverDirection direction;
  List<MediaStream> streams;
  List<RTCRtpEncoding> sendEncodings;

  static Map<String, dynamic> initToMap(RTCRtpTransceiverInit init) {
    return {
      'direction': typeRtpTransceiverDirectionToString[init.direction],
      if (init.streams != null)
        'streamIds': init.streams.map((e) => e.id).toList(),
      if (init.sendEncodings != null)
        'sendEncodings': init.sendEncodings.map((e) => e.toMap()).toList(),
    };
  }
}

abstract class RTCRtpTransceiver {
  RTCRtpTransceiver();

  TransceiverDirection get currentDirection;

  String get mid;

  RTCRtpSender get sender;

  RTCRtpReceiver get receiver;

  bool get stoped;

  String get transceiverId;

  Future<void> setDirection(TransceiverDirection direction);

  Future<TransceiverDirection> getCurrentDirection();

  Future<void> stop();
}
