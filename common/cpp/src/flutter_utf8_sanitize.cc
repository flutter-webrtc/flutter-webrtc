#include "flutter_utf8_sanitize.h"

#include <cstdint>

namespace flutter_webrtc_plugin {

// Replace invalid UTF-8 sequences with U+FFFD (EF BF BD).
std::string SanitizeUtf8ForFlutter(const std::string& input) {
  std::string out;
  out.reserve(input.size());
  const unsigned char* s = reinterpret_cast<const unsigned char*>(input.data());
  const size_t len = input.size();
  size_t i = 0;

  while (i < len) {
    const unsigned char c = s[i];
    if (c < 0x80) {
      out.push_back(static_cast<char>(c));
      ++i;
      continue;
    }
    if ((c & 0xE0) == 0xC0) {
      if (i + 1 >= len) {
        out += "\xEF\xBF\xBD";
        ++i;
        continue;
      }
      const unsigned char c1 = s[i + 1];
      if ((c1 & 0xC0) != 0x80) {
        out += "\xEF\xBF\xBD";
        ++i;
        continue;
      }
      const uint32_t cp =
          (static_cast<uint32_t>(c & 0x1F) << 6) | (c1 & 0x3F);
      if (cp < 0x80 || cp > 0x7FF) {
        out += "\xEF\xBF\xBD";
        ++i;
        continue;
      }
      out.push_back(static_cast<char>(c));
      out.push_back(static_cast<char>(c1));
      i += 2;
      continue;
    }
    if ((c & 0xF0) == 0xE0) {
      if (i + 2 >= len) {
        out += "\xEF\xBF\xBD";
        ++i;
        continue;
      }
      const unsigned char c1 = s[i + 1];
      const unsigned char c2 = s[i + 2];
      if ((c1 & 0xC0) != 0x80 || (c2 & 0xC0) != 0x80) {
        out += "\xEF\xBF\xBD";
        ++i;
        continue;
      }
      const uint32_t cp = (static_cast<uint32_t>(c & 0x0F) << 12) |
                          (static_cast<uint32_t>(c1 & 0x3F) << 6) |
                          (c2 & 0x3F);
      if (cp < 0x800 || cp > 0xFFFF || (cp >= 0xD800 && cp <= 0xDFFF)) {
        out += "\xEF\xBF\xBD";
        ++i;
        continue;
      }
      out.push_back(static_cast<char>(c));
      out.push_back(static_cast<char>(c1));
      out.push_back(static_cast<char>(c2));
      i += 3;
      continue;
    }
    if ((c & 0xF8) == 0xF0) {
      if (i + 3 >= len) {
        out += "\xEF\xBF\xBD";
        ++i;
        continue;
      }
      const unsigned char c1 = s[i + 1];
      const unsigned char c2 = s[i + 2];
      const unsigned char c3 = s[i + 3];
      if ((c1 & 0xC0) != 0x80 || (c2 & 0xC0) != 0x80 ||
          (c3 & 0xC0) != 0x80) {
        out += "\xEF\xBF\xBD";
        ++i;
        continue;
      }
      const uint32_t cp = (static_cast<uint32_t>(c & 0x07) << 18) |
                          (static_cast<uint32_t>(c1 & 0x3F) << 12) |
                          (static_cast<uint32_t>(c2 & 0x3F) << 6) |
                          (c3 & 0x3F);
      if (cp < 0x10000 || cp > 0x10FFFF) {
        out += "\xEF\xBF\xBD";
        ++i;
        continue;
      }
      out.push_back(static_cast<char>(c));
      out.push_back(static_cast<char>(c1));
      out.push_back(static_cast<char>(c2));
      out.push_back(static_cast<char>(c3));
      i += 4;
      continue;
    }
    out += "\xEF\xBF\xBD";
    ++i;
  }
  return out;
}

}  // namespace flutter_webrtc_plugin
