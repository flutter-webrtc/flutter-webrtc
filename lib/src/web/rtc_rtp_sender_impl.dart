import 'dart:async';

import 'package:dart_webrtc/dart_webrtc.dart' as js;
import 'package:flutter/services.dart';

import '../interface/media_stream_track.dart';
import '../interface/rtc_dtmf_sender.dart';
import '../interface/rtc_rtp_parameters.dart';
import '../interface/rtc_rtp_sender.dart';
import 'media_stream_track_impl.dart';
import 'rtc_dtmf_sender_impl.dart';

class RTCRtpSenderWeb extends RTCRtpSender {
  RTCRtpSenderWeb(this._jsRtpSender, this._ownsTrack);

  factory RTCRtpSenderWeb.fromJsSender(js.RTCRtpSender jsRtpSender) {
    return RTCRtpSenderWeb(jsRtpSender, jsRtpSender.track != null);
  }

  js.RTCRtpSender _jsRtpSender;
  bool _ownsTrack = false;

  js.RTCRtpSender get jsSender => _jsRtpSender;

  @override
  Future<bool> setParameters(RTCRtpParameters parameters) async {
    try {
      return _jsRtpSender
          .setParameters(js.rtpEncodingParametersFromMap(parameters.toMap()));
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpSender::setParameters: ${e.message}';
    }
  }

  @override
  Future<void> replaceTrack(MediaStreamTrack track) async {
    try {
      var nativeTrack = track as MediaStreamTrackWeb;
      _jsRtpSender.replaceTrack(nativeTrack.jsTrack);
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpSender::replaceTrack: ${e.message}';
    }
  }

  @override
  Future<void> setTrack(MediaStreamTrack track,
      {bool takeOwnership = true}) async {
    try {
      var nativeTrack = track as MediaStreamTrackWeb;
      _jsRtpSender.replaceTrack(nativeTrack.jsTrack);
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpSender::setTrack: ${e.message}';
    }
  }

  @override
  RTCRtpParameters get parameters => RTCRtpParameters.fromMap(
      js.rtpEncodingParametersToMap(_jsRtpSender.getParameters()));

  @override
  MediaStreamTrack get track => MediaStreamTrackWeb(_jsRtpSender.track);

  @override
  String get senderId => _jsRtpSender?.track?.id ?? '';

  @override
  bool get ownsTrack => _ownsTrack;

  @override
  RTCDTMFSender get dtmfSender => RTCDTMFSenderWeb(_jsRtpSender.dtmf);

  @override
  Future<void> dispose() async {}
}
