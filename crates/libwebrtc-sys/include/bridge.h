#pragma once

#include <functional>
#include "api/audio_codecs/builtin_audio_decoder_factory.h"
#include "api/audio_codecs/builtin_audio_encoder_factory.h"
#include "api/create_peerconnection_factory.h"
#include "api/peer_connection_interface.h"
#include "api/task_queue/default_task_queue_factory.h"
#include "api/video_codecs/builtin_video_decoder_factory.h"
#include "api/video_codecs/builtin_video_encoder_factory.h"
#include "api/video_track_source_proxy_factory.h"
#if __APPLE__
  #include "libwebrtc-sys/include/device_info_mac.h"
  #include "mac_capturer.h"
  #include "device_info_mac.h"
#else
  #include "device_video_capturer.h"
#endif
#include "modules/audio_device/include/audio_device.h"
#include "modules/video_capture/video_capture_factory.h"
#include "pc/audio_track.h"
#include "pc/local_audio_source.h"
#include "pc/video_track_source.h"
#include "peer_connection.h"
#include "rust/cxx.h"
#include "screen_video_capturer.h"
#include "video_sink.h"

#include "adm_proxy.h"

#include "media/base/fake_frame_source.h"
#include "pc/test/fake_video_track_source.h"
#include "modules/audio_device/include/test_audio_device.h"

namespace bridge {

struct DynTrackEventCallback;

// `TrackEventObserver` propagating track events to the Rust side.
class TrackEventObserver : public webrtc::ObserverInterface {
 public:
  // Creates a new `TrackEventObserver`.
  TrackEventObserver(rust::Box<bridge::DynTrackEventCallback> cb);

  // Called whenever the track calls `set_state()` or `set_enabled()`.
  void OnChanged();

  // Sets the inner `MediaStreamTrackInterface`.
  void set_track(rtc::scoped_refptr<webrtc::MediaStreamTrackInterface> track);

 private:
  // `MediaStreamTrackInterface` to determine the event.
  std::optional<rtc::scoped_refptr<webrtc::MediaStreamTrackInterface>> track_;

