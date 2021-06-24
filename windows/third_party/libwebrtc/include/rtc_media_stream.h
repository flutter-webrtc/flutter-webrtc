#ifndef LIB_WEBRTC_RTC_MEDIA_STREAM_HXX
#define LIB_WEBRTC_RTC_MEDIA_STREAM_HXX

#include "rtc_types.h"
#include "rtc_audio_track.h"
#include "rtc_video_track.h"

namespace libwebrtc {

class RTCMediaStream : public RefCountInterface {
 public:
  virtual void GetId(OnString on) = 0;

  virtual bool AddTrack(scoped_refptr<RTCAudioTrack> track) = 0;

  virtual bool AddTrack(scoped_refptr<RTCVideoTrack> track) = 0;

  virtual bool RemoveTrack(scoped_refptr<RTCAudioTrack> track) = 0;

  virtual bool RemoveTrack(scoped_refptr<RTCVideoTrack> track) = 0;

  /*获取所有音频轨道*/
  virtual void GetAudioTracks(OnRTCAudioTrack on) = 0;

  /*获取所有视频轨道*/
  virtual void GetVideoTracks(OnRTCVideoTrack on) = 0;

  virtual scoped_refptr<RTCAudioTrack> FindAudioTrack(
      const char* track_id) = 0;

  virtual scoped_refptr<RTCVideoTrack> FindVideoTrack(
      const char* track_id) = 0;

  /*media stream label 对应sdp msid 前缀*/
  virtual const char* label() = 0;

 protected:
  ~RTCMediaStream() {}
};

typedef fixed_size_function<void(scoped_refptr<RTCMediaStream> val)>
    OnRTCMediaStream;
typedef fixed_size_function<void(OnRTCMediaStream on)> OnVectorRTCMediaStream;


} // namespace libwebrtc

#endif  // LIB_WEBRTC_RTC_MEDIA_STREAM_HXX
