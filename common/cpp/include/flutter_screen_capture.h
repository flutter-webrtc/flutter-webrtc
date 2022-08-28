#ifndef FLUTTER_SCRREN_CAPTURE_HXX
#define FLUTTER_SCRREN_CAPTURE_HXX

#include "flutter_common.h"
#include "flutter_webrtc_base.h"

#include "rtc_desktop_capturer.h"
#include "rtc_desktop_media_list.h"

namespace flutter_webrtc_plugin {

class FlutterScreenCapture : public MediaListObserver,
                             public DesktopCapturerObserver {
 public:
  FlutterScreenCapture(FlutterWebRTCBase* base);

  void GetDisplayMedia(const EncodableMap& constraints,
                       std::unique_ptr<MethodResultProxy> result);

  void GetDesktopSources(const EncodableList& types,
                         std::unique_ptr<MethodResultProxy> result);

  void UpdateDesktopSources(const EncodableList& types,
                            std::unique_ptr<MethodResultProxy> result);

  void GetDesktopSourceThumbnail(std::string source_id,
                                 int width,
                                 int height,
                                 std::unique_ptr<MethodResultProxy> result);

 protected:
  void OnMediaSourceAdded(scoped_refptr<MediaSource> source) override;

  void OnMediaSourceRemoved(scoped_refptr<MediaSource> source) override;

  void OnMediaSourceNameChanged(scoped_refptr<MediaSource> source) override;

  void OnMediaSourceThumbnailChanged(
      scoped_refptr<MediaSource> source) override;

  void OnStart(scoped_refptr<RTCDesktopCapturer> capturer) override;

  void OnPaused(scoped_refptr<RTCDesktopCapturer> capturer) override;

  void OnStop(scoped_refptr<RTCDesktopCapturer> capturer) override;

  void OnError(scoped_refptr<RTCDesktopCapturer> capturer) override;

 private:
  bool BuildDesktopSourcesList(const EncodableList& types, bool force_reload);

 private:
  FlutterWebRTCBase* base_;
  std::map<DesktopType, scoped_refptr<RTCDesktopMediaList>> medialist_;
  std::vector<scoped_refptr<MediaSource>> sources_;
};

}  // namespace flutter_webrtc_plugin

#endif  // FLUTTER_SCRREN_CAPTURE_HXX