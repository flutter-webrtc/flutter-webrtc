#ifndef LIB_WEBRTC_RTC_PEERCONNECTION_HXX
#define LIB_WEBRTC_RTC_PEERCONNECTION_HXX

#include "rtc_audio_track.h"
#include "rtc_data_channel.h"
#include "rtc_ice_candidate.h"
#include "rtc_media_stream.h"
#include "rtc_mediaconstraints.h"
#include "rtc_rtp_sender.h"
#include "rtc_rtp_transceiver.h"
#include "rtc_session_description.h"
#include "rtc_video_source.h"
#include "rtc_video_track.h"

namespace libwebrtc {

enum SessionDescriptionErrorType {
  kPeerConnectionInitFailed = 0,
  kCreatePeerConnectionFailed,
  kSDPParseFailed,
};

enum RTCPeerConnectionState {
  RTCPeerConnectionStateNew,
  RTCPeerConnectionStateConnecting,
  RTCPeerConnectionStateConnected,
  RTCPeerConnectionStateDisconnected,
  RTCPeerConnectionStateFailed,
  RTCPeerConnectionStateClosed,
};

enum RTCSignalingState {
  RTCSignalingStateStable,
  RTCSignalingStateHaveLocalOffer,
  RTCSignalingStateHaveRemoteOffer,
  RTCSignalingStateHaveLocalPrAnswer,
  RTCSignalingStateHaveRemotePrAnswer,
  RTCSignalingStateClosed
};

enum RTCIceGatheringState {
  RTCIceGatheringStateNew,
  RTCIceGatheringStateGathering,
  RTCIceGatheringStateComplete
};

enum RTCIceConnectionState {
  RTCIceConnectionStateNew,
  RTCIceConnectionStateChecking,
  RTCIceConnectionStateCompleted,
  RTCIceConnectionStateConnected,
  RTCIceConnectionStateFailed,
  RTCIceConnectionStateDisconnected,
  RTCIceConnectionStateClosed,
  RTCIceConnectionStateMax,
};

class RTCStatsMember : public RefCountInterface {
 public:
  // Member value types.
  enum Type {
    kBool,    // bool
    kInt32,   // int32_t
    kUint32,  // uint32_t
    kInt64,   // int64_t
    kUint64,  // uint64_t
    kDouble,  // double
    kString,  // std::string

    kSequenceBool,    // std::vector<bool>
    kSequenceInt32,   // std::vector<int32_t>
    kSequenceUint32,  // std::vector<uint32_t>
    kSequenceInt64,   // std::vector<int64_t>
    kSequenceUint64,  // std::vector<uint64_t>
    kSequenceDouble,  // std::vector<double>
    kSequenceString,  // std::vector<std::string>

    kMapStringUint64,  // std::map<std::string, uint64_t>
    kMapStringDouble,  // std::map<std::string, double>
  };

 public:
  virtual string GetName() const = 0;
  virtual Type GetType() const = 0;
  virtual bool IsDefined() const = 0;

  virtual bool ValueBool() const = 0;
  virtual int32_t ValueInt32() const = 0;
  virtual uint32_t ValueUint32() const = 0;
  virtual int64_t ValueInt64() const = 0;
  virtual uint64_t ValueUint64() const = 0;
  virtual double ValueDouble() const = 0;
  virtual string ValueString() const = 0;
  virtual vector<bool> ValueSequenceBool() const = 0;
  virtual vector<int32_t> ValueSequenceInt32() const = 0;
  virtual vector<uint32_t> ValueSequenceUint32() const = 0;
  virtual vector<int64_t> ValueSequenceInt64() const = 0;
  virtual vector<uint64_t> ValueSequenceUint64() const = 0;
  virtual vector<double> ValueSequenceDouble() const = 0;
  virtual vector<string> ValueSequenceString() const = 0;
  virtual map<string, uint64_t> ValueMapStringUint64() const = 0;
  virtual map<string, double> ValueMapStringDouble() const = 0;

 protected:
  virtual ~RTCStatsMember() {}
};

class MediaRTCStats : public RefCountInterface {
 public:
  virtual const string id() = 0;

  virtual const string type() = 0;

  virtual int64_t timestamp_us() = 0;

  virtual const string ToJson() = 0;

  virtual const vector<scoped_refptr<RTCStatsMember>> Members() = 0;
};

typedef fixed_size_function<void(
    const vector<scoped_refptr<MediaRTCStats>> reports)>
    OnStatsCollectorSuccess;

typedef fixed_size_function<void(const char* error)> OnStatsCollectorFailure;

typedef fixed_size_function<void(const string sdp, const string type)>
    OnSdpCreateSuccess;

typedef fixed_size_function<void(const char* erro)> OnSdpCreateFailure;

typedef fixed_size_function<void()> OnSetSdpSuccess;

typedef fixed_size_function<void(const char* error)> OnSetSdpFailure;

typedef fixed_size_function<void(const char* sdp, const char* type)>
    OnGetSdpSuccess;

typedef fixed_size_function<void(const char* error)> OnGetSdpFailure;

class RTCPeerConnectionObserver {
 public:
  virtual void OnSignalingState(RTCSignalingState state) = 0;

  virtual void OnPeerConnectionState(RTCPeerConnectionState state) = 0;

  virtual void OnIceGatheringState(RTCIceGatheringState state) = 0;

  virtual void OnIceConnectionState(RTCIceConnectionState state) = 0;

  virtual void OnIceCandidate(scoped_refptr<RTCIceCandidate> candidate) = 0;

  virtual void OnAddStream(scoped_refptr<RTCMediaStream> stream) = 0;

  virtual void OnRemoveStream(scoped_refptr<RTCMediaStream> stream) = 0;

  virtual void OnDataChannel(scoped_refptr<RTCDataChannel> data_channel) = 0;

  virtual void OnRenegotiationNeeded() = 0;

  virtual void OnTrack(scoped_refptr<RTCRtpTransceiver> transceiver) = 0;

  virtual void OnAddTrack(vector<scoped_refptr<RTCMediaStream>> streams,
                          scoped_refptr<RTCRtpReceiver> receiver) = 0;

  virtual void OnRemoveTrack(scoped_refptr<RTCRtpReceiver> receiver) = 0;

 protected:
  virtual ~RTCPeerConnectionObserver() {}
};

class RTCPeerConnection : public RefCountInterface {
 public:
  virtual int AddStream(scoped_refptr<RTCMediaStream> stream) = 0;

  virtual int RemoveStream(scoped_refptr<RTCMediaStream> stream) = 0;

  virtual scoped_refptr<RTCMediaStream> CreateLocalMediaStream(
      const string stream_id) = 0;

  virtual scoped_refptr<RTCDataChannel> CreateDataChannel(
      const string label,
      RTCDataChannelInit* dataChannelDict) = 0;

  virtual void CreateOffer(OnSdpCreateSuccess success,
                           OnSdpCreateFailure failure,
                           scoped_refptr<RTCMediaConstraints> constraints) = 0;

  virtual void CreateAnswer(OnSdpCreateSuccess success,
                            OnSdpCreateFailure failure,
                            scoped_refptr<RTCMediaConstraints> constraints) = 0;

  virtual void RestartIce() = 0;

  virtual void Close() = 0;

  virtual void SetLocalDescription(const string sdp,
                                   const string type,
                                   OnSetSdpSuccess success,
                                   OnSetSdpFailure failure) = 0;

  virtual void SetRemoteDescription(const string sdp,
                                    const string type,
                                    OnSetSdpSuccess success,
                                    OnSetSdpFailure failure) = 0;

  virtual void GetLocalDescription(OnGetSdpSuccess success,
                                   OnGetSdpFailure failure) = 0;

  virtual void GetRemoteDescription(OnGetSdpSuccess success,
                                    OnGetSdpFailure failure) = 0;

  virtual void AddCandidate(const string mid,
                            int mid_mline_index,
                            const string candiate) = 0;

  virtual void RegisterRTCPeerConnectionObserver(
      RTCPeerConnectionObserver* observer) = 0;

  virtual void DeRegisterRTCPeerConnectionObserver() = 0;

  virtual vector<scoped_refptr<RTCMediaStream>> local_streams() = 0;

  virtual vector<scoped_refptr<RTCMediaStream>> remote_streams() = 0;

  virtual bool GetStats(scoped_refptr<RTCRtpSender> sender,
                        OnStatsCollectorSuccess success,
                        OnStatsCollectorFailure failure) = 0;

  virtual bool GetStats(scoped_refptr<RTCRtpReceiver> receiver,
                        OnStatsCollectorSuccess success,
                        OnStatsCollectorFailure failure) = 0;

  virtual void GetStats(OnStatsCollectorSuccess success,
                        OnStatsCollectorFailure failure) = 0;

  virtual scoped_refptr<RTCRtpTransceiver> AddTransceiver(
      scoped_refptr<RTCMediaTrack> track,
      scoped_refptr<RTCRtpTransceiverInit> init) = 0;

  virtual scoped_refptr<RTCRtpTransceiver> AddTransceiver(
      scoped_refptr<RTCMediaTrack> track) = 0;

  virtual scoped_refptr<RTCRtpSender> AddTrack(
      scoped_refptr<RTCMediaTrack> track,
      const vector<string> streamIds) = 0;

  virtual scoped_refptr<RTCRtpTransceiver> AddTransceiver(
      RTCMediaType media_type) = 0;

  virtual scoped_refptr<RTCRtpTransceiver> AddTransceiver(
      RTCMediaType media_type,
      scoped_refptr<RTCRtpTransceiverInit> init) = 0;

  virtual bool RemoveTrack(scoped_refptr<RTCRtpSender> render) = 0;

  virtual vector<scoped_refptr<RTCRtpSender>> senders() = 0;

  virtual vector<scoped_refptr<RTCRtpTransceiver>> transceivers() = 0;

  virtual vector<scoped_refptr<RTCRtpReceiver>> receivers() = 0;

  virtual RTCSignalingState signaling_state() = 0;

  virtual RTCIceConnectionState ice_connection_state() = 0;

  virtual RTCIceConnectionState standardized_ice_connection_state() = 0;

  virtual RTCPeerConnectionState peer_connection_state() = 0;

  virtual RTCIceGatheringState ice_gathering_state() = 0;

 protected:
  virtual ~RTCPeerConnection() {}
};

}  // namespace libwebrtc

#endif  // LIB_WEBRTC_RTC_PEERCONNECTION_HXX
