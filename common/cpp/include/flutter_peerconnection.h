#ifndef FLUTTER_WEBRTC_RTC_PEER_CONNECTION_HXX
#define FLUTTER_WEBRTC_RTC_PEER_CONNECTION_HXX

#include "flutter_common.h"
#include "flutter_webrtc_base.h"

namespace flutter_webrtc_plugin {

class FlutterPeerConnectionObserver : public RTCPeerConnectionObserver {
 public:
  FlutterPeerConnectionObserver(FlutterWebRTCBase* base,
                                scoped_refptr<RTCPeerConnection> peerconnection,
                                BinaryMessenger* messenger,
                                const std::string& channel_name,
                                std::string& peerConnectionId);

  virtual void OnSignalingState(RTCSignalingState state) override;
  virtual void OnPeerConnectionState(RTCPeerConnectionState state) override;
  virtual void OnIceGatheringState(RTCIceGatheringState state) override;
  virtual void OnIceConnectionState(RTCIceConnectionState state) override;
  virtual void OnIceCandidate(
      scoped_refptr<RTCIceCandidate> candidate) override;
  virtual void OnAddStream(scoped_refptr<RTCMediaStream> stream) override;
  virtual void OnRemoveStream(scoped_refptr<RTCMediaStream> stream) override;

  virtual void OnTrack(scoped_refptr<RTCRtpTransceiver> transceiver) override;
  virtual void OnAddTrack(vector<scoped_refptr<RTCMediaStream>> streams,
                          scoped_refptr<RTCRtpReceiver> receiver) override;
  virtual void OnRemoveTrack(scoped_refptr<RTCRtpReceiver> receiver) override;
  virtual void OnDataChannel(
      scoped_refptr<RTCDataChannel> data_channel) override;
  virtual void OnRenegotiationNeeded() override;

  scoped_refptr<RTCMediaStream> MediaStreamForId(const std::string& id);

  scoped_refptr<RTCMediaTrack> MediaTrackForId(const std::string& id);

  void RemoveStreamForId(const std::string& id);

 private:
  std::unique_ptr<EventChannelProxy> event_channel_;
  scoped_refptr<RTCPeerConnection> peerconnection_;
  std::map<std::string, scoped_refptr<RTCMediaStream>> remote_streams_;
  FlutterWebRTCBase* base_;
  std::string id_;
};

class FlutterPeerConnection {
 public:
  FlutterPeerConnection(FlutterWebRTCBase* base) : base_(base) {}

  void CreateRTCPeerConnection(const EncodableMap& configuration,
                               const EncodableMap& constraints,
                               std::unique_ptr<MethodResultProxy> result);

  void RTCPeerConnectionClose(RTCPeerConnection* pc,
                              const std::string& uuid,
                              std::unique_ptr<MethodResultProxy> result);

  void RTCPeerConnectionDispose(RTCPeerConnection* pc,
                                const std::string& uuid,
                                std::unique_ptr<MethodResultProxy> result);

  void CreateOffer(const EncodableMap& constraints,
                   RTCPeerConnection* pc,
                   std::unique_ptr<MethodResultProxy> result);

  void CreateAnswer(const EncodableMap& constraints,
                    RTCPeerConnection* pc,
                    std::unique_ptr<MethodResultProxy> result);

  void SetLocalDescription(RTCSessionDescription* sdp,
                           RTCPeerConnection* pc,
                           std::unique_ptr<MethodResultProxy> result);

  void SetRemoteDescription(RTCSessionDescription* sdp,
                            RTCPeerConnection* pc,
                            std::unique_ptr<MethodResultProxy> result);

  void GetLocalDescription(RTCPeerConnection* pc,
                           std::unique_ptr<MethodResultProxy> result);

  void GetRemoteDescription(RTCPeerConnection* pc,
                            std::unique_ptr<MethodResultProxy> result);

  scoped_refptr<RTCRtpTransceiverInit> mapToRtpTransceiverInit(
      const EncodableMap& transceiverInit);

  RTCRtpTransceiverDirection stringToTransceiverDirection(
      std::string direction);

  libwebrtc::scoped_refptr<libwebrtc::RTCRtpEncodingParameters> mapToEncoding(
      const EncodableMap& parameters);

