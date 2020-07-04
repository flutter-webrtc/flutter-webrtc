#ifndef FLUTTER_WEBRTC_RTC_PEER_CONNECTION_HXX
#define FLUTTER_WEBRTC_RTC_PEER_CONNECTION_HXX

#include "flutter_webrtc_base.h"

namespace flutter_webrtc_plugin {

using namespace flutter;

class FlutterPeerConnectionObserver : public RTCPeerConnectionObserver {
 public:
  FlutterPeerConnectionObserver(FlutterWebRTCBase *base,
                                scoped_refptr<RTCPeerConnection> peerconnection,
                                BinaryMessenger *messenger,
                                const std::string &channel_name);

  virtual void OnSignalingState(RTCSignalingState state) override;
  virtual void OnIceGatheringState(RTCIceGatheringState state) override;
  virtual void OnIceConnectionState(RTCIceConnectionState state) override;
  virtual void OnIceCandidate(
      scoped_refptr<RTCIceCandidate> candidate) override;
  virtual void OnAddStream(scoped_refptr<RTCMediaStream> stream) override;
  virtual void OnRemoveStream(scoped_refptr<RTCMediaStream> stream) override;
  virtual void OnAddTrack(scoped_refptr<RTCMediaStream> stream,
                          scoped_refptr<RTCMediaTrack> track) override;
  virtual void OnRemoveTrack(scoped_refptr<RTCMediaStream> stream,
                             scoped_refptr<RTCMediaTrack> track) override;
  virtual void OnDataChannel(
      scoped_refptr<RTCDataChannel> data_channel) override;
  virtual void OnRenegotiationNeeded() override;

  scoped_refptr<RTCMediaStream> MediaStreamForId(
      const std::string &id) {
    auto it = remote_streams_.find(id);
    if (it != remote_streams_.end()) return (*it).second;
    return nullptr;
  }

  void RemoveStreamForId(const std::string &id) {
    auto it = remote_streams_.find(id);
    if (it != remote_streams_.end()) remote_streams_.erase(it);
  }

 private:
  std::unique_ptr<EventChannel<EncodableValue>> event_channel_;
  std::unique_ptr<EventSink<EncodableValue>> event_sink_;
  scoped_refptr<RTCPeerConnection> peerconnection_;
  std::map<std::string, scoped_refptr<RTCMediaStream>> remote_streams_;
  FlutterWebRTCBase *base_;
};

class FlutterPeerConnection {
 public:
  FlutterPeerConnection(FlutterWebRTCBase *base) : base_(base) {}

  void CreateRTCPeerConnection(
      const EncodableMap &configuration, const EncodableMap &constraints,
      std::unique_ptr<MethodResult<EncodableValue>> result);

  void RTCPeerConnectionClose(
      RTCPeerConnection *pc, const std::string &uuid,
      std::unique_ptr<MethodResult<EncodableValue>> result);

  void CreateOffer(const EncodableMap &constraints, RTCPeerConnection *pc,
                   std::unique_ptr<MethodResult<EncodableValue>> result);

  void CreateAnswer(const EncodableMap &constraints, RTCPeerConnection *pc,
                    std::unique_ptr<MethodResult<EncodableValue>> result);

  void SetLocalDescription(
      RTCSessionDescription *sdp, RTCPeerConnection *pc,
      std::unique_ptr<MethodResult<EncodableValue>> result);

  void SetRemoteDescription(
      RTCSessionDescription *sdp, RTCPeerConnection *pc,
      std::unique_ptr<MethodResult<EncodableValue>> result);

  void AddIceCandidate(RTCIceCandidate *candidate, RTCPeerConnection *pc,
                       std::unique_ptr<MethodResult<EncodableValue>> result);

  void GetStats(const std::string &track_id, RTCPeerConnection *pc,
                std::unique_ptr<MethodResult<EncodableValue>> result);

 private:
  FlutterWebRTCBase *base_;
};
}  // namespace flutter_webrtc_plugin

#endif  // !FLUTTER_WEBRTC_RTC_PEER_CONNECTION_HXX