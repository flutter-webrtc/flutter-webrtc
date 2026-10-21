#ifndef FLUTTER_WEBRTC_BASE_HXX
#define FLUTTER_WEBRTC_BASE_HXX

#include "flutter_common.h"

#include <string.h>
#include <list>
#include <map>
#include <memory>
#include <mutex>
#include <vector>

#include "libwebrtc.h"

#include "rtc_audio_device.h"
#include "rtc_audio_processing.h"
#include "rtc_desktop_device.h"
#include "rtc_dtmf_sender.h"
#include "rtc_frame_cryptor.h"
#include "rtc_media_stream.h"
#include "rtc_media_track.h"
#include "rtc_mediaconstraints.h"
#include "rtc_peerconnection.h"
#include "rtc_peerconnection_factory.h"
#include "rtc_video_device.h"
#include "rtc_video_processor.h"
#include "rtc_video_source.h"

namespace flutter_webrtc_plugin {

using namespace libwebrtc;

class FlutterVideoRenderer;
class FlutterRTCDataChannelObserver;
class FlutterPeerConnectionObserver;

class FlutterWebRTCBase {
 public:
  friend class FlutterMediaStream;
  friend class FlutterPeerConnection;
  friend class FlutterVideoRendererManager;
  friend class FlutterDataChannel;
  friend class FlutterPeerConnectionObserver;
  friend class FlutterScreenCapture;
  friend class FlutterFrameCryptor;
  friend class FlutterDataPacketCryptor;
  friend class FlutterRemoteAudioTap;
  enum ParseConstraintType { kMandatory, kOptional };

 public:
  FlutterWebRTCBase(BinaryMessenger* messenger,
                    TextureRegistrar* textures,
                    TaskRunner* task_runner);
  ~FlutterWebRTCBase();

  // Initializes WebRTC and creates the peer connection factory the first time
  // it is needed, applying the process global field trials that the
  // `initialize()` options ask for. Field trials are read when the factory is
  // created, so only the first call decides them; later calls are no-ops.
  void EnsureWebRTCInitialized(bool enable_warp = false,
                               bool zero_playout_delay = false);

  virtual scoped_refptr<RTCAudioProcessing> audio_processing() {
    EnsureWebRTCInitialized();
    return audio_processing_;
  }

  virtual scoped_refptr<RTCMediaTrack> MediaTrackForId(const std::string& id);

  // Runs `processor` on every frame of the local video track `track_id`
  // before the frame is encoded or rendered. This is the desktop counterpart
  // of Android's LocalVideoTrack.addProcessor and Darwin's addProcessing, and
  // works for camera and screen capture tracks. Returns false if `track_id`
  // is not a local video track created by this plugin.
  //
  // Call both methods on the platform thread. The caller owns `processor`.
  // Remove it before the track is disposed and before freeing it, and free it
  // only after RemoveVideoProcessor() returns, since removal waits for a
  // frame that is being processed. If the track is disposed first, the
  // dispose removes any processor still attached and RemoveVideoProcessor()
  // returns false from then on.
  //
  // These are virtual so that other plugins can call them through
  // FlutterWebRTCPluginSharedInstance() (Windows, eLinux) or
  // flutter_webrtc_plugin_get_shared_instance() (Linux) without linking to
  // them.
  virtual bool AddVideoProcessor(const std::string& track_id,
                                 RTCVideoProcessor* processor);

  virtual bool RemoveVideoProcessor(const std::string& track_id,
                                    RTCVideoProcessor* processor);

  std::string GenerateUUID();

  RTCPeerConnection* PeerConnectionForId(const std::string& id);

  void RemovePeerConnectionForId(const std::string& id);

  void RemoveMediaTrackForId(const std::string& id);

  FlutterPeerConnectionObserver* PeerConnectionObserversForId(
      const std::string& id);

  void RemovePeerConnectionObserversForId(const std::string& id);

  scoped_refptr<RTCMediaStream> MediaStreamForId(
      const std::string& id,
      std::string ownerTag = std::string());

  void RemoveStreamForId(const std::string& id);

  bool ParseConstraints(const EncodableMap& constraints,
                        RTCConfiguration* configuration);

  scoped_refptr<RTCMediaConstraints> ParseMediaConstraints(
      const EncodableMap& constraints);

  bool ParseRTCConfiguration(const EncodableMap& map,
                             RTCConfiguration& configuration);

  scoped_refptr<RTCMediaTrack> MediaTracksForId(const std::string& id);

  void RemoveTracksForId(const std::string& id);

  EventChannelProxy* event_channel();

  libwebrtc::scoped_refptr<libwebrtc::RTCRtpSender> GetRtpSenderById(
      RTCPeerConnection* pc,
      std::string id);

  libwebrtc::scoped_refptr<libwebrtc::RTCRtpReceiver> GetRtpReceiverById(
      RTCPeerConnection* pc,
      std::string id);

  libwebrtc::scoped_refptr<libwebrtc::KeyProvider> GetKeyProviderForId(
      const std::string& keyProviderId);

 private:
  void ParseConstraints(const EncodableMap& src,
                        scoped_refptr<RTCMediaConstraints> mediaConstraints,
                        ParseConstraintType type = kMandatory);

  bool CreateIceServers(const EncodableList& iceServersArray,
                        IceServer* ice_servers);

  // Detaches the processors of a local video track and forgets its source.
  void RemoveVideoSourceForId(const std::string& track_id);

  struct LocalVideoSource {
    scoped_refptr<RTCVideoSource> source;
    std::vector<RTCVideoProcessor*> processors;
  };

 protected:
  bool webrtc_initialized_ = false;
  // Whether `enableWARP` was requested; peer connections created afterwards
  // default to DSCP marking. See EnsureWebRTCInitialized().
  bool warp_enabled_ = false;
  scoped_refptr<RTCPeerConnectionFactory> factory_;
  scoped_refptr<RTCAudioDevice> audio_device_;
  scoped_refptr<RTCVideoDevice> video_device_;
  scoped_refptr<RTCDesktopDevice> desktop_device_;
  scoped_refptr<RTCAudioProcessing> audio_processing_;
  RTCConfiguration configuration_;

  std::map<std::string, scoped_refptr<libwebrtc::KeyProvider>> key_providers_;
  std::map<std::string, scoped_refptr<RTCPeerConnection>> peerconnections_;
  std::map<std::string, scoped_refptr<RTCMediaStream>> local_streams_;
  std::map<std::string, scoped_refptr<RTCMediaTrack>> local_tracks_;
  std::map<std::string, scoped_refptr<RTCVideoCapturer>> video_capturers_;
  // Sources of the local video tracks in `local_tracks_`, keyed by track id.
  std::map<std::string, LocalVideoSource> video_sources_;
  std::map<int64_t, std::shared_ptr<FlutterVideoRenderer>> renders_;
  std::map<std::string, std::shared_ptr<FlutterRTCDataChannelObserver>>
      data_channel_observers_;
  std::map<std::string, std::shared_ptr<FlutterPeerConnectionObserver>>
      peerconnection_observers_;
  mutable std::mutex mutex_;

  void lock() { mutex_.lock(); }
  void unlock() { mutex_.unlock(); }

 protected:
  BinaryMessenger* messenger_;
  TaskRunner* task_runner_;
  TextureRegistrar* textures_;
  std::unique_ptr<EventChannelProxy> event_channel_;
};

}  // namespace flutter_webrtc_plugin

#endif  // !FLUTTER_WEBRTC_BASE_HXX
