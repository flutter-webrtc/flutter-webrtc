#ifndef EXAMPLE_CPP_VIDEO_PROCESSOR_SAMPLE_H_
#define EXAMPLE_CPP_VIDEO_PROCESSOR_SAMPLE_H_

#include <map>
#include <memory>
#include <string>

namespace flutter_webrtc_plugin {
class FlutterWebRTC;
}  // namespace flutter_webrtc_plugin

class GrayscaleProcessor;

// Shows how an app or another native plugin can modify the frames of a
// flutter_webrtc local video track on desktop. It attaches a black and white
// filter to a track through FlutterWebRTCBase::AddVideoProcessor.
//
// This file is shared by the Windows, Linux and eLinux runners and does not
// depend on a platform channel API. Each runner forwards these calls from the
// "flutter_webrtc_example/video_processor" method channel:
//   setGrayscale({trackId, enabled}) -> SetGrayscale()
//   remove({trackId})                -> Remove()
// See lib/src/video_processor_sample.dart for the Dart side.
//
// Call all methods on the platform thread, and destroy this object before the
// flutter_webrtc plugin is destroyed.
class VideoProcessorSample {
 public:
  // Returns the flutter_webrtc plugin instance, for example
  // FlutterWebRTCPluginSharedInstance on Windows and eLinux, or
  // flutter_webrtc_plugin_get_shared_instance on Linux.
  using SharedInstanceGetter = flutter_webrtc_plugin::FlutterWebRTC* (*)();

  explicit VideoProcessorSample(SharedInstanceGetter get_shared_instance);
  ~VideoProcessorSample();

  VideoProcessorSample(const VideoProcessorSample&) = delete;
  VideoProcessorSample& operator=(const VideoProcessorSample&) = delete;

  // Turns the filter of `track_id` on or off, attaching it on first use.
  // Returns false if `track_id` is not a local video track of flutter_webrtc.
  bool SetGrayscale(const std::string& track_id, bool enabled);

  // Detaches and frees the filter of `track_id`. Call it before disposing the
  // track. Returns false if no filter was attached.
  bool Remove(const std::string& track_id);

 private:
  SharedInstanceGetter get_shared_instance_;
  std::map<std::string, std::unique_ptr<GrayscaleProcessor>> processors_;
};

#endif  // EXAMPLE_CPP_VIDEO_PROCESSOR_SAMPLE_H_
