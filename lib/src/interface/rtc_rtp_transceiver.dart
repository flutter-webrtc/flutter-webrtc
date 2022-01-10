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
  TransceiverDirection? direction;
  List<MediaStream>? streams;
  List<RTCRtpEncoding>? sendEncodings;
}

abstract class RTCRtpTransceiver {
  RTCRtpTransceiver();

  Future<TransceiverDirection?> getCurrentDirection();

  Future<void> setDirection(TransceiverDirection direction);

  Future<TransceiverDirection> getDirection();

  Future<void> sync();

  String? get mid;

  RTCRtpSender get sender;

  RTCRtpReceiver get receiver;

  bool get stoped;

  Future<void> stop();

  /// Deprecated methods.
  @Deprecated('Use the `await getCurrentDirection` instead')
  TransceiverDirection get currentDirection => throw UnimplementedError(
      'Need to be call asynchronously from native sdk, so the method is deprecated');
}
