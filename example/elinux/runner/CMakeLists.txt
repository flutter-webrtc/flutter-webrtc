cmake_minimum_required(VERSION 3.15)
project(runner LANGUAGES CXX)

if(FLUTTER_TARGET_BACKEND_TYPE MATCHES "gbm")
  add_definitions(-DFLUTTER_TARGET_BACKEND_GBM)
elseif(FLUTTER_TARGET_BACKEND_TYPE MATCHES "eglstream")
  add_definitions(-DFLUTTER_TARGET_BACKEND_EGLSTREAM)
elseif(FLUTTER_TARGET_BACKEND_TYPE MATCHES "x11")
  add_definitions(-DFLUTTER_TARGET_BACKEND_X11)
else()
  add_definitions(-DFLUTTER_TARGET_BACKEND_WAYLAND)
endif()

add_executable(${BINARY_NAME}
  "flutter_window.cc"
  "main.cc"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
  "${CMAKE_SOURCE_DIR}/../cpp/video_processor_sample.cpp"
)
apply_standard_settings(${BINARY_NAME})
target_link_libraries(${BINARY_NAME} PRIVATE flutter)
target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")

# The video processor sample in ../cpp, shared with the Windows and Linux
# runners, uses the flutter_webrtc C++ API and libwebrtc directly. The
# flutter_webrtc_plugin target, linked in generated_plugins.cmake, provides
# their include paths; libwebrtc and the defines are added here so that the
# headers match how the plugin was built.
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}/../cpp")
target_compile_definitions(${BINARY_NAME} PRIVATE RTC_DESKTOP_DEVICE)
# The libwebrtc headers use uint32_t and friends without including <cstdint>;
# see the same workaround in the plugin's linux/CMakeLists.txt.
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
  target_compile_options(${BINARY_NAME} PRIVATE -include cstdint)
endif()
target_link_libraries(${BINARY_NAME} PRIVATE
  "${CMAKE_SOURCE_DIR}/flutter/ephemeral/.plugin_symlinks/flutter_webrtc/third_party/libwebrtc/lib/libwebrtc.so")
add_dependencies(${BINARY_NAME} flutter_assemble)
