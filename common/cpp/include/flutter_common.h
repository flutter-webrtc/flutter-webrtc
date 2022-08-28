#ifndef FLUTTER_WEBRTC_COMMON_HXX
#define FLUTTER_WEBRTC_COMMON_HXX

#include <flutter/encodable_value.h>

using namespace flutter;

// foo.StringValue() becomes std::get<std::string>(foo)
// foo.IsString() becomes std::holds_alternative<std::string>(foo)

template <typename T>
inline bool TypeIs(const EncodableValue val) {
  return std::holds_alternative<T>(val);
}

template <typename T>
inline const T GetValue(EncodableValue val) {
  return std::get<T>(val);
}

inline EncodableValue findEncodableValue(const EncodableMap& map,
                                         const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it != map.end())
    return it->second;
  return EncodableValue();
}

inline EncodableMap findMap(const EncodableMap& map, const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it != map.end() && TypeIs<EncodableMap>(it->second))
    return GetValue<EncodableMap>(it->second);
  return EncodableMap();
}

inline EncodableList findList(const EncodableMap& map, const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it != map.end() && TypeIs<EncodableList>(it->second))
    return GetValue<EncodableList>(it->second);
  return EncodableList();
}

inline std::string findString(const EncodableMap& map, const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it != map.end() && TypeIs<std::string>(it->second))
    return GetValue<std::string>(it->second);
  return std::string();
}

inline int findInt(const EncodableMap& map, const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it != map.end() && TypeIs<int>(it->second))
    return GetValue<int>(it->second);
  return -1;
}

inline double findDouble(const EncodableMap& map, const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it != map.end() && TypeIs<double>(it->second))
    return GetValue<double>(it->second);
  return 0.0;
}

inline int64_t findLongInt(const EncodableMap& map, const std::string& key) {
  for (auto it : map) {
    if (key == GetValue<std::string>(it.first)) {
      if (TypeIs<int64_t>(it.second)) {
        return GetValue<int64_t>(it.second);
      } else if (TypeIs<int32_t>(it.second)) {
        return GetValue<int32_t>(it.second);
      }
    }
  }

  return -1;
}

inline int toInt(EncodableValue inputVal, int defaultVal) {
  int intValue = defaultVal;
  if (TypeIs<int>(inputVal)) {
    intValue = GetValue<int>(inputVal);
  } else if (TypeIs<int32_t>(inputVal)) {
    intValue = GetValue<int32_t>(inputVal);
  } else if (TypeIs<std::string>(inputVal)) {
    intValue = atoi(GetValue<std::string>(inputVal).c_str());
  }
  return intValue;
}

#endif // FLUTTER_WEBRTC_COMMON_HXX
