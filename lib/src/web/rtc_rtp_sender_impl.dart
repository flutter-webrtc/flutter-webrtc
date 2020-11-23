import 'dart:async';
import 'dart:html';
import 'dart:js_util' as jsutil;

import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../interface/media_stream_track.dart';
import '../interface/rtc_dtmf_sender.dart';
import '../interface/rtc_rtp_parameters.dart';
import '../interface/rtc_rtp_sender.dart';
import 'media_stream_track_impl.dart';
import 'rtc_dtmf_sender_impl.dart';
import 'rtc_rtp_parameters_impl.dart';

class RTCRtpSenderWeb extends RTCRtpSender {
  RTCRtpSenderWeb(this._jsRtpSender, this._ownsTrack);

  factory RTCRtpSenderWeb.fromJsSender(RtcRtpSender jsRtpSender) {
    return RTCRtpSenderWeb(jsRtpSender, jsRtpSender.track != null);
  }

  RtcRtpSender _jsRtpSender;
  bool _ownsTrack = false;

  @override
  Future<void> replaceTrack(MediaStreamTrack track) async {
    try {
      var nativeTrack = track as MediaStreamTrackWeb;
      jsutil.callMethod(_jsRtpSender, 'replaceTrack', [nativeTrack.jsTrack]);
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpSender::replaceTrack: ${e.message}';
    }
  }

  @override
  Future<void> setTrack(MediaStreamTrack track,
      {bool takeOwnership = true}) async {
    try {
      var nativeTrack = track as MediaStreamTrackWeb;
      jsutil.callMethod(_jsRtpSender, 'replaceTrack', [nativeTrack.jsTrack]);
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpSender::setTrack: ${e.message}';
    }
  }

  @override
  RTCRtpParameters get parameters {
    var parameters = jsutil.callMethod(_jsRtpSender, 'getParameters', []);
    return RTCRtpParametersWeb.fromJsObject(parameters);
  }

  @override
  Future<bool> setParameters(RTCRtpParameters parameters) async {
    try {
      var oldParameters = jsutil.callMethod(_jsRtpSender, 'getParameters', []);
      jsutil.setProperty(oldParameters, 'encodings',
          jsutil.jsify(parameters.encodings.map((e) => e.toMap()).toList()));
      return await jsutil.promiseToFuture<bool>(
          jsutil.callMethod(_jsRtpSender, 'setParameters', [oldParameters]));
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpSender::setParameters: ${e.message}';
    }
  }

  @override
  Future<List<StatsReport>> getStats() async {
    var stats = await jsutil.promiseToFuture<dynamic>(
        jsutil.callMethod(_jsRtpSender, 'getStats', []));
    var report = <StatsReport>[];
    stats.forEach((key, value) {
      report.add(
          StatsReport(value['id'], value['type'], value['timestamp'], value));
    });
    return report;
  }

  @override
  MediaStreamTrack get track =>
      MediaStreamTrackWeb(jsutil.getProperty(_jsRtpSender, 'track'));

  @override
  String get senderId => jsutil.getProperty(_jsRtpSender, 'senderId');

  @override
  bool get ownsTrack => _ownsTrack;

  @override
  RTCDTMFSender get dtmfSender =>
      RTCDTMFSenderWeb(jsutil.getProperty(_jsRtpSender, 'dtmf'));

  @override
  Future<void> dispose() async {}
}
