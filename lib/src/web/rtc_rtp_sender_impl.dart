import 'dart:async';

import 'dart:js_util' as jsutil;
import 'package:flutter/services.dart';

import '../interface/media_stream_track.dart';
import '../interface/rtc_dtmf_sender.dart';
import '../interface/rtc_rtp_parameters.dart';
import '../interface/rtc_rtp_sender.dart';
import 'media_stream_track_impl.dart';
import 'rtc_dtmf_sender_impl.dart';

class RTCRtpSenderWeb extends RTCRtpSender {
  RTCRtpSenderWeb(this._jsRtpSender, this._ownsTrack);

  factory RTCRtpSenderWeb.fromJsSender(Object jsRtpSender) {
    return RTCRtpSenderWeb(
        jsRtpSender, jsutil.getProperty(jsRtpSender, 'track') != null);
  }

  Object _jsRtpSender;
  bool _ownsTrack = false;

  Object get jsSender => _jsRtpSender;

  @override
  Future<bool> setParameters(RTCRtpParameters parameters) async {
    try {
      var jsParameters = jsutil.callMethod(_jsRtpSender, 'getParameters', []);

      //TODO:
      //jsParameters.encodings
      //    .addAll(rtpEncodingParametersFromMap(parameters.toMap()).encodings);
      return await jsutil.promiseToFuture<bool>(jsutil.callMethod(
          _jsRtpSender, 'setParameters', [jsutil.jsify(jsParameters)]));
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpSender::setParameters: ${e.message}';
    }
  }

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
  RTCRtpParameters get parameters => RTCRtpParameters.fromMap(
      jsutil.callMethod(_jsRtpSender, 'getParameters', []));

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
