import 'rtc_degradation_preference.dart';
import 'rtc_ice_server.dart'; // Assuming this file will exist or be created for RTCIceServer
import 'rtc_ice_transport_policy.dart'; // Assuming for IceTransportPolicy
import 'rtc_bundle_policy.dart'; // Assuming for BundlePolicy
import 'rtc_rtcp_mux_policy.dart'; // Assuming for RtcpMuxPolicy
import 'rtc_peer_identity.dart'; // Assuming for PeerIdentity
import 'rtc_certificate.dart'; // Assuming for RTCCertificate
import 'rtc_ice_candidate_enums.dart'; // Import new enums

class RTCConfiguration {
  List<RTCIceServer>? iceServers;
  RTCIceTransportPolicy? iceTransportPolicy;
  RTCBundlePolicy? bundlePolicy;
    RTCRtcpMuxPolicy? rtcpMuxPolicy;
    List<RTCPeerIdentity>? peerIdentities;
    List<RTCCertificate>? certificates;
    int? iceCandidatePoolSize;
    String? sdpSemantics; // Usually 'unified-plan' or 'plan-b'
    RTCDegradationPreference? degradationPreference;
    bool? hardwareAcceleration;
  List<RTCIceCandidateType>? allowedIceCandidateTypes;
  List<RTCIceProtocol>? allowedIceProtocols;
  int? iceGatheringTimeoutSeconds; // New field

  RTCConfiguration({
    this.iceServers,
    this.iceTransportPolicy,
    this.bundlePolicy,
    this.rtcpMuxPolicy,
    this.peerIdentities,
    this.certificates,
    this.iceCandidatePoolSize,
    this.sdpSemantics,
    this.degradationPreference,
    this.hardwareAcceleration,
    this.allowedIceCandidateTypes,
    this.allowedIceProtocols,
    this.iceGatheringTimeoutSeconds, // Added here
  });

  factory RTCConfiguration.fromMap(Map<String, dynamic> map) {
    return RTCConfiguration(
      iceServers: (map['iceServers'] as List<dynamic>?)
          ?.map((e) => RTCIceServer.fromMap(e as Map<String, dynamic>))
          .toList(),
      iceTransportPolicy: map['iceTransportPolicy'] != null
          ? RTCIceTransportPolicy.values.firstWhere(
              (e) => e.toString().split('.').last == map['iceTransportPolicy'])
          : null,
      bundlePolicy: map['bundlePolicy'] != null
          ? RTCBundlePolicy.values.firstWhere(
              (e) => e.toString().split('.').last == map['bundlePolicy'])
          : null,
      rtcpMuxPolicy: map['rtcpMuxPolicy'] != null
          ? RTCRtcpMuxPolicy.values.firstWhere(
              (e) => e.toString().split('.').last == map['rtcpMuxPolicy'])
          : null,
      peerIdentities: (map['peerIdentities'] as List<dynamic>?)
          ?.map((e) => RTCPeerIdentity.fromMap(e as Map<String, dynamic>))
          .toList(),
      certificates: (map['certificates'] as List<dynamic>?)
          ?.map((e) => RTCCertificate.fromMap(e as Map<String, dynamic>))
          .toList(),
      iceCandidatePoolSize: map['iceCandidatePoolSize'] as int?,
      sdpSemantics: map['sdpSemantics'] as String?,
      degradationPreference: map['degradationPreference'] != null
          ? rtcDegradationPreferencefromString(map['degradationPreference'] as String?)
          : null,
      hardwareAcceleration: map['hardwareAcceleration'] as bool?,
      allowedIceCandidateTypes: (map['allowedIceCandidateTypes'] as List<dynamic>?)
          ?.map((e) => rtcIceCandidateTypeFromString(e as String))
          .whereType<RTCIceCandidateType>() // Filters out nulls if any string is invalid
          .toList(),
      allowedIceProtocols: (map['allowedIceProtocols'] as List<dynamic>?)
          ?.map((e) => rtcIceProtocolFromString(e as String))
          .whereType<RTCIceProtocol>()
          .toList(),
      iceGatheringTimeoutSeconds: map['iceGatheringTimeoutSeconds'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'iceServers': iceServers?.map((e) => e.toMap()).toList(),
      'iceTransportPolicy': iceTransportPolicy?.toString().split('.').last,
      'bundlePolicy': bundlePolicy?.toString().split('.').last,
      'rtcpMuxPolicy': rtcpMuxPolicy?.toString().split('.').last,
      'peerIdentities': peerIdentities?.map((e) => e.toMap()).toList(),
      'certificates': certificates?.map((e) => e.toMap()).toList(),
      'iceCandidatePoolSize': iceCandidatePoolSize,
      if (sdpSemantics != null) 'sdpSemantics': sdpSemantics,
      if (degradationPreference != null)
        'degradationPreference':
            rtcDegradationPreferenceToString(degradationPreference),
      if (hardwareAcceleration != null) 'hardwareAcceleration': hardwareAcceleration,
      if (allowedIceCandidateTypes != null && allowedIceCandidateTypes!.isNotEmpty)
        'allowedIceCandidateTypes': allowedIceCandidateTypes!
            .map((e) => rtcIceCandidateTypeToString(e))
            .toList(),
      if (allowedIceProtocols != null && allowedIceProtocols!.isNotEmpty)
        'allowedIceProtocols': allowedIceProtocols!
            .map((e) => rtcIceProtocolToString(e))
            .toList(),
      if (iceGatheringTimeoutSeconds != null && iceGatheringTimeoutSeconds! > 0)
        'iceGatheringTimeoutSeconds': iceGatheringTimeoutSeconds,
    };
  }
}
