cmake_minimum_required(VERSION 3.15)
set(PROJECT_NAME "flutter_webrtc")
project(${PROJECT_NAME} LANGUAGES CXX)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "flutter_webrtc_plugin")

add_definitions(-DLIB_WEBRTC_API_DLL)

add_library(${PLUGIN_NAME} SHARED
  "flutter_webrtc_plugin.cc"
  "src/flutter_webrtc.cc"
  "src/media_stream.cc"
  "${CMAKE_CURRENT_SOURCE_DIR}/rust/src/flutter_webrtc_native.cc"
)

include_directories(
  "${CMAKE_CURRENT_SOURCE_DIR}/include"
  "${CMAKE_CURRENT_SOURCE_DIR}/rust/include"
)

apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include"
  "${CMAKE_CURRENT_SOURCE_DIR}/rust/include"
)
target_link_libraries(${PLUGIN_NAME} PRIVATE
  flutter
  flutter_wrapper_plugin
  "${CMAKE_CURRENT_SOURCE_DIR}/rust/lib/flutter_webrtc_native.dll.lib"
  "${CMAKE_CURRENT_SOURCE_DIR}/rust/lib/cxxbridge1.lib"
)

# List of absolute paths to libraries that should be bundled with the plugin
set(flutter_webrtc_bundled_libraries
  "${CMAKE_CURRENT_SOURCE_DIR}/rust/lib/flutter_webrtc_native.dll"
  PARENT_SCOPE
)
