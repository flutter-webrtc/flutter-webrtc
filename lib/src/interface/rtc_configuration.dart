abstract class RTCConfiguration {
  RTCConfiguration(
      {this.iceServers,
      this.bundlePolicy,
      this.iceTransportPolicy,
      this.rtcpMuxPolicy,
      this.sdpSemantics,
      this.certificates});
  RTCBundlePolicy bundlePolicy;
  RTCCertificate certificates;
  List<IceServer> iceServers;
  RTCIceTransportPolicy iceTransportPolicy;
  RTCRtcpMuxPolicy rtcpMuxPolicy;
  RTCSdpSemantics sdpSemantics;
}

enum RTCSdpSemantics { PlanB, UnifiedPlan }

enum RTCBundlePolicy {
  BundlePolicyBalanced,
  BundlePolicyMaxBundle,
  BundlePolicyMaxCompat
}

enum RTCIceTransportPolicy { All, Relay }

enum RTCRtcpMuxPolicy {
  RtcpMuxPolicyNegotiate,
  RtcpMuxPolicyRequire,
}

class IceServer {
  IceServer({this.urls, this.username, this.credential, this.credentialType});
  RTCIceCredentialType credentialType;
  var username;
  var credential;
  List<String> urls; //: ["stun:stun.example.com", "stun:stun-1.example.com"]
}

enum RTCIceCredentialType { OAuth, Password }

class RTCCertificate {
  RTCCertificate({this.expires});
  var expires;
}

class RTCOfferOptions {
  RTCOfferOptions(
      {this.offerToReceiveAudio, this.offerToReceiveVideo, this.iceRestart});
  bool iceRestart;
  bool offerToReceiveAudio;
  bool offerToReceiveVideo;
}

class RTCAnswerOptions {
  RTCAnswerOptions({this.iceRestart});
  bool iceRestart;
}
