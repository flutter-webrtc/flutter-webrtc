import 'dart:async';

import 'enums.dart';
import 'media_stream.dart';
import 'media_stream_track.dart';
import 'rtc_ice_candidate.dart';
import 'rtc_rtp_receiver.dart';
import 'rtc_rtp_sender.dart';
import 'rtc_rtp_transceiver.dart';
import 'rtc_session_description.dart';
import 'rtc_stats_report.dart';
import 'rtc_track_event.dart';

abstract class RTCPeerConnection {
  RTCPeerConnection();

  // public: delegate
  void Function(RTCSignalingState state)? onSignalingState;
  void Function(RTCPeerConnectionState state)? onConnectionState;
  void Function(RTCIceGatheringState state)? onIceGatheringState;
  void Function(RTCIceConnectionState state)? onIceConnectionState;
  void Function(RTCIceCandidate candidate)? onIceCandidate;
  void Function()? onRenegotiationNeeded;
  void Function(RTCTrackEvent event)? onTrack;

  RTCSignalingState? get signalingState;

  RTCIceGatheringState? get iceGatheringState;

  RTCIceConnectionState? get iceConnectionState;

  RTCPeerConnectionState? get connectionState;

  Future<void> dispose();

  Map<String, dynamic> get getConfiguration;

  Future<void> setConfiguration(Map<String, dynamic> configuration);

  Future<RTCSessionDescription> createOffer([Map<String, dynamic> constraints]);

  Future<RTCSessionDescription> createAnswer(
      [Map<String, dynamic> constraints]);

  Future<RTCSessionDescription?> getLocalDescription();

  Future<void> setLocalDescription(RTCSessionDescription description);

  Future<RTCSessionDescription?> getRemoteDescription();

  Future<void> setRemoteDescription(RTCSessionDescription description);

  Future<void> addCandidate(RTCIceCandidate candidate);

  Future<List<StatsReport>> getStats([MediaStreamTrack? track]);

  Future<void> close();

  /// Unified-Plan.
  Future<List<RTCRtpSender>> getSenders();

  Future<List<RTCRtpSender>> get senders => getSenders();

  Future<List<RTCRtpReceiver>> getReceivers();

  Future<List<RTCRtpReceiver>> get receivers => getReceivers();

  Future<List<RTCRtpTransceiver>> getTransceivers();

  Future<List<RTCRtpTransceiver>> get transceivers => getTransceivers();

  Future<RTCRtpSender> addTrack(MediaStreamTrack track, [MediaStream stream]);

  Future<bool> removeTrack(RTCRtpSender sender);

  /// 'audio|video', { 'direction': 'recvonly|sendonly|sendrecv' }
  Future<RTCRtpTransceiver> addTransceiver(
      {MediaStreamTrack track,
      RTCRtpMediaType kind,
      RTCRtpTransceiverInit init});
}
