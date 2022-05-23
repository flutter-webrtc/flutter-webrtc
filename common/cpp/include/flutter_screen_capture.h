#ifndef FLUTTER_SCRREN_CAPTURE_HXX
#define FLUTTER_SCRREN_CAPTURE_HXX

#include "flutter_webrtc_base.h"

namespace flutter_webrtc_plugin {

using namespace flutter;

class FlutterScreenCapture {
 public:
  FlutterScreenCapture(FlutterWebRTCBase *base) : base_(base) {}
  
  void EnumerateWindow(std::unique_ptr<MethodResult<EncodableValue>> result);

  void EnumerateScreen(std::unique_ptr<MethodResult<EncodableValue>> result);

  void CreateScreenCapture(const EncodableMap& constraints, 
                                               std::unique_ptr<MethodResult<EncodableValue>> result);

  void CreateWindowsCapture(const EncodableMap& constraints, 
                                               std::unique_ptr<MethodResult<EncodableValue>> result);

 private:
  FlutterWebRTCBase *base_;
};

}

#endif  // FLUTTER_SCRREN_CAPTURE_HXX