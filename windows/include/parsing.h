#pragma once

#include "flutter/encodable_value.h"

template<typename T>
inline bool TypeIs(const EncodableValue val) {
  return std::holds_alternative<T>(val);
}

template<typename T>
inline const T GetValue(EncodableValue val) {
  return std::get<T>(val);
}

// Returns an `int64_t` value from the given `EncodableMap` by the given `key`
// if any, or a `-1` otherwise.
inline int64_t findLongInt(const EncodableMap& map, const std::string& key) {
  for (auto it : map) {
    if (key == GetValue<std::string>(it.first) &&
        (TypeIs<int64_t>(it.second) || TypeIs<int32_t>(it.second)))
      return GetValue<int64_t>(it.second);
  }

  return -1;
}

// Returns an `EncodableMap` value from the given `EncodableMap` by the given
// `key` if any, or an empty `EncodableMap` otherwise.
inline EncodableMap findMap(const EncodableMap& map, const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it != map.end() && TypeIs<EncodableMap>(it->second))
    return GetValue<EncodableMap>(it->second);
  return EncodableMap();
}

// Returns an `std::string` value from the given `EncodableMap` by the given
// `key` if any, or an empty `std::string` otherwise.
inline std::string findString(const EncodableMap& map, const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it != map.end() && TypeIs<std::string>(it->second))
    return GetValue<std::string>(it->second);
  return std::string();
}

// Returns a `bool` value from the given `EncodableMap` by the given `key` if
// any, or `false` otherwise.
inline bool findBool(const EncodableMap& map, const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it != map.end() && TypeIs<bool>(it->second))
    return GetValue<bool>(it->second);
  return bool();
}

// Returns an `EncodableList` value from the given `EncodableMap` by the given
// `key` if any, or an empty `EncodableList` otherwise.
inline EncodableList findList(const EncodableMap& map, const std::string& key) {
  auto it = map.find(EncodableValue(key));
  if (it != map.end() && TypeIs<EncodableList>(it->second))
    return GetValue<EncodableList>(it->second);
  return EncodableList();
}