  void AddTransceiver(RTCPeerConnection* pc,
                      const std::string& trackId,
                      const std::string& mediaType,
                      const EncodableMap& transceiverInit,
                      std::unique_ptr<MethodResultProxy> result);

  void GetTransceivers(RTCPeerConnection* pc,
                       std::unique_ptr<MethodResultProxy> result);

  void GetReceivers(RTCPeerConnection* pc,
                    std::unique_ptr<MethodResultProxy> result);

  void RtpSenderDispose(RTCPeerConnection* pc,
                        std::string rtpSenderId,
                        std::unique_ptr<MethodResultProxy> result);

  void RtpSenderSetTrack(RTCPeerConnection* pc,
                         RTCMediaTrack* track,
                         std::string rtpSenderId,
                         std::unique_ptr<MethodResultProxy> result);

  void RtpSenderReplaceTrack(RTCPeerConnection* pc,
                             RTCMediaTrack* track,
                             std::string rtpSenderId,
                             std::unique_ptr<MethodResultProxy> result);

  scoped_refptr<RTCRtpParameters> updateRtpParameters(
      EncodableMap newParameters,
      scoped_refptr<RTCRtpParameters> parameters);

  void RtpSenderSetParameters(RTCPeerConnection* pc,
                              std::string rtpSenderId,
                              const EncodableMap& parameters,
                              std::unique_ptr<MethodResultProxy> result);

  void RtpTransceiverStop(RTCPeerConnection* pc,
                          std::string rtpTransceiverId,
                          std::unique_ptr<MethodResultProxy> result);

  void RtpTransceiverGetCurrentDirection(
      RTCPeerConnection* pc,
      std::string rtpTransceiverId,
      std::unique_ptr<MethodResultProxy> result);

  void SetConfiguration(RTCPeerConnection* pc,
                        const EncodableMap& configuration,
                        std::unique_ptr<MethodResultProxy> result);

  void CaptureFrame(RTCVideoTrack* track,
                    std::string path,
                    std::unique_ptr<MethodResultProxy> result);

  scoped_refptr<RTCRtpTransceiver> getRtpTransceiverById(RTCPeerConnection* pc,
                                                         std::string id);

  void RtpTransceiverSetDirection(RTCPeerConnection* pc,
                                  std::string rtpTransceiverId,
                                  std::string direction,
                                  std::unique_ptr<MethodResultProxy> result);

  void RtpTransceiverSetCodecPreferences(RTCPeerConnection* pc,
                                  std::string rtpTransceiverId,
                                  const EncodableList codecs,
                                  std::unique_ptr<MethodResultProxy> result);

  void GetSenders(RTCPeerConnection* pc,
                  std::unique_ptr<MethodResultProxy> result);

  void AddIceCandidate(RTCIceCandidate* candidate,
                       RTCPeerConnection* pc,
                       std::unique_ptr<MethodResultProxy> result);

  void GetStats(const std::string& track_id,
                RTCPeerConnection* pc,
                std::unique_ptr<MethodResultProxy> result);

  void MediaStreamAddTrack(scoped_refptr<RTCMediaStream> stream,
                           scoped_refptr<RTCMediaTrack> track,
                           std::unique_ptr<MethodResultProxy> result);

  void MediaStreamRemoveTrack(scoped_refptr<RTCMediaStream> stream,
                              scoped_refptr<RTCMediaTrack> track,
                              std::unique_ptr<MethodResultProxy> result);

  void AddTrack(RTCPeerConnection* pc,
                scoped_refptr<RTCMediaTrack> track,
                std::list<std::string> streamIds,
                std::unique_ptr<MethodResultProxy> result);

  libwebrtc::scoped_refptr<libwebrtc::RTCRtpSender> GetRtpSenderById(
      RTCPeerConnection* pc,
      std::string id);

  void RemoveTrack(RTCPeerConnection* pc,
                   std::string senderId,
                   std::unique_ptr<MethodResultProxy> result);

 private:
  FlutterWebRTCBase* base_;
};
}  // namespace flutter_webrtc_plugin

#endif  // !FLUTTER_WEBRTC_RTC_PEER_CONNECTION_HXX