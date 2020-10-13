import 'dart:async';

import 'package:flutter/material.dart';

import 'media_stream_track.dart';
import 'rtc_dtmf_sender.dart';
import 'rtc_rtp_parameters.dart';

abstract class RTCRtpSender {
  RTCRtpSender();

  Future<bool> setParameters(RTCRtpParameters parameters);

  Future<void> replaceTrack(MediaStreamTrack track);

  Future<void> setTrack(MediaStreamTrack track, {bool takeOwnership = true});

  RTCRtpParameters get parameters;

  MediaStreamTrack get track;

  String get senderId;

  bool get ownsTrack;

  RTCDTMFSender get dtmfSender;

  @mustCallSuper
  Future<void> dispose();
}
