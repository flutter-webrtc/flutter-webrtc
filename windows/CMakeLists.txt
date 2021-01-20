cmake_minimum_required(VERSION 3.15)
set(PROJECT_NAME "flutter_webrtc")
project(${PROJECT_NAME} LANGUAGES CXX)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "flutter_webrtc_plugin")

add_definitions(-DLIB_WEBRTC_API_DLL)

add_library(${PLUGIN_NAME} SHARED
  "flutter_webrtc_plugin.cc"
  "src/flutter_data_channel.cc"
  "src/flutter_media_stream.cc"
  "src/flutter_peerconnection.cc"
  "src/flutter_video_renderer.cc"
  "src/flutter_webrtc.cc"
  "src/flutter_webrtc_base.cc"
  "third_party/uuidxx/uuidxx.cc"
)

include_directories(
  "${CMAKE_CURRENT_SOURCE_DIR}/include"
  "${CMAKE_CURRENT_SOURCE_DIR}/third_party/uuidxx"
  "${CMAKE_CURRENT_SOURCE_DIR}/third_party/uuidxx"
  "${CMAKE_CURRENT_SOURCE_DIR}/third_party/libwebrtc/include"
)

apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include"
)
target_link_libraries(${PLUGIN_NAME} PRIVATE 
  flutter
  flutter_wrapper_plugin
  "${CMAKE_CURRENT_SOURCE_DIR}/third_party/libwebrtc/lib/libwebrtc.dll.lib"
)

# List of absolute paths to libraries that should be bundled with the plugin
set(flutter_webrtc_bundled_libraries
  "${CMAKE_CURRENT_SOURCE_DIR}/third_party/libwebrtc/lib/libwebrtc.dll"
  PARENT_SCOPE
)
