#ifndef FLUTTER_SCRREN_CAPTURE_HXX
#define FLUTTER_SCRREN_CAPTURE_HXX

#include "flutter_webrtc_base.h"

namespace flutter_webrtc_plugin {

using namespace flutter;

class FlutterScreenCapture {
 public:
  FlutterScreenCapture(FlutterWebRTCBase *base) : base_(base) {}
  
  void GetDisplayMedia(const EncodableMap& constraints,
                    std::unique_ptr<MethodResult<EncodableValue>> result);

  void GetDesktopSources(const EncodableList &types, std::unique_ptr<MethodResult<EncodableValue>> result);

  void GetDesktopSourceThumbnail(uint64_t source_id, int width, int height,
                     std::unique_ptr<MethodResult<EncodableValue>> result);

  void EnumerateWindows(std::unique_ptr<MethodResult<EncodableValue>> result);

  void EnumerateScreens(std::unique_ptr<MethodResult<EncodableValue>> result);

  void CreateCapture(libwebrtc::SourceType type, uint64_t id,
                     const EncodableMap& constraints,
                     std::unique_ptr<MethodResult<EncodableValue>> result);

 private:
  FlutterWebRTCBase *base_;
};

}

#endif  // FLUTTER_SCRREN_CAPTURE_HXX