#ifndef FLUTTER_WEBRTC_PLUGIN_FLUTTER_UTF8_SANITIZE_H_
#define FLUTTER_WEBRTC_PLUGIN_FLUTTER_UTF8_SANITIZE_H_

#include <string>

namespace flutter_webrtc_plugin {

// ADM/device buffers may not be valid UTF-8. Flutter StandardMessageCodec
// decodes as UTF-8; invalid bytes cause FormatException. Use before EncodableValue
// and when comparing ids from Dart.
std::string SanitizeUtf8ForFlutter(const std::string& input);

}  // namespace flutter_webrtc_plugin

#endif  // FLUTTER_WEBRTC_PLUGIN_FLUTTER_UTF8_SANITIZE_H_
