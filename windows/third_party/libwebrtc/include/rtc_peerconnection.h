#ifndef LIB_WEBRTC_RTC_PEERCONNECTION_HXX
#define LIB_WEBRTC_RTC_PEERCONNECTION_HXX

#include "rtc_types.h"
#include "rtc_audio_track.h"
#include "rtc_data_channel.h"
#include "rtc_ice_candidate.h"
#include "rtc_media_stream.h"
#include "rtc_mediaconstraints.h"
#include "rtc_session_description.h"
#include "rtc_video_source.h"
#include "rtc_video_track.h"

#include <string.h>

namespace libwebrtc {

enum SessionDescriptionErrorType {
  kPeerConnectionInitFailed = 0,
  kCreatePeerConnectionFailed,
  kSDPParseFailed,
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

class MediaTrackStatistics {
 public:
  MediaTrackStatistics() {}
  int64_t bytes_received = 0;
  int64_t bytes_sent = 0;
  int packets_lost = 0;
  int packets_received = 0;
  int packets_sent = 0;
  int frame_rate_sent = 0;
  int frame_rate_received = 0;
  uint32_t rtt = 0;

  int64_t ssrc = 0;
  char msid[kMaxStringLength];
  char kind[kShortStringLength];
  char direction[kShortStringLength];

 public:
  MediaTrackStatistics(const MediaTrackStatistics* stats) { copy(*stats); }

  MediaTrackStatistics& operator=(const MediaTrackStatistics& rhs) {
    if (&rhs == this)
      return *this;
    return copy(rhs);
  }

  MediaTrackStatistics& copy(const MediaTrackStatistics& rhs) {
    strncpy(direction, rhs.direction, sizeof(direction));
    strncpy(kind, rhs.kind, sizeof(kind));
    packets_sent = rhs.packets_sent;
    packets_received = rhs.packets_received;
    packets_lost = rhs.packets_lost;
    bytes_sent = rhs.bytes_sent;
    bytes_received = rhs.bytes_received;
    frame_rate_sent = rhs.frame_rate_sent;
    frame_rate_received = rhs.frame_rate_received;
    ssrc = rhs.ssrc;
    rtt = rhs.rtt;
    strncpy(msid, rhs.msid, sizeof(msid));
    return *this;
  }
};

class TrackStatsObserver : public RefCountInterface {
 public:
  virtual void OnComplete(const MediaTrackStatistics& reports) = 0;

 protected:
  ~TrackStatsObserver() {}
};

typedef fixed_size_function<void(const char* sdp, const char* type)>
    OnSdpCreateSuccess;

typedef fixed_size_function<void(const char* erro)> OnSdpCreateFailure;

typedef fixed_size_function<void()> OnSetSdpSuccess;

typedef fixed_size_function<void(const char* error)> OnSetSdpFailure;

class RTCPeerConnectionObserver {
 public:
  virtual void OnSignalingState(RTCSignalingState state) = 0;

  virtual void OnIceGatheringState(RTCIceGatheringState state) = 0;

  virtual void OnIceConnectionState(RTCIceConnectionState state) = 0;

  virtual void OnIceCandidate(scoped_refptr<RTCIceCandidate> candidate) = 0;

  virtual void OnAddStream(scoped_refptr<RTCMediaStream> stream) = 0;

  virtual void OnRemoveStream(scoped_refptr<RTCMediaStream> stream) = 0;

  virtual void OnAddTrack(scoped_refptr<RTCMediaStream> stream,
                          scoped_refptr<RTCMediaTrack> track) = 0;

  virtual void OnRemoveTrack(scoped_refptr<RTCMediaStream> stream,
                             scoped_refptr<RTCMediaTrack> track) = 0;

  virtual void OnDataChannel(scoped_refptr<RTCDataChannel> data_channel) = 0;

  virtual void OnRenegotiationNeeded() = 0;

 protected:
  virtual ~RTCPeerConnectionObserver() {}
};

class RTCPeerConnection : public RefCountInterface {
 public:
  virtual int AddStream(scoped_refptr<RTCMediaStream> stream) = 0;

  virtual int RemoveStream(scoped_refptr<RTCMediaStream> stream) = 0;

  virtual scoped_refptr<RTCDataChannel> CreateDataChannel(
      const char* label,
      const RTCDataChannelInit* dataChannelDict) = 0;

  virtual void CreateOffer(OnSdpCreateSuccess success,
                           OnSdpCreateFailure failure,
                           scoped_refptr<RTCMediaConstraints> constraints) = 0;

  virtual void CreateAnswer(OnSdpCreateSuccess success,
                            OnSdpCreateFailure failure,
                            scoped_refptr<RTCMediaConstraints> constraints) = 0;

  virtual void Close() = 0;

  virtual void SetLocalDescription(const char* sdp,
                                   const char* type,
                                   OnSetSdpSuccess success,
                                   OnSetSdpFailure failure) = 0;

  virtual void SetRemoteDescription(const char* sdp,
                                    const char* type,
                                    OnSetSdpSuccess success,
                                    OnSetSdpFailure failure) = 0;

  virtual void AddCandidate(const char* mid,
                            int midx,
                            const char* candiate) = 0;

  virtual void RegisterRTCPeerConnectionObserver(
      RTCPeerConnectionObserver* observer) = 0;

  virtual void DeRegisterRTCPeerConnectionObserver() = 0;

  virtual MediaStreamVector local_streams() = 0;

  virtual MediaStreamVector remote_streams() = 0;

  virtual bool GetStats(const RTCAudioTrack* track,
                        scoped_refptr<TrackStatsObserver> observer) = 0;

  virtual bool GetStats(const RTCVideoTrack* track,
                        scoped_refptr<TrackStatsObserver> observer) = 0;

 protected:
  virtual ~RTCPeerConnection() {}
};

};  // namespace libwebrtc

#endif  // LIB_WEBRTC_RTC_PEERCONNECTION_HXX
