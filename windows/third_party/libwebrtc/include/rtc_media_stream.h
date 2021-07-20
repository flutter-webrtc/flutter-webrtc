#ifndef LIB_WEBRTC_RTC_MEDIA_STREAM_HXX
#define LIB_WEBRTC_RTC_MEDIA_STREAM_HXX

#include "rtc_audio_track.h"
#include "rtc_types.h"
#include "rtc_video_track.h"

namespace libwebrtc {

class RTCMediaStream : public RefCountInterface {
 public:
  virtual bool AddTrack(scoped_refptr<RTCAudioTrack> track) = 0;

  virtual bool AddTrack(scoped_refptr<RTCVideoTrack> track) = 0;

  virtual bool RemoveTrack(scoped_refptr<RTCAudioTrack> track) = 0;

  virtual bool RemoveTrack(scoped_refptr<RTCVideoTrack> track) = 0;

  virtual scoped_refptr<RTCAudioTracks> audio_tracks() = 0;

  virtual scoped_refptr<RTCVideoTracks> video_tracks() = 0;

  virtual scoped_refptr<RTCMediaTracks> tracks() = 0;

  virtual scoped_refptr<RTCAudioTrack> FindAudioTrack(
      const string track_id) = 0;

  virtual scoped_refptr<RTCVideoTrack> FindVideoTrack(
      const string track_id) = 0;

  virtual const string label() = 0;

  virtual const string id() = 0;

 protected:
  ~RTCMediaStream() {}
};

class RTCMediaStreams : public RefCountInterface {
 public:
  LIB_WEBRTC_API  static scoped_refptr<RTCMediaStreams> Create();
  virtual void Add(scoped_refptr<RTCMediaStream> value) = 0;
  virtual scoped_refptr<RTCMediaStream> Get(int index) = 0;
  virtual int Size() = 0;
  virtual void Remove(int index) = 0;
  virtual void Clean() = 0;
};

class RTCStreamIds : public RefCountInterface {
 public:
  LIB_WEBRTC_API static scoped_refptr<RTCStreamIds> Create();
  virtual void Add(string value) = 0;
  virtual string Get(int index) = 0;
  virtual int Size() = 0;
  virtual void Remove(int index) = 0;
  virtual void Clean() = 0;
};


}  // namespace libwebrtc




#endif  // LIB_WEBRTC_RTC_MEDIA_STREAM_HXX