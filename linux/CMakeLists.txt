cmake_minimum_required(VERSION 3.10)
set(PROJECT_NAME "flutter_webrtc")
project(${PROJECT_NAME} LANGUAGES CXX)

if (CMAKE_VERSION VERSION_GREATER_EQUAL "3.24.0")
  cmake_policy(SET CMP0135 NEW)
endif()

# Add the libwebrtc dependency
include("${CMAKE_CURRENT_SOURCE_DIR}/../third_party/CMakeLists.txt")

set(PLUGIN_NAME "${PROJECT_NAME}_plugin")
set (CMAKE_EXPORT_COMPILE_COMMANDS ON )
set(CMAKE_CXX_STANDARD 17)

add_definitions(-DRTC_DESKTOP_DEVICE)

add_library(${PLUGIN_NAME} SHARED
  "../common/cpp/src/flutter_data_channel.cc"
  "../common/cpp/src/flutter_data_packet_cryptor.cc"
  "../common/cpp/src/flutter_frame_cryptor.cc"
  "../common/cpp/src/flutter_media_stream.cc"
  "../common/cpp/src/flutter_utf8_sanitize.cc"
  "../common/cpp/src/flutter_peerconnection.cc"
  "../common/cpp/src/flutter_frame_capturer.cc"
  "../common/cpp/src/flutter_video_renderer.cc"
  "../common/cpp/src/flutter_screen_capture.cc"
  "../common/cpp/src/flutter_webrtc.cc"
  "../common/cpp/src/flutter_webrtc_base.cc"
  "../common/cpp/src/flutter_common.cc"
  "loopback_capturer_factory.cc"
  "pulse_loopback_capturer.cc"
  "flutter_webrtc_plugin.cc"
  "flutter/core_implementations.cc"
  "flutter/standard_codec.cc"
  "flutter/plugin_registrar.cc"
  "task_runner_linux.cc"
)

include_directories(
  "${CMAKE_CURRENT_SOURCE_DIR}"
  "${CMAKE_CURRENT_SOURCE_DIR}/flutter/include"
  "${CMAKE_CURRENT_SOURCE_DIR}/../common/cpp/include"
  "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/libwebrtc/include"
  "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/svpng"
)

apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}"
  "${CMAKE_CURRENT_SOURCE_DIR}/../common/cpp/include"
  "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/libwebrtc/include"
)
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter)
target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::GTK)

# GCC 14+ (and notably GCC 16) tightened transitive header inclusion, so the
# bundled libwebrtc headers (e.g. third_party/libwebrtc/include/rtc_types.h)
# now fail to compile because they use fixed-width integer types such as
# uint32_t without including <cstdint>. Force-include <cstdint> for every
# translation unit of this target so those headers build under strict
# toolchains, instead of editing the downloaded third-party headers in place.
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
  target_compile_options(${PLUGIN_NAME} PRIVATE -include cstdint)
endif()

# ---------------------------------------------------------------------------
# System-audio (loopback) capture: PulseAudio simple API.
# Guarded so a host without libpulse dev headers still builds the plugin; in
# that case pulse_loopback_capturer.cc compiles to nothing and the factory
# returns nullptr (getDisplayMedia audio degrades to no track), matching the
# previous Linux stub behaviour rather than breaking the whole plugin build.
# PipeWire ships a PulseAudio compat layer, so libpulse covers both stacks.
# On Manjaro/.41 the dev headers come from the base `libpulse` package.
# ---------------------------------------------------------------------------
find_package(PkgConfig)
if(PkgConfig_FOUND)
  pkg_check_modules(PULSE IMPORTED_TARGET libpulse libpulse-simple)
endif()
if(TARGET PkgConfig::PULSE)
  message(STATUS "flutter_webrtc: libpulse found -- enabling Linux system-audio loopback capture.")
  target_compile_definitions(${PLUGIN_NAME} PRIVATE HAVE_LIBPULSE)
  target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::PULSE)
else()
  message(WARNING "flutter_webrtc: libpulse NOT found -- Linux system-audio loopback capture disabled (getDisplayMedia({audio:true}) yields no audio track). Install the libpulse dev package to enable it.")
endif()


target_link_libraries(${PLUGIN_NAME} PRIVATE 
  "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/libwebrtc/lib/libwebrtc.so"
)

# List of absolute paths to libraries that should be bundled with the plugin
set(flutter_webrtc_bundled_libraries
  "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/libwebrtc/lib/libwebrtc.so"
  PARENT_SCOPE
)

# Add $ORIGIN to RPATH so that lib/libflutter_webrtc_plugin.so can find lib/libwebrtc.so at runtime
set_property(
    TARGET ${PLUGIN_NAME}
    PROPERTY BUILD_RPATH
    "\$ORIGIN"
)
