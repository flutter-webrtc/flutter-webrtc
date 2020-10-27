import 'dart:async';
import 'dart:js_util' as jsutil;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../interface/media_stream_track.dart';
import '../interface/rtc_dtmf_sender.dart';
import '../interface/rtc_rtp_parameters.dart';
import '../interface/rtc_rtp_sender.dart';
import 'media_stream_track_impl.dart';
import 'rtc_dtmf_sender_impl.dart';
import 'utils.dart';

class RTCRtpSenderWeb extends RTCRtpSender {
  RTCRtpSenderWeb(this._id, this._track, this._dtmf, this._parameters,
      this._ownsTrack, this._peerConnectionId);

  factory RTCRtpSenderWeb.fromJsObject(Object jsObject,
      {String peerConnectionId}) {
    var params = jsutil.callMethod(jsObject, 'getParameters', []);
    Map rtpParameters = convertToDart(params);
    var senderId = '';
    var ownsTrack = false;
    return RTCRtpSenderWeb(
        senderId,
        MediaStreamTrackWeb.fromJsObject(jsutil.getProperty(jsObject, 'track')),
        RTCDTMFSenderWeb.fromJsObject(
            peerConnectionId, jsutil.getProperty(jsObject, 'sender')),
        RTCRtpParameters.fromMap(rtpParameters ?? {}),
        ownsTrack,
        peerConnectionId);
  }

  final MethodChannel _channel = WebRTC.methodChannel();
  String _peerConnectionId;
  String _id;
  MediaStreamTrack _track;
  RTCDTMFSender _dtmf;
  RTCRtpParameters _parameters;
  bool _ownsTrack = false;

  set peerConnectionId(String id) {
    _peerConnectionId = id;
  }

  @override
  Future<bool> setParameters(RTCRtpParameters parameters) async {
    _parameters = parameters;
    try {
      final response = await _channel
          .invokeMethod('rtpSenderSetParameters', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'rtpSenderId': _id,
        'parameters': parameters.toMap()
      });
      return response['result'];
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpSender::setParameters: ${e.message}';
    }
  }

  @override
  Future<void> replaceTrack(MediaStreamTrack track) async {
    try {
      await _channel.invokeMethod('rtpSenderReplaceTrack', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'rtpSenderId': _id,
        'trackId': track.id
      });
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpSender::replaceTrack: ${e.message}';
    }
  }

  @override
  Future<void> setTrack(MediaStreamTrack track,
      {bool takeOwnership = true}) async {
    try {
      await _channel.invokeMethod('rtpSenderSetTrack', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'rtpSenderId': _id,
        'trackId': track.id,
        'takeOwnership': takeOwnership,
      });
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpSender::setTrack: ${e.message}';
    }
  }

  @override
  RTCRtpParameters get parameters => _parameters;

  @override
  MediaStreamTrack get track => _track;

  @override
  String get senderId => _id;

  @override
  bool get ownsTrack => _ownsTrack;

  @override
  RTCDTMFSender get dtmfSender => _dtmf;

  @override
  @mustCallSuper
  Future<void> dispose() async {
    try {
      await _channel.invokeMethod('rtpSenderDispose', <String, dynamic>{
        'peerConnectionId': _peerConnectionId,
        'rtpSenderId': _id,
      });
    } on PlatformException catch (e) {
      throw 'Unable to RTCRtpSender::setTrack: ${e.message}';
    }
  }
}
