#include <cstdint>
#include <memory>
#include <string>

#include <chrono>
#include <thread>

#include "api/video/i420_buffer.h"
#include "api/video_codecs/video_decoder_factory_template.h"
#include "api/video_codecs/video_decoder_factory_template_dav1d_adapter.h"
#include "api/video_codecs/video_decoder_factory_template_libvpx_vp8_adapter.h"
#include "api/video_codecs/video_decoder_factory_template_libvpx_vp9_adapter.h"
#include "api/video_codecs/video_decoder_factory_template_open_h264_adapter.h"
#include "api/video_codecs/video_encoder_factory_template.h"
#include "api/video_codecs/video_encoder_factory_template_libaom_av1_adapter.h"
#include "api/video_codecs/video_encoder_factory_template_libvpx_vp8_adapter.h"
#include "api/video_codecs/video_encoder_factory_template_libvpx_vp9_adapter.h"
#include "api/video_codecs/video_encoder_factory_template_open_h264_adapter.h"
#include "libwebrtc-sys/include/bridge.h"
#include "libwebrtc-sys/src/bridge.rs.h"
#include "libyuv.h"
#include "modules/audio_device/include/audio_device_factory.h"
#include "pc/proxy.h"
#include "test_audio_device_module.cc"

namespace bridge {

// Creates a new `TrackEventObserver`.
TrackEventObserver::TrackEventObserver(
    rust::Box<bridge::DynTrackEventCallback> cb)
    : cb_(std::move(cb)){};

// Called when the `MediaStreamTrackInterface`, that this `TrackEventObserver`
// is attached to, has its state changed.
void TrackEventObserver::OnChanged() {
  if (track_) {
    if (track_.value()->state() ==
        webrtc::MediaStreamTrackInterface::TrackState::kEnded) {
      bridge::on_ended(*cb_);
    }
  }
}

// Sets the inner `MediaStreamTrackInterface`.
void TrackEventObserver::set_track(
    rtc::scoped_refptr<webrtc::MediaStreamTrackInterface> track) {
  track_ = track;
}

// Creates a new fake `DeviceVideoCapturer` with the specified constraints and
// calls `CreateVideoTrackSourceProxy()`.
std::unique_ptr<VideoTrackSourceInterface> create_fake_device_video_source(
    Thread& worker_thread,
    Thread& signaling_thread,
    size_t width,
    size_t height,
    size_t fps) {
  auto src = webrtc::FakeVideoTrackSource::Create();

  int fps_ms = 1000 / fps;
  int timestamp_offset_us = 1000000 / fps;
  auto th = std::thread([=] {
    auto frame = cricket::FakeFrameSource(width, height, timestamp_offset_us);
    while (true) {
      src->InjectFrame(frame.GetFrame());
      std::this_thread::sleep_for(std::chrono::milliseconds(fps_ms));
    }
  });
  th.detach();

  auto proxied = webrtc::CreateVideoTrackSourceProxy(&signaling_thread,
                                                     &worker_thread, src.get());
  if (proxied == nullptr) {
    return nullptr;
  }

  return std::make_unique<VideoTrackSourceInterface>(proxied);
}

// Creates a new fake `AudioDeviceModule` with `PulsedNoiseCapturer` and without
// audio renderer.
std::unique_ptr<AudioDeviceModule> create_fake_audio_device_module(
    TaskQueueFactory& task_queue_factory) {
  auto capture = webrtc::CreatePulsedNoiseCapturer(1024, 8000, 1);
  auto renderer = webrtc::CreateDiscardRenderer(8000, 1);

  auto adm_fake = webrtc::CreateTestAdm(&task_queue_factory, std::move(capture),
                                        std::move(renderer), 1);

  return std::make_unique<AudioDeviceModule>(adm_fake);
}

// Creates a new `DeviceVideoCapturer` with the specified constraints and
// calls `CreateVideoTrackSourceProxy()`.
std::unique_ptr<VideoTrackSourceInterface> create_device_video_source(
    Thread& worker_thread,
    Thread& signaling_thread,
    size_t width,
    size_t height,
    size_t fps,
    uint32_t device) {
#if __APPLE__
  auto dvc = signaling_thread.BlockingCall([width, height, fps, device] {
    return MacCapturer::Create(width, height, fps, device);
  });
#else
  auto dvc = signaling_thread.BlockingCall([width, height, fps, device] {
    return DeviceVideoCapturer::Create(width, height, fps, device);
  });
#endif

  if (dvc == nullptr) {
    return nullptr;
  }

  auto src = webrtc::CreateVideoTrackSourceProxy(&signaling_thread,
                                                 &worker_thread, dvc.get());
  if (src == nullptr) {
    return nullptr;
  }

  return std::make_unique<VideoTrackSourceInterface>(src);
}

// Creates a new `AudioDeviceModuleProxy`.
std::unique_ptr<AudioDeviceModule> create_audio_device_module(
    Thread& worker_thread,
    AudioLayer audio_layer,
    TaskQueueFactory& task_queue_factory) {
  AudioDeviceModule adm =
      worker_thread.BlockingCall([audio_layer, &task_queue_factory] {
        return ::OpenALAudioDeviceModule::Create(audio_layer, &task_queue_factory);
      });

  if (adm == nullptr) {
    return nullptr;
  }

  AudioDeviceModule proxied =
      webrtc::AudioDeviceModuleProxy::Create(&worker_thread, adm);

  return std::make_unique<AudioDeviceModule>(proxied);
}

// Calls `AudioDeviceModule->Init()`.
int32_t init_audio_device_module(const AudioDeviceModule& audio_device_module) {
  return audio_device_module->Init();
}

// Calls `AudioDeviceModule->InitMicrophone()`.
int32_t init_microphone(const AudioDeviceModule& audio_device_module) {
  return audio_device_module->InitMicrophone();
}

// Calls `AudioDeviceModule->MicrophoneIsInitialized()`.
bool microphone_is_initialized(const AudioDeviceModule& audio_device_module) {
  return audio_device_module->MicrophoneIsInitialized();
}

// Calls `AudioDeviceModule->SetMicrophoneVolume()`.
int32_t set_microphone_volume(const AudioDeviceModule& audio_device_module,
                              uint32_t volume) {
  return audio_device_module->SetMicrophoneVolume(volume);
}

// Calls `AudioDeviceModule->MicrophoneVolumeIsAvailable()`.
int32_t microphone_volume_is_available(
    const AudioDeviceModule& audio_device_module,
    bool& is_available) {
  return audio_device_module->MicrophoneVolumeIsAvailable(&is_available);
}

// Calls `AudioDeviceModule->MinMicrophoneVolume()`.
int32_t min_microphone_volume(const AudioDeviceModule& audio_device_module,
                              uint32_t& volume) {
  return audio_device_module->MinMicrophoneVolume(&volume);
}

// Calls `AudioDeviceModule->MaxMicrophoneVolume()`.
int32_t max_microphone_volume(const AudioDeviceModule& audio_device_module,
                              uint32_t& volume) {
  return audio_device_module->MaxMicrophoneVolume(&volume);
}

// Calls `AudioDeviceModule->MicrophoneVolume()`.
int32_t microphone_volume(const AudioDeviceModule& audio_device_module,
                          uint32_t& volume) {
  return audio_device_module->MicrophoneVolume(&volume);
}

// Calls `AudioDeviceModule->PlayoutDevices()`.
int16_t playout_devices(const AudioDeviceModule& audio_device_module) {
  return audio_device_module->PlayoutDevices();
}

// Calls `AudioDeviceModule->RecordingDevices()`.
int16_t recording_devices(const AudioDeviceModule& audio_device_module) {
  return audio_device_module->RecordingDevices();
}

// Calls `AudioDeviceModule->PlayoutDeviceName()` with the provided arguments.
int32_t playout_device_name(const AudioDeviceModule& audio_device_module,
                            int16_t index,
                            rust::String& name,
                            rust::String& guid) {
  char name_buff[webrtc::kAdmMaxDeviceNameSize];
  char guid_buff[webrtc::kAdmMaxGuidSize];

  const int32_t result =
      audio_device_module->PlayoutDeviceName(index, name_buff, guid_buff);
  name = name_buff;
  guid = guid_buff;

  return result;
}

// Calls `AudioDeviceModule->RecordingDeviceName()` with the provided arguments.
int32_t recording_device_name(const AudioDeviceModule& audio_device_module,
                              int16_t index,
                              rust::String& name,
                              rust::String& guid) {
  char name_buff[webrtc::kAdmMaxDeviceNameSize];
  char guid_buff[webrtc::kAdmMaxGuidSize];

  const int32_t result =
      audio_device_module->RecordingDeviceName(index, name_buff, guid_buff);

  name = name_buff;
  guid = guid_buff;

  return result;
}

// Calls `AudioDeviceModule->SetRecordingDevice()` with the provided arguments.
int32_t set_audio_recording_device(const AudioDeviceModule& audio_device_module,
                                   uint16_t index) {
  return audio_device_module->SetRecordingDevice(index);
}

// Stops playout of audio on the specified device.
int32_t stop_playout(const AudioDeviceModule& audio_device_module) {
  return audio_device_module->StopPlayout();
}

// Sets stereo availability of the specified playout device.
int32_t stereo_playout_is_available(
    const AudioDeviceModule& audio_device_module,
    bool available) {
  return audio_device_module->StereoPlayoutIsAvailable(&available);
}

// Initializes the specified audio playout device.
int32_t init_playout(const AudioDeviceModule& audio_device_module) {
  return audio_device_module->InitPlayout();
}

// Starts playout of audio on the specified device.
int32_t start_playout(const AudioDeviceModule& audio_device_module) {
  return audio_device_module->StartPlayout();
}

// Calls `AudioDeviceModule->SetPlayoutDevice()` with the provided device index.
int32_t set_audio_playout_device(const AudioDeviceModule& audio_device_module,
                                 uint16_t index) {
  return audio_device_module->SetPlayoutDevice(index);
}

// Calls `AudioProcessingBuilder().Create()`.
std::unique_ptr<AudioProcessing> create_audio_processing() {
  auto ap = webrtc::AudioProcessingBuilder().Create();

  return std::make_unique<AudioProcessing>(ap);
}

// Calls `AudioProcessing->set_output_will_be_muted()`.
void set_output_will_be_muted(const AudioProcessing& ap, bool muted) {
  ap->set_output_will_be_muted(muted);
}

// Calls `VideoCaptureFactory->CreateDeviceInfo()`.
std::unique_ptr<VideoDeviceInfo> create_video_device_info() {
#if __APPLE__
  return create_device_info_mac();
#else
  std::unique_ptr<VideoDeviceInfo> ptr(
      webrtc::VideoCaptureFactory::CreateDeviceInfo());

  return ptr;
#endif
}

// Calls `VideoDeviceInfo->GetDeviceName()` with the provided arguments.
int32_t video_device_name(VideoDeviceInfo& device_info,
                          uint32_t index,
                          rust::String& name,
                          rust::String& guid) {
  char name_buff[256];
  char guid_buff[256];

  const int32_t size =
      device_info.GetDeviceName(index, name_buff, 256, guid_buff, 256);

  name = name_buff;
  guid = guid_buff;

  return size;
}

// Calls `Thread->Create()`.
std::unique_ptr<rtc::Thread> create_thread() {
  return rtc::Thread::Create();
}

// Creates a default `TaskQueueFactory`, basing on the current platform.
std::unique_ptr<TaskQueueFactory> create_default_task_queue_factory() {
  return webrtc::CreateDefaultTaskQueueFactory();
}

// Calls `Thread->CreateWithSocketServer()`.
std::unique_ptr<rtc::Thread> create_thread_with_socket_server() {
  return rtc::Thread::CreateWithSocketServer();
}

// Creates a new `ScreenVideoCapturer` with the specified constraints and
// calls `CreateVideoTrackSourceProxy()`.
std::unique_ptr<VideoTrackSourceInterface> create_display_video_source(
    Thread& worker_thread,
    Thread& signaling_thread,
    int64_t id,
    size_t width,
    size_t height,
    size_t fps) {
  rtc::scoped_refptr<ScreenVideoCapturer> capturer(
      new rtc::RefCountedObject<ScreenVideoCapturer>(id, width, height, fps));

  auto src = webrtc::CreateVideoTrackSourceProxy(
      &signaling_thread, &worker_thread, capturer.get());

  if (src == nullptr) {
    return nullptr;
  }

  return std::make_unique<VideoTrackSourceInterface>(src);
}

// Calls `PeerConnectionFactoryInterface->CreateAudioSource()` with empty
// `AudioOptions`.
std::unique_ptr<AudioSourceInterface> create_audio_source(
    const PeerConnectionFactoryInterface& peer_connection_factory) {
  auto src =
      peer_connection_factory->CreateAudioSource(cricket::AudioOptions());

  if (src == nullptr) {
    return nullptr;
  }

  return std::make_unique<AudioSourceInterface>(src);
}

// Calls `PeerConnectionFactoryInterface->CreateVideoTrack`.
std::unique_ptr<VideoTrackInterface> create_video_track(
    const PeerConnectionFactoryInterface& peer_connection_factory,
    rust::String id,
    const VideoTrackSourceInterface& video_source) {
  auto track = peer_connection_factory->CreateVideoTrack(std::string(id),
                                                         video_source.get());

  if (track == nullptr) {
    return nullptr;
  }

  return std::make_unique<VideoTrackInterface>(track);
}

// Calls `PeerConnectionFactoryInterface->CreateAudioTrack`.
std::unique_ptr<AudioTrackInterface> create_audio_track(
    const PeerConnectionFactoryInterface& peer_connection_factory,
    rust::String id,
    const AudioSourceInterface& audio_source) {
  auto track = peer_connection_factory->CreateAudioTrack(std::string(id),
                                                         audio_source.get());

  if (track == nullptr) {
    return nullptr;
  }

  return std::make_unique<AudioTrackInterface>(track);
}

// Calls `MediaStreamInterface->CreateLocalMediaStream`.
std::unique_ptr<MediaStreamInterface> create_local_media_stream(
    const PeerConnectionFactoryInterface& peer_connection_factory,
    rust::String id) {
  auto stream =
      peer_connection_factory->CreateLocalMediaStream(std::string(id));

  if (stream == nullptr) {
    return nullptr;
  }

  return std::make_unique<MediaStreamInterface>(stream);
}

// Calls `MediaStreamInterface->AddTrack`.
bool add_video_track(const MediaStreamInterface& media_stream,
                     const VideoTrackInterface& track) {
  return media_stream->AddTrack(track);
}

// Calls `MediaStreamInterface->AddTrack`.
bool add_audio_track(const MediaStreamInterface& media_stream,
                     const AudioTrackInterface& track) {
  return media_stream->AddTrack(track);
}

// Calls `MediaStreamInterface->RemoveTrack`.
bool remove_video_track(const MediaStreamInterface& media_stream,
                        const VideoTrackInterface& track) {
  return media_stream->RemoveTrack(track);
}

// Calls `MediaStreamInterface->RemoveTrack`.
bool remove_audio_track(const MediaStreamInterface& media_stream,
                        const AudioTrackInterface& track) {
  return media_stream->RemoveTrack(track);
}

// Calls `VideoTrackInterface->set_enabled()`.
void set_video_track_enabled(const VideoTrackInterface& track, bool enabled) {
  track->set_enabled(enabled);
}

// Calls `AudioTrackInterface->set_enabled()`.
void set_audio_track_enabled(const AudioTrackInterface& track, bool enabled) {
  track->set_enabled(enabled);
}

// Calls `VideoTrackInterface->state()`.
TrackState video_track_state(const VideoTrackInterface& track) {
  return track->state();
}

// Calls `AudioTrackInterface->state()`.
TrackState audio_track_state(const AudioTrackInterface& track) {
  return track->state();
}

// Registers the provided video `sink` for the given `track`.
//
// Used to connect the given `track` to the underlying video engine.
void add_or_update_video_sink(const VideoTrackInterface& track,
                              VideoSinkInterface& sink) {
  track->AddOrUpdateSink(&sink, rtc::VideoSinkWants());
}

// Detaches the provided video `sink` from the given `track`.
void remove_video_sink(const VideoTrackInterface& track,
                       VideoSinkInterface& sink) {
  track->RemoveSink(&sink);
}

// Creates a new `ForwardingVideoSink`.
std::unique_ptr<VideoSinkInterface> create_forwarding_video_sink(
    rust::Box<DynOnFrameCallback> cb) {
  return std::make_unique<video_sink::ForwardingVideoSink>(std::move(cb));
}

// Converts the provided `webrtc::VideoFrame` pixels to the ABGR scheme and
// writes the result to the provided `dst_abgr`.
void video_frame_to_abgr(const webrtc::VideoFrame& frame, uint8_t* dst_abgr) {
  rtc::scoped_refptr<webrtc::I420BufferInterface> buffer(
      frame.video_frame_buffer()->ToI420());

  libyuv::I420ToABGR(buffer->DataY(), buffer->StrideY(), buffer->DataU(),
                     buffer->StrideU(), buffer->DataV(), buffer->StrideV(),
                     dst_abgr, buffer->width() * 4, buffer->width(),
                     buffer->height());
}

// Converts the provided `webrtc::VideoFrame` pixels to the ARGB scheme and
// writes the result to the provided `dst_argb`.
void video_frame_to_argb(const webrtc::VideoFrame& frame,
                         int argb_stride,
                         uint8_t* dst_argb) {
  rtc::scoped_refptr<webrtc::I420BufferInterface> buffer(
      frame.video_frame_buffer()->ToI420());

  libyuv::I420ToARGB(buffer->DataY(), buffer->StrideY(), buffer->DataU(),
                     buffer->StrideU(), buffer->DataV(), buffer->StrideV(),
                     dst_argb, argb_stride, buffer->width(), buffer->height());
}

// Creates a new `PeerConnectionFactoryInterface`.
std::unique_ptr<PeerConnectionFactoryInterface> create_peer_connection_factory(
    const std::unique_ptr<Thread>& network_thread,
    const std::unique_ptr<Thread>& worker_thread,
    const std::unique_ptr<Thread>& signaling_thread,
    const std::unique_ptr<AudioDeviceModule>& default_adm,
    const std::unique_ptr<AudioProcessing>& ap) {
  std::unique_ptr<webrtc::VideoEncoderFactory> video_encoder_factory =
      std::make_unique<webrtc::VideoEncoderFactoryTemplate<
          webrtc::LibvpxVp8EncoderTemplateAdapter,
          webrtc::LibvpxVp9EncoderTemplateAdapter,
          webrtc::OpenH264EncoderTemplateAdapter,
          webrtc::LibaomAv1EncoderTemplateAdapter>>();
  std::unique_ptr<webrtc::VideoDecoderFactory> video_decoder_factory =
      std::make_unique<webrtc::VideoDecoderFactoryTemplate<
          webrtc::LibvpxVp8DecoderTemplateAdapter,
          webrtc::LibvpxVp9DecoderTemplateAdapter,
          webrtc::OpenH264DecoderTemplateAdapter,
          webrtc::Dav1dDecoderTemplateAdapter>>();

  auto factory = webrtc::CreatePeerConnectionFactory(
      network_thread.get(), worker_thread.get(), signaling_thread.get(),
      default_adm ? *default_adm : nullptr,
      webrtc::CreateBuiltinAudioEncoderFactory(),
      webrtc::CreateBuiltinAudioDecoderFactory(),
      std::move(video_encoder_factory), std::move(video_decoder_factory),
      nullptr, ap ? *ap : nullptr);

  if (factory == nullptr) {
    return nullptr;
  }
  return std::make_unique<PeerConnectionFactoryInterface>(factory);
}

// Calls `PeerConnectionFactoryInterface->CreatePeerConnectionOrError`.
std::unique_ptr<PeerConnectionInterface> create_peer_connection_or_error(
    PeerConnectionFactoryInterface& peer_connection_factory,
    const RTCConfiguration& configuration,
    std::unique_ptr<PeerConnectionDependencies> dependencies,
    rust::String& error) {
  auto pc = peer_connection_factory->CreatePeerConnectionOrError(
      configuration, std::move(*dependencies));

  if (pc.ok()) {
    return std::make_unique<PeerConnectionInterface>(pc.MoveValue());
  }

  error = rust::String(pc.MoveError().message());
  return nullptr;
}

// Creates a new default `RTCConfiguration`.
std::unique_ptr<RTCConfiguration> create_default_rtc_configuration() {
  auto config = std::make_unique<RTCConfiguration>();
  config->sdp_semantics = webrtc::SdpSemantics::kUnifiedPlan;
  return config;
}

// Sets the `type` field of the provided `RTCConfiguration`.
void set_rtc_configuration_ice_transport_type(
    RTCConfiguration& config,
    IceTransportsType transport_type) {
  config.type = transport_type;
}

// Sets the `bundle_policy` field of the provided `RTCConfiguration`.
void set_rtc_configuration_bundle_policy(RTCConfiguration& config,
                                         BundlePolicy bundle_policy) {
  config.bundle_policy = bundle_policy;
}

// Adds the specified `IceServer` to the `servers` list of the provided
// `RTCConfiguration`.
void add_rtc_configuration_server(RTCConfiguration& config, IceServer& server) {
  config.servers.push_back(server);
}

// Creates a new empty `IceServer`.
std::unique_ptr<IceServer> create_ice_server() {
  return std::make_unique<IceServer>();
}

// Adds the specified `url` to the list of `urls` of the provided `IceServer`.
void add_ice_server_url(IceServer& server, rust::String url) {
  server.urls.push_back(std::string(url));
}

// Sets the specified `username` and `password` fields of the provided
// `IceServer`.
void set_ice_server_credentials(IceServer& server,
                                rust::String username,
                                rust::String password) {
  server.username = std::string(username);
  server.password = std::string(password);
}

// Creates a new `PeerConnectionObserver`.
std::unique_ptr<PeerConnectionObserver> create_peer_connection_observer(
    rust::Box<bridge::DynPeerConnectionEventsHandler> cb) {
  return std::make_unique<PeerConnectionObserver>(
      PeerConnectionObserver(std::move(cb)));
}

// Creates a new `PeerConnectionDependencies`.
std::unique_ptr<PeerConnectionDependencies> create_peer_connection_dependencies(
    const std::unique_ptr<PeerConnectionObserver>& observer) {
  PeerConnectionDependencies pcd(observer.get());
  return std::make_unique<PeerConnectionDependencies>(std::move(pcd));
}

// Creates a new `RTCOfferAnswerOptions`.
std::unique_ptr<RTCOfferAnswerOptions>
create_default_rtc_offer_answer_options() {
  return std::make_unique<RTCOfferAnswerOptions>();
}

// Creates a new `RTCOfferAnswerOptions`.
std::unique_ptr<RTCOfferAnswerOptions> create_rtc_offer_answer_options(
    int32_t offer_to_receive_video,
    int32_t offer_to_receive_audio,
    bool voice_activity_detection,
    bool ice_restart,
    bool use_rtp_mux) {
  return std::make_unique<RTCOfferAnswerOptions>(
      offer_to_receive_video, offer_to_receive_audio, voice_activity_detection,
      ice_restart, use_rtp_mux);
}

// Creates a new default `RtpTransceiverInit`.
std::unique_ptr<RtpTransceiverInit> create_default_rtp_transceiver_init() {
  return std::make_unique<RtpTransceiverInit>();
}

// Sets an `RtpTransceiverDirection` for the provided `RtpTransceiverInit`.
void set_rtp_transceiver_init_direction(
    RtpTransceiverInit& init,
    webrtc::RtpTransceiverDirection direction) {
  init.direction = direction;
}

// Adds an `RtpEncodingParameters` to the provided `RtpTransceiverInit`.
void add_rtp_transceiver_init_send_encoding(
    RtpTransceiverInit& init,
    const RtpEncodingParametersContainer& params) {
  init.send_encodings.push_back(*params.ptr);
}

// Creates new default `RtpEncodingParameters`.
RtpEncodingParametersContainer create_rtp_encoding_parameters() {
  RtpEncodingParametersContainer res = {
      std::make_unique<webrtc::RtpEncodingParameters>()};
  return res;
}

// Creates a new `CreateSessionDescriptionObserver` from the provided
// `bridge::DynCreateSdpCallback`.
std::unique_ptr<CreateSessionDescriptionObserver>
create_create_session_observer(rust::Box<bridge::DynCreateSdpCallback> cb) {
  return std::make_unique<CreateSessionDescriptionObserver>(std::move(cb));
}

// Creates a new `SetLocalDescriptionObserverInterface` from the provided
// `bridge::DynSetDescriptionCallback`.
std::unique_ptr<SetLocalDescriptionObserver>
create_set_local_description_observer(
    rust::Box<bridge::DynSetDescriptionCallback> cb) {
  return std::make_unique<SetLocalDescriptionObserver>(std::move(cb));
}

// Creates a new `SetRemoteDescriptionObserverInterface` from the provided
// `bridge::DynSetDescriptionCallback`.
std::unique_ptr<SetRemoteDescriptionObserver>
create_set_remote_description_observer(
    rust::Box<bridge::DynSetDescriptionCallback> cb) {
  return std::make_unique<SetRemoteDescriptionObserver>(std::move(cb));
}

// Returns the `RtpExtension.uri` field value.
std::unique_ptr<std::string> rtp_extension_uri(
    const webrtc::RtpExtension& extension) {
  return std::make_unique<std::string>(extension.uri);
}

// Returns the `RtpExtension.id` field value.
int32_t rtp_extension_id(const webrtc::RtpExtension& extension) {
  return extension.id;
}

// Returns the `RtpExtension.encrypt` field value.
bool rtp_extension_encrypt(const webrtc::RtpExtension& extension) {
  return extension.encrypt;
}

// Returns the `RtcpParameters.cname` field value.
std::unique_ptr<std::string> rtcp_parameters_cname(
    const webrtc::RtcpParameters& rtcp) {
  return std::make_unique<std::string>(rtcp.cname);
}

// Returns the `RtcpParameters.reduced_size` field value.
bool rtcp_parameters_reduced_size(const webrtc::RtcpParameters& rtcp) {
  return rtcp.reduced_size;
}

// Returns the `VideoTrackInterface` of the provided
// `VideoTrackSourceInterface`.
std::unique_ptr<VideoTrackSourceInterface> get_video_track_source(
    const VideoTrackInterface& track) {
  return std::make_unique<VideoTrackSourceInterface>(track->GetSource());
}

// Returns the `AudioSourceInterface` of the provided `AudioTrackInterface`.
std::unique_ptr<AudioSourceInterface> get_audio_track_source(
    const AudioTrackInterface& track) {
  return std::make_unique<AudioSourceInterface>(track->GetSource());
}

// Calls `IceCandidateInterface->ToString`.
std::unique_ptr<std::string> ice_candidate_interface_to_string(
    const IceCandidateInterface& candidate) {
  std::string out;
  candidate.ToString(&out);
  return std::make_unique<std::string>(out);
};

// Calls `Candidate->ToString`.
std::unique_ptr<std::string> candidate_to_string(
    const cricket::Candidate& candidate) {
  return std::make_unique<std::string>(candidate.ToString());
};

// Returns `CandidatePairChangeEvent.candidate_pair` field value.
const cricket::CandidatePair& get_candidate_pair(
    const cricket::CandidatePairChangeEvent& event) {
  return event.selected_candidate_pair;
};

// Returns `CandidatePairChangeEvent.last_data_received_ms` field value.
int64_t get_last_data_received_ms(
    const cricket::CandidatePairChangeEvent& event) {
  return event.last_data_received_ms;
}

// Returns `CandidatePairChangeEvent.reason` field value.
std::unique_ptr<std::string> get_reason(
    const cricket::CandidatePairChangeEvent& event) {
  return std::make_unique<std::string>(event.reason);
}

// Returns `CandidatePairChangeEvent.estimated_disconnected_time_ms` field
// value.
int64_t get_estimated_disconnected_time_ms(
    const cricket::CandidatePairChangeEvent& event) {
  return event.estimated_disconnected_time_ms;
}

// Calls `RtpTransceiverInterface->mid()`.
rust::String get_transceiver_mid(const RtpTransceiverInterface& transceiver) {
  return rust::String(transceiver->mid().value_or(""));
}

// Calls `RtpTransceiverInterface->media_type()`.
MediaType get_transceiver_media_type(
    const RtpTransceiverInterface& transceiver) {
  return transceiver->media_type();
}

// Calls `RtpTransceiverInterface->direction()`.
RtpTransceiverDirection get_transceiver_direction(
    const RtpTransceiverInterface& transceiver) {
  return transceiver->direction();
}

// Calls `RtpTransceiverInterface->SetDirectionWithError()`.
rust::String set_transceiver_direction(
    const RtpTransceiverInterface& transceiver,
    webrtc::RtpTransceiverDirection new_direction) {
  webrtc::RTCError result = transceiver->SetDirectionWithError(new_direction);
  rust::String error;

  if (!result.ok()) {
    error = result.message();
  }
  return error;
}

// Calls `RtpTransceiverInterface->StopStandard()`.
rust::String stop_transceiver(const RtpTransceiverInterface& transceiver) {
  webrtc::RTCError result = transceiver->StopStandard();
  rust::String error;

  if (!result.ok()) {
    error = result.message();
  }
  return error;
}

// Creates a new `TrackEventObserver` from the provided
// `bridge::DynTrackEventCallback`.
std::unique_ptr<TrackEventObserver> create_track_event_observer(
    rust::Box<bridge::DynTrackEventCallback> cb) {
  return std::make_unique<TrackEventObserver>(
      TrackEventObserver(std::move(cb)));
}

// Changes the `track` member of the provided `TrackEventObserver`.
void set_track_observer_video_track(TrackEventObserver& obs,
                                    const VideoTrackInterface& track) {
  obs.set_track(track);
}

// Changes the `track` member of the provided `TrackEventObserver`.
void set_track_observer_audio_track(TrackEventObserver& obs,
                                    const AudioTrackInterface& track) {
  obs.set_track(track);
}

// Calls `VideoTrackInterface->RegisterObserver`.
void video_track_register_observer(VideoTrackInterface& track,
                                   TrackEventObserver& obs) {
  track->RegisterObserver(&obs);
}

// Calls `AudioTrackInterface->RegisterObserver`.
void audio_track_register_observer(AudioTrackInterface& track,
                                   TrackEventObserver& obs) {
  track->RegisterObserver(&obs);
}

// Calls `VideoTrackInterface->UnregisterObserver`.
void video_track_unregister_observer(VideoTrackInterface& track,
                                     TrackEventObserver& obs) {
  track->UnregisterObserver(&obs);
}

// Calls `AudioTrackInterface->UnregisterObserver`.
void audio_track_unregister_observer(AudioTrackInterface& track,
                                     TrackEventObserver& obs) {
  track->UnregisterObserver(&obs);
}

// Calls `RtpTransceiverInterface->sender()`.
std::unique_ptr<RtpSenderInterface> transceiver_sender(
    const RtpTransceiverInterface& transceiver) {
  return std::make_unique<RtpSenderInterface>(transceiver->sender());
}

// Returns the `receiver` of the provided `RtpTransceiverInterface`.
std::unique_ptr<RtpReceiverInterface> transceiver_receiver(
    const RtpTransceiverInterface& transceiver) {
  return std::make_unique<RtpReceiverInterface>(transceiver->receiver());
}

// Returns the `parameters` as `std::vector<(std::string, std::string)>` of the
// provided `RtpCodecParameters`.
std::unique_ptr<std::vector<StringPair>> rtp_codec_parameters_parameters(
    const webrtc::RtpCodecParameters& codec) {
  std::vector<StringPair> result;
  for (auto const& p : codec.parameters) {
    result.push_back(new_string_pair(p.first, p.second));
  }
  return std::make_unique<std::vector<StringPair>>(result);
}

// Returns the `RtpParameters.codecs` field value.
rust::Vec<RtpCodecParametersContainer> rtp_parameters_codecs(
    const webrtc::RtpParameters& parameters) {
  rust::Vec<RtpCodecParametersContainer> result;
  for (int i = 0; i < parameters.codecs.size(); ++i) {
    RtpCodecParametersContainer codec = {
        std::make_unique<webrtc::RtpCodecParameters>(parameters.codecs[i])};
    result.push_back(std::move(codec));
  }
  return std::move(result);
}

// Returns the `RtpParameters.header_extensions` field value.
rust::Vec<RtpExtensionContainer> rtp_parameters_header_extensions(
    const webrtc::RtpParameters& parameters) {
  rust::Vec<RtpExtensionContainer> result;
  for (int i = 0; i < parameters.header_extensions.size(); ++i) {
    RtpExtensionContainer codec = {std::make_unique<webrtc::RtpExtension>(
        parameters.header_extensions[i])};
    result.push_back(std::move(codec));
  }
  return std::move(result);
}

// Returns the `RtpParameters.encodings` field value.
rust::Vec<RtpEncodingParametersContainer> rtp_parameters_encodings(
    const webrtc::RtpParameters& parameters) {
  rust::Vec<RtpEncodingParametersContainer> result;
  for (int i = 0; i < parameters.encodings.size(); ++i) {
    RtpEncodingParametersContainer codec = {
        std::make_unique<webrtc::RtpEncodingParameters>(
            parameters.encodings[i])};
    result.push_back(std::move(codec));
  }
  return std::move(result);
}

// Calls `IceCandidateInterface->sdp_mid()`.
std::unique_ptr<std::string> sdp_mid_of_ice_candidate(
    const IceCandidateInterface& candidate) {
  return std::make_unique<std::string>(candidate.sdp_mid());
}

// Calls `IceCandidateInterface->sdp_mline_index()`.
int sdp_mline_index_of_ice_candidate(const IceCandidateInterface& candidate) {
  return candidate.sdp_mline_index();
}

// Calls `webrtc::CreateIceCandidate` with the given values.
std::unique_ptr<webrtc::IceCandidateInterface> create_ice_candidate(
    rust::Str sdp_mid,
    int sdp_mline_index,
    rust::Str candidate,
    rust::String& error) {
  webrtc::SdpParseError* sdp_error;
  std::unique_ptr<webrtc::IceCandidateInterface> owned_candidate(
      webrtc::CreateIceCandidate(std::string(sdp_mid), sdp_mline_index,
                                 std::string(candidate), sdp_error));

  if (!owned_candidate.get()) {
    error = sdp_error->description;
    return nullptr;
  } else {
    return owned_candidate;
  }
}

// Returns a list of all available `DesktopCapturer::Source`s.
rust::Vec<DisplaySourceContainer> screen_capture_sources() {
  webrtc::DesktopCapturer::SourceList sourceList;
  ScreenVideoCapturer::GetSourceList(&sourceList);
  rust::Vec<DisplaySourceContainer> sources;

  for (auto source : sourceList) {
    DisplaySourceContainer container = {
        std::make_unique<DisplaySource>(source)};
    sources.push_back(std::move(container));
  }

  return sources;
}

// Returns an `id` of the provided `DesktopCapturer::Source`.
int64_t display_source_id(const DisplaySource& source) {
  return source.id;
}

// Returns a `title` of the provided `DesktopCapturer::Source`.
std::unique_ptr<std::string> display_source_title(const DisplaySource& source) {
  return std::make_unique<std::string>(source.title);
}

}  // namespace bridge
