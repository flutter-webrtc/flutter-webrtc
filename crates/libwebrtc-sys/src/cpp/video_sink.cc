#include "libwebrtc-sys/include/video_sink.h"
#include "libwebrtc-sys/src/bridge.rs.h"

namespace video_sink {

// Creates a new `ForwardingVideoSink` backed by the provided
// `DynOnFrameCallback`.
ForwardingVideoSink::ForwardingVideoSink(
    rust::Box<bridge::DynOnFrameCallback> cb_) : cb_(std::move(cb_)) {}

// Propagates the received `VideoFrame` to the Rust side.
void ForwardingVideoSink::OnFrame(const webrtc::VideoFrame& video_frame) {
  bridge::on_frame(*cb_.value(),
                   std::make_unique<webrtc::VideoFrame>(video_frame));
}

}  // namespace video_sink