  // Rust side callback.
  rust::Box<bridge::DynTrackEventCallback> cb_;
};

struct TransceiverContainer;
struct DisplaySourceContainer;
struct StringPair;
struct RtpCodecParametersContainer;
struct RtpExtensionContainer;
struct RtpEncodingParametersContainer;

using Thread = rtc::Thread;
using VideoSinkInterface = rtc::VideoSinkInterface<webrtc::VideoFrame>;

using MediaType = cricket::MediaType;

using AudioLayer = webrtc::AudioDeviceModule::AudioLayer;
using BundlePolicy = webrtc::PeerConnectionInterface::BundlePolicy;
using IceCandidateInterface = webrtc::IceCandidateInterface;
using IceConnectionState = webrtc::PeerConnectionInterface::IceConnectionState;
using IceGatheringState = webrtc::PeerConnectionInterface::IceGatheringState;
using IceServer = webrtc::PeerConnectionInterface::IceServer;
using IceTransportsType = webrtc::PeerConnectionInterface::IceTransportsType;
using PeerConnectionDependencies = webrtc::PeerConnectionDependencies;
using PeerConnectionState =
    webrtc::PeerConnectionInterface::PeerConnectionState;
using RTCConfiguration = webrtc::PeerConnectionInterface::RTCConfiguration;
using SdpType = webrtc::SdpType;
using SignalingState = webrtc::PeerConnectionInterface::SignalingState;
using TaskQueueFactory = webrtc::TaskQueueFactory;
using VideoDeviceInfo = webrtc::VideoCaptureModule::DeviceInfo;
using DisplaySource = webrtc::DesktopCapturer::Source;
using VideoRotation = webrtc::VideoRotation;
using RtpTransceiverDirection = webrtc::RtpTransceiverDirection;
using TrackState = webrtc::MediaStreamTrackInterface::TrackState;

using AudioDeviceModule = rtc::scoped_refptr<webrtc::AudioDeviceModule>;
using AudioProcessing = rtc::scoped_refptr<webrtc::AudioProcessing>;
using AudioSourceInterface = rtc::scoped_refptr<webrtc::AudioSourceInterface>;
using AudioTrackInterface = rtc::scoped_refptr<webrtc::AudioTrackInterface>;
using MediaStreamInterface = rtc::scoped_refptr<webrtc::MediaStreamInterface>;
using PeerConnectionFactoryInterface =
    rtc::scoped_refptr<webrtc::PeerConnectionFactoryInterface>;
using RtpSenderInterface = rtc::scoped_refptr<webrtc::RtpSenderInterface>;
using VideoTrackInterface = rtc::scoped_refptr<webrtc::VideoTrackInterface>;
using VideoTrackSourceInterface =
    rtc::scoped_refptr<webrtc::VideoTrackSourceInterface>;
using RtpReceiverInterface = rtc::scoped_refptr<webrtc::RtpReceiverInterface>;
using MediaStreamTrackInterface =
    rtc::scoped_refptr<webrtc::MediaStreamTrackInterface>;

// Creates a new proxied `AudioDeviceModule` for the given `AudioLayer`.
std::unique_ptr<AudioDeviceModule> create_audio_device_module(
    Thread& worker_thread,
    AudioLayer audio_layer,
    TaskQueueFactory& task_queue_factory);

// Creates a new fake `AudioDeviceModule`.
std::unique_ptr<AudioDeviceModule> create_fake_audio_device_module(
    TaskQueueFactory& task_queue_factory);

// Initializes the native audio parts required for each platform.
int32_t init_audio_device_module(const AudioDeviceModule& audio_device_module);

// Initializes the microphone in the audio device module.
int32_t init_microphone(const AudioDeviceModule& audio_device_module);

// Indicates whether the microphone of the audio device module is initialized.
bool microphone_is_initialized(const AudioDeviceModule& audio_device_module);

// Sets the volume of the initialized microphone.
int32_t set_microphone_volume(const AudioDeviceModule& audio_device_module,
                              uint32_t volume);

// Indicates whether the microphone is available to set volume.
int32_t microphone_volume_is_available(
    const AudioDeviceModule& audio_device_module,
    bool& is_available);

// Returns the lowest possible level of the microphone volume.
int32_t min_microphone_volume(const AudioDeviceModule& audio_device_module,
                              uint32_t& volume);

// Returns the highest possible level of the microphone volume.
int32_t max_microphone_volume(const AudioDeviceModule& audio_device_module,
                              uint32_t& volume);

// Returns the current level of the microphone volume.
int32_t microphone_volume(const AudioDeviceModule& audio_device_module,
                          uint32_t& volume);

// Returns count of the available playout audio devices.
int16_t playout_devices(const AudioDeviceModule& audio_device_module);

// Returns count of the available recording audio devices.
int16_t recording_devices(const AudioDeviceModule& audio_device_module);

// Obtains information regarding the specified audio playout device.
int32_t playout_device_name(const AudioDeviceModule& audio_device_module,
                            int16_t index,
                            rust::String& name,
                            rust::String& guid);

// Obtains information regarding the specified audio recording device.
int32_t recording_device_name(const AudioDeviceModule& audio_device_module,
                              int16_t index,
                              rust::String& name,
                              rust::String& guid);

// Specifies which microphone to use for recording audio using an index
// retrieved by the corresponding enumeration method which is
// `AudiDeviceModule::RecordingDeviceName`.
int32_t set_audio_recording_device(const AudioDeviceModule& audio_device_module,
                                   uint16_t index);

// Specifies which device to use for playout audio using an index
// retrieved by the corresponding enumeration method which is
// `AudiDeviceModule::PlayoutDeviceName`.
int32_t set_audio_playout_device(const AudioDeviceModule& audio_device_module,
                                 uint16_t index);

// Creates a new `AudioProcessing`.
std::unique_ptr<AudioProcessing> create_audio_processing();

// Indicates intent to mute the output of the provided `AudioProcessing`.
//
// Set it to `true` when the output of the provided `AudioProcessing` will be
// muted or in some other way not used. Ideally, the captured audio would still
// be processed, but some components may change behavior based on this
// information.
void set_output_will_be_muted(const AudioProcessing& ap, bool muted);

// Creates a new `VideoDeviceInfo`.
std::unique_ptr<VideoDeviceInfo> create_video_device_info();

// Obtains information regarding the specified video recording device.
int32_t video_device_name(VideoDeviceInfo& device_info,
                          uint32_t index,
                          rust::String& name,
                          rust::String& guid);

// Creates a new `Thread`.
std::unique_ptr<rtc::Thread> create_thread();

// Creates a new `Thread` with a socket server.
std::unique_ptr<rtc::Thread> create_thread_with_socket_server();

// Creates a new `VideoTrackSourceInterface` from the specified video input
// device according to the specified constraints.
std::unique_ptr<VideoTrackSourceInterface> create_device_video_source(
    Thread& worker_thread,
    Thread& signaling_thread,
    size_t width,
    size_t height,
    size_t fps,
    uint32_t device_index);

// Creates a new fake `DeviceVideoCapturer` with the specified constraints and
// calls `CreateVideoTrackSourceProxy()`.
std::unique_ptr<VideoTrackSourceInterface> create_fake_device_video_source(
    Thread& worker_thread,
    Thread& signaling_thread,
    size_t width,
    size_t height,
    size_t fps);

// Starts screen capturing and creates a new `VideoTrackSourceInterface`
// according to the specified constraints.
std::unique_ptr<VideoTrackSourceInterface> create_display_video_source(
    Thread& worker_thread,
    Thread& signaling_thread,
    int64_t id,
    size_t width,
    size_t height,
    size_t fps);

// Creates a new `AudioSourceInterface`.
std::unique_ptr<AudioSourceInterface> create_audio_source(
    const PeerConnectionFactoryInterface& peer_connection_factory);

// Creates a new `VideoTrackInterface`.
std::unique_ptr<VideoTrackInterface> create_video_track(
    const PeerConnectionFactoryInterface& peer_connection_factory,
    rust::String id,
    const VideoTrackSourceInterface& video_source);

// Creates a new `AudioTrackInterface`.
std::unique_ptr<AudioTrackInterface> create_audio_track(
    const PeerConnectionFactoryInterface& peer_connection_factory,
    rust::String id,
    const AudioSourceInterface& audio_source);

// Creates a new `MediaStreamInterface`.
std::unique_ptr<MediaStreamInterface> create_local_media_stream(
    const PeerConnectionFactoryInterface& peer_connection_factory,
    rust::String id);

// Adds the provided `VideoTrackInterface` to the specified
// `MediaStreamInterface`.
bool add_video_track(const MediaStreamInterface& media_stream,
                     const VideoTrackInterface& track);

// Adds the provided `AudioTrackInterface` to the specified
// `MediaStreamInterface`.
bool add_audio_track(const MediaStreamInterface& media_stream,
                     const AudioTrackInterface& track);

// Removes the provided `VideoTrackInterface` to the specified
// `MediaStreamInterface`.
bool remove_video_track(const MediaStreamInterface& media_stream,
                        const VideoTrackInterface& track);

// Removes the provided `AudioTrackInterface` to the specified
// `MediaStreamInterface`.
bool remove_audio_track(const MediaStreamInterface& media_stream,
                        const AudioTrackInterface& track);

// Changes the `enabled` property of the provided `VideoTrackInterface`.
void set_video_track_enabled(const VideoTrackInterface& track, bool enabled);

// Changes the `enabled` property of the provided `AudioTrackInterface`.
void set_audio_track_enabled(const AudioTrackInterface& track, bool enabled);

// Returns the `state` property of the provided `VideoTrackInterface`.
TrackState video_track_state(const VideoTrackInterface& track);

// Returns the `state` property of the provided `AudioTrackInterface`.
TrackState audio_track_state(const AudioTrackInterface& track);

// Registers the provided video `sink` for the given `track`.
//
// Used to connect the given `track` to the underlying video engine.
void add_or_update_video_sink(const VideoTrackInterface& track,
                              VideoSinkInterface& sink);

// Detaches the provided video `sink` from the given `track`.
void remove_video_sink(const VideoTrackInterface& track,
                       VideoSinkInterface& sink);

// Creates a new `ForwardingVideoSink`.
std::unique_ptr<VideoSinkInterface> create_forwarding_video_sink(
    rust::Box<DynOnFrameCallback> handler);

// Converts the provided `webrtc::VideoFrame` pixels to the ABGR scheme and
// writes the result to the provided `dst_abgr`.
void video_frame_to_abgr(const webrtc::VideoFrame& frame, uint8_t* dst_abgr);

// Converts the provided `webrtc::VideoFrame` pixels to the ARGB scheme and
// writes the result to the provided `dst_argb`.
void video_frame_to_argb(const webrtc::VideoFrame& frame, uint8_t* dst_argb);

// Creates a new `PeerConnectionFactoryInterface`.
std::unique_ptr<PeerConnectionFactoryInterface> create_peer_connection_factory(
    const std::unique_ptr<Thread>& network_thread,
    const std::unique_ptr<Thread>& worker_thread,
    const std::unique_ptr<Thread>& signaling_thread,
    const std::unique_ptr<AudioDeviceModule>& default_adm,
    const std::unique_ptr<AudioProcessing>& ap);

// Creates a new `PeerConnectionInterface`.
std::unique_ptr<PeerConnectionInterface> create_peer_connection_or_error(
    PeerConnectionFactoryInterface& peer_connection_factory,
    const RTCConfiguration& configuration,
    std::unique_ptr<PeerConnectionDependencies> dependencies,
    rust::String& error);

// Creates a new default `RTCConfiguration`.
std::unique_ptr<RTCConfiguration> create_default_rtc_configuration();

// Sets the `IceTransportsType` for the provided `RTCConfiguration`.
void set_rtc_configuration_ice_transport_type(RTCConfiguration& config,
                                              IceTransportsType transport_type);

// Sets the `BundlePolicy` for the provided `RTCConfiguration`.
void set_rtc_configuration_bundle_policy(RTCConfiguration& config,
                                         BundlePolicy bundle_policy);

// Adds the `IceServer` to the provided `RTCConfiguration`.
void add_rtc_configuration_server(RTCConfiguration& config, IceServer& server);

// Creates a new empty `IceServer`.
std::unique_ptr<IceServer> create_ice_server();

// Adds the specified `url` to the provided `IceServer`.
void add_ice_server_url(IceServer& server, rust::String url);

// Sets the specified credentials for the provided `IceServer`.
void set_ice_server_credentials(IceServer& server,
                                rust::String username,
                                rust::String password);

// Creates a new `PeerConnectionObserver` backed by the provided
// `DynPeerConnectionEventsHandler`.
std::unique_ptr<PeerConnectionObserver> create_peer_connection_observer(
    rust::Box<bridge::DynPeerConnectionEventsHandler> cb);

// Creates a new `PeerConnectionDependencies`.
std::unique_ptr<PeerConnectionDependencies> create_peer_connection_dependencies(
    const std::unique_ptr<PeerConnectionObserver>& observer);

// Creates a new `RTCOfferAnswerOptions`.
std::unique_ptr<RTCOfferAnswerOptions>
create_default_rtc_offer_answer_options();

// Creates a new `RTCOfferAnswerOptions`.
std::unique_ptr<RTCOfferAnswerOptions> create_rtc_offer_answer_options(
    int32_t offer_to_receive_video,
    int32_t offer_to_receive_audio,
    bool voice_activity_detection,
    bool ice_restart,
    bool use_rtp_mux);

// Creates a new `CreateSessionDescriptionObserver` from the provided
// `bridge::DynCreateSdpCallback`.
std::unique_ptr<CreateSessionDescriptionObserver>
create_create_session_observer(rust::Box<bridge::DynCreateSdpCallback> cb);

// Creates a new `SetLocalDescriptionObserverInterface` from the provided
// `bridge::DynSetDescriptionCallback`.
std::unique_ptr<SetLocalDescriptionObserver>
create_set_local_description_observer(
    rust::Box<bridge::DynSetDescriptionCallback> cb);

// Creates a new `SetRemoteDescriptionObserverInterface` from the provided
// `bridge::DynSetDescriptionCallback`.
std::unique_ptr<SetRemoteDescriptionObserver>
create_set_remote_description_observer(
    rust::Box<bridge::DynSetDescriptionCallback> cb);

// Returns the `RtpExtension.uri` field value.
std::unique_ptr<std::string> rtp_extension_uri(
    const webrtc::RtpExtension& extension);

// Returns the `RtpExtension.id` field value.
int32_t rtp_extension_id(const webrtc::RtpExtension& extension);

// Returns the `RtpExtension.encrypt` field value.
bool rtp_extension_encrypt(const webrtc::RtpExtension& extension);

// Returns the `RtcpParameters.cname` field value.
std::unique_ptr<std::string> rtcp_parameters_cname(
    const webrtc::RtcpParameters& rtcp);

// Returns the`RtcpParameters.reduced_size` field value.
bool rtcp_parameters_reduced_size(const webrtc::RtcpParameters& rtcp);

// Returns the `VideoTrackInterface` of the provided
// `VideoTrackSourceInterface`.
std::unique_ptr<VideoTrackSourceInterface> get_video_track_source(
    const VideoTrackInterface& track);

// Returns the `AudioSourceInterface` of the provided
// `AudioTrackInterface`.
std::unique_ptr<AudioSourceInterface> get_audio_track_source(
    const AudioTrackInterface& track);

// Creates an SDP-ized form of this `Candidate`.

// Returns `CandidatePairChangeEvent.candidate_pair` field value.
const cricket::CandidatePair& get_candidate_pair(
    const cricket::CandidatePairChangeEvent& event);

// Returns `CandidatePairChangeEvent.last_data_received_ms` field value.
int64_t get_last_data_received_ms(
    const cricket::CandidatePairChangeEvent& event);

// Returns `CandidatePairChangeEvent.reason` field value.
std::unique_ptr<std::string> get_reason(
    const cricket::CandidatePairChangeEvent& event);

// Returns `CandidatePairChangeEvent.estimated_disconnected_time_ms` field
// value.
int64_t get_estimated_disconnected_time_ms(
    const cricket::CandidatePairChangeEvent& event);

// Returns a `mid` of the given `RtpTransceiverInterface`.
rust::String get_transceiver_mid(const RtpTransceiverInterface& transceiver);

// Returns a `MediaType` of the given `RtpTransceiverInterface`.
MediaType get_transceiver_media_type(
    const RtpTransceiverInterface& transceiver);

// Returns a `direction` of the given `RtpTransceiverInterface`.
RtpTransceiverDirection get_transceiver_direction(
    const RtpTransceiverInterface& transceiver);

// Changes the preferred `RtpTransceiverInterface` direction to the given
// `RtpTransceiverDirection`.
rust::String set_transceiver_direction(
    const RtpTransceiverInterface& transceiver,
    RtpTransceiverDirection new_direction);

// Irreversibly marks the `transceiver` as stopping, unless it's already
// stopped.
//
// This will immediately cause the `transceiver`'s sender to no longer send, and
// its receiver to no longer receive.
rust::String stop_transceiver(const RtpTransceiverInterface& transceiver);

// Creates a new `TrackEventObserver` from the provided
// `bridge::DynTrackEventCallback`.
std::unique_ptr<TrackEventObserver> create_track_event_observer(
    rust::Box<bridge::DynTrackEventCallback> cb);

// Changes the `track` member of the provided `TrackEventObserver`.
void set_track_observer_video_track(TrackEventObserver& obs,
                                    const VideoTrackInterface& track);

// Changes the `track` member of the provided `TrackEventObserver`.
void set_track_observer_audio_track(TrackEventObserver& obs,
                                    const AudioTrackInterface& track);

// Calls `VideoTrackInterface->RegisterObserver`.
void video_track_register_observer(VideoTrackInterface& track,
                                   TrackEventObserver& obs);

// Calls `AudioTrackInterface->RegisterObserver`.
void audio_track_register_observer(AudioTrackInterface& track,
                                   TrackEventObserver& obs);

// Calls `VideoTrackInterface->UnregisterObserver`.
void video_track_unregister_observer(VideoTrackInterface& track,
                                     TrackEventObserver& obs);

// Calls `AudioTrackInterface->UnregisterObserver`.
void audio_track_unregister_observer(AudioTrackInterface& track,
                                     TrackEventObserver& obs);

// Returns the `RtpSenderInterface` of the provided `RtpTransceiverInterface`.
std::unique_ptr<RtpSenderInterface> transceiver_sender(
    const RtpTransceiverInterface& transceiver);

// Returns the `receiver` of the provided `RtpTransceiverInterface`.
std::unique_ptr<RtpReceiverInterface> transceiver_receiver(
    const RtpTransceiverInterface& transceiver);

// Calls `Candidate->ToString`.
std::unique_ptr<std::string> candidate_to_string(
    const cricket::Candidate& candidate);

// Returns the `parameters` as `std::vector<(std::string, std::string)>` of the
// provided `RtpCodecParameters`.
std::unique_ptr<std::vector<StringPair>> rtp_codec_parameters_parameters(
    const webrtc::RtpCodecParameters& codec);

// Returns the `RtpParameters.codecs` field value.
rust::Vec<RtpCodecParametersContainer> rtp_parameters_codecs(
    const webrtc::RtpParameters& parameters);

// Returns the `RtpParameters.header_extensions` field value.
rust::Vec<RtpExtensionContainer> rtp_parameters_header_extensions(
    const webrtc::RtpParameters& parameters);

// Returns the `RtpParameters.encodings` field value.
rust::Vec<RtpEncodingParametersContainer> rtp_parameters_encodings(
    const webrtc::RtpParameters& parameters);

// Calls `IceCandidateInterface->ToString`.
std::unique_ptr<std::string> ice_candidate_interface_to_string(
    const IceCandidateInterface& candidate);

// Returns the `sdp_mid` of the provided `IceCandidateInterface`.
std::unique_ptr<std::string> sdp_mid_of_ice_candidate(
    const IceCandidateInterface& candidate);

// Returns the `sdp_mline_index` of the provided `IceCandidateInterface`.
int sdp_mline_index_of_ice_candidate(const IceCandidateInterface& candidate);

// Returns a list of all available `DesktopCapturer::Source`s.
rust::Vec<DisplaySourceContainer> screen_capture_sources();

// Returns an `id` of the provided `DesktopCapturer::Source`.
int64_t display_source_id(const DisplaySource& source);

// Returns a `title` of the provided `DesktopCapturer::Source`.
std::unique_ptr<std::string> display_source_title(const DisplaySource& source);

// Creates a new `IceCandidateInterface`.
std::unique_ptr<webrtc::IceCandidateInterface> create_ice_candidate(
    rust::Str sdp_mid,
    int sdp_mline_index,
    rust::Str candidate,
    rust::String& error);

}  // namespace bridge
