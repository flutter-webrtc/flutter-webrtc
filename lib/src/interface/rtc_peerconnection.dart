import 'enums.dart';
import 'media_stream.dart';
import 'media_stream_track.dart';
import 'rtc_data_channel.dart';
import 'rtc_dtmf_sender.dart';
import 'rtc_ice_candidate.dart';
import 'rtc_rtp_receiver.dart';
import 'rtc_rtp_sender.dart';
import 'rtc_rtp_transceiver.dart';
import 'rtc_session_description.dart';
import 'rtc_stats_report.dart';
import 'rtc_track_event.dart';

typedef SignalingStateCallback = void Function(RTCSignalingState state);
typedef PeerConnectionStateCallback = void Function(
    RTCPeerConnectionState state);
typedef IceGatheringStateCallback = void Function(RTCIceGatheringState state);
typedef IceConnectionStateCallback = void Function(RTCIceConnectionState state);
typedef IceCandidateCallback = void Function(RTCIceCandidate candidate);
typedef AddStreamCallback = void Function(MediaStream stream);
typedef RemoveStreamCallback = void Function(MediaStream stream);
typedef AddTrackCallback = void Function(
    MediaStream stream, MediaStreamTrack track);
typedef RemoveTrackCallback = void Function(
    MediaStream stream, MediaStreamTrack track);
typedef RTCDataChannelCallback = void Function(RTCDataChannel channel);
typedef RenegotiationNeededCallback = void Function();

/// Unified-Plan
typedef UnifiedPlanTrackCallback = void Function(RTCTrackEvent event);

abstract class RTCPeerConnection {
  RTCPeerConnection();

  // public: delegate
  SignalingStateCallback onSignalingState;
  PeerConnectionStateCallback onConnectionState;
  IceGatheringStateCallback onIceGatheringState;
  IceConnectionStateCallback onIceConnectionState;
  IceCandidateCallback onIceCandidate;
  AddStreamCallback onAddStream;
  RemoveStreamCallback onRemoveStream;
  AddTrackCallback onAddTrack;
  RemoveTrackCallback onRemoveTrack;
  RTCDataChannelCallback onDataChannel;
  RenegotiationNeededCallback onRenegotiationNeeded;

  /// Unified-Plan
  UnifiedPlanTrackCallback onTrack;

  RTCSignalingState get signalingState;

  RTCIceGatheringState get iceGatheringState;

  RTCIceConnectionState get iceConnectionState;

  RTCPeerConnectionState get connectionState;

  Future<void> dispose();

  Map<String, dynamic> get getConfiguration;

  Future<void> setConfiguration(Map<String, dynamic> configuration);

  Future<RTCSessionDescription> createOffer([Map<String, dynamic> constraints]);

  Future<RTCSessionDescription> createAnswer(
      [Map<String, dynamic> constraints]);

  Future<void> addStream(MediaStream stream);

  Future<void> removeStream(MediaStream stream);

  Future<RTCSessionDescription> getLocalDescription();
  Future<void> setLocalDescription(RTCSessionDescription description);

  Future<RTCSessionDescription> getRemoteDescription();
  Future<void> setRemoteDescription(RTCSessionDescription description);

  Future<void> addCandidate(RTCIceCandidate candidate);

  Future<List<StatsReport>> getStats([MediaStreamTrack track]);

  List<MediaStream> getLocalStreams();

  List<MediaStream> getRemoteStreams();

  Future<RTCDataChannel> createDataChannel(
      String label, RTCDataChannelInit dataChannelDict);

  Future<void> close();

  RTCDTMFSender createDtmfSender(MediaStreamTrack track);

  /// Unified-Plan.
  List<RTCRtpSender> get senders;

  List<RTCRtpReceiver> get receivers;

  List<RTCRtpTransceiver> get transceivers;

  Future<RTCRtpSender> addTrack(MediaStreamTrack track, [MediaStream stream]);

  Future<bool> removeTrack(RTCRtpSender sender);

  /// 'audio|video', { 'direction': 'recvonly|sendonly|sendrecv' }
  Future<RTCRtpTransceiver> addTransceiver(
      {MediaStreamTrack track,
      RTCRtpMediaType kind,
      RTCRtpTransceiverInit init});
}
