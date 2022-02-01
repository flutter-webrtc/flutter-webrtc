#include <memory>

#include <flutter_webrtc_native.h>
#include "flutter_webrtc.h"
#include "flutter_webrtc/flutter_web_r_t_c_plugin.h"
#include "flutter_webrtc/flutter_webrtc_plugin.h"

using namespace rust::cxxbridge1;

#define DEFAULT_WIDTH 640
#define DEFAULT_HEIGHT 480
#define DEFAULT_FPS 30

// Calls Rust `EnumerateDevices()` and converts the received Rust vector of
// `MediaDeviceInfo` info for Dart.
void enumerate_device(rust::Box<Webrtc>& webrtc,
                      std::unique_ptr<MethodResult<EncodableValue>> result);

// Parses the received constraints from Dart and passes them to Rust
// `GetUserMedia()`, then converts the backed `MediaStream` info for Dart.
void get_user_media(const flutter::MethodCall<EncodableValue>& method_call,
                    Box<Webrtc>& webrtc,
                    std::unique_ptr<MethodResult<EncodableValue>> result);

// Parses video constraints received from Dart to Rust `VideoConstraints`.
VideoConstraints parse_video_constraints(const EncodableValue video_arg);

// Parses audio constraints received from Dart to Rust `AudioConstraints`.
AudioConstraints parse_audio_constraints(const EncodableValue audio_arg);

// Converts Rust `VideoConstraints` or `AudioConstraints` to `EncodableList`
// for passing to Dart according to `TrackKind`.
EncodableList get_params(TrackKind type, MediaStream& user_media);

// Disposes some media stream calling Rust `DisposeStream`.
void dispose_stream(const flutter::MethodCall<EncodableValue>& method_call,
                    Box<Webrtc>& webrtc,
                    std::unique_ptr<MethodResult<EncodableValue>> result);
