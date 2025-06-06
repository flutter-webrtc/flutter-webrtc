#ifndef BRIDGE_LOCAL_AUDIO_SOURCE_H_
#define BRIDGE_LOCAL_AUDIO_SOURCE_H_

#include <chrono>
#include <mutex>
#include <optional>

#include "api/audio/audio_frame.h"
#include "api/audio_options.h"
#include "api/media_stream_interface.h"
#include "api/notifier.h"
#include "api/scoped_refptr.h"
#include "modules/audio_processing/include/audio_processing.h"
#include "rust/cxx.h"

namespace bridge {

struct DynAudioSourceOnAudioLevelChangeCallback;

// Implementation of an `AudioSourceInterface` with settings for switching audio
// processing on and off.
class LocalAudioSource : public webrtc::Notifier<webrtc::AudioSourceInterface> {
 public:
  // Creates a new `LocalAudioSource`.
  static webrtc::scoped_refptr<LocalAudioSource> Create(
      webrtc::AudioOptions audio_options,
      webrtc::scoped_refptr<webrtc::AudioProcessing> ap);

  SourceState state() const override { return kLive; }
  bool remote() const override { return false; }

  const webrtc::AudioOptions options() const override { return _options; }

  void AddSink(webrtc::AudioTrackSinkInterface* sink) override;
  void RemoveSink(webrtc::AudioTrackSinkInterface* sink) override;

  void OnData(const void* audio_data,
              int bits_per_sample,
              int sample_rate,
              size_t number_of_channels,
              size_t number_of_frames);

  void RegisterAudioLevelObserver(
      rust::Box<bridge::DynAudioSourceOnAudioLevelChangeCallback> cb);

  void UnregisterAudioLevelObserver();

 protected:
  LocalAudioSource() {}
  ~LocalAudioSource() override {}

 private:
  webrtc::AudioOptions _options;
  std::recursive_mutex sink_lock_;
  std::list<webrtc::AudioTrackSinkInterface*> sinks_;
  webrtc::AudioFrame audio_frame_;
  webrtc::scoped_refptr<webrtc::AudioProcessing> audio_processing_;

  // Rust side callback that audio level changes are forwarded to.
  std::optional<rust::Box<bridge::DynAudioSourceOnAudioLevelChangeCallback>>
      cb_;
  std::chrono::steady_clock::time_point last_audio_level_recalculation_ =
      std::chrono::steady_clock::now();
};

}  // namespace bridge

#endif  // BRIDGE_LOCAL_AUDIO_SOURCE_H_
