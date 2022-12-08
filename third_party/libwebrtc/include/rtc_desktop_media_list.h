#ifndef LIB_WEBRTC_RTC_DESKTOP_MEDIA_LIST_HXX
#define LIB_WEBRTC_RTC_DESKTOP_MEDIA_LIST_HXX

#include "rtc_types.h"

namespace libwebrtc {

class MediaSource : public RefCountInterface {
 public:
  // source id
  virtual string id() const = 0;

  // source name
  virtual string name() const = 0;

  // Returns the thumbnail of the source, jpeg format.
  virtual portable::vector<unsigned char> thumbnail() const = 0;

  virtual DesktopType type() const = 0;

  virtual bool UpdateThumbnail() = 0;

 protected:
  virtual ~MediaSource() {}
};

class MediaListObserver {
 public:
  virtual void OnMediaSourceAdded(scoped_refptr<MediaSource> source) = 0;

  virtual void OnMediaSourceRemoved(scoped_refptr<MediaSource> source) = 0;

  virtual void OnMediaSourceNameChanged(scoped_refptr<MediaSource> source) = 0;

  virtual void OnMediaSourceThumbnailChanged(
      scoped_refptr<MediaSource> source) = 0;

 protected:
  virtual ~MediaListObserver() {}
};

class RTCDesktopMediaList : public RefCountInterface {
 public:
  virtual void RegisterMediaListObserver(MediaListObserver* observer) = 0;

  virtual void DeRegisterMediaListObserver() = 0;

  virtual DesktopType type() const = 0;

  virtual int32_t UpdateSourceList(bool force_reload = false,
                                   bool get_thumbnail = true) = 0;

  virtual int GetSourceCount() const = 0;

  virtual scoped_refptr<MediaSource> GetSource(int index) = 0;

  virtual bool GetThumbnail(scoped_refptr<MediaSource> source,
                            bool notify = false) = 0;

 protected:
  ~RTCDesktopMediaList() {}
};

}  // namespace libwebrtc

#endif  // LIB_WEBRTC_RTC_DESKTOP_MEDIA_LIST_HXX