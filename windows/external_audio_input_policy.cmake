# Detect the dependent factory API without making stock SDK users link it.
function(flutter_webrtc_configure_external_input target sdk_include)
  include(CheckCXXSourceCompiles)
  set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
  set(CMAKE_REQUIRED_INCLUDES "${sdk_include}")
  set(CMAKE_REQUIRED_DEFINITIONS -DLIB_WEBRTC_API_DLL -DRTC_DESKTOP_DEVICE)
  unset(FLUTTER_WEBRTC_HAS_EXTERNAL_AUDIO_INPUT_POLICY CACHE)
  check_cxx_source_compiles("#include <libwebrtc.h>
int main() {
  libwebrtc::RTCPeerConnectionFactoryOptions options;
  options.external_audio_input_only = true;
  auto factory = libwebrtc::LibWebRTC::CreateRTCPeerConnectionFactory(options);
  return 0;
}" FLUTTER_WEBRTC_HAS_EXTERNAL_AUDIO_INPUT_POLICY)
  if(FLUTTER_WEBRTC_HAS_EXTERNAL_AUDIO_INPUT_POLICY)
    target_compile_definitions(${target} PRIVATE FLUTTER_WEBRTC_HAS_EXTERNAL_AUDIO_INPUT_POLICY=1)
  endif()
endfunction()
