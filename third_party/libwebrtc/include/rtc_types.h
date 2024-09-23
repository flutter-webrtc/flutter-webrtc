#ifndef LIB_WEBRTC_RTC_TYPES_HXX
#define LIB_WEBRTC_RTC_TYPES_HXX

#ifdef LIB_WEBRTC_API_EXPORTS
#define LIB_WEBRTC_API __declspec(dllexport)
#elif defined(LIB_WEBRTC_API_DLL)
#define LIB_WEBRTC_API __declspec(dllimport)
#elif !defined(WIN32)
#define LIB_WEBRTC_API __attribute__((visibility("default")))
#else
#define LIB_WEBRTC_API
#endif

#include "base/fixed_size_function.h"
#include "base/portable.h"
#include "base/refcount.h"
#include "base/scoped_ref_ptr.h"

namespace libwebrtc {

enum { kMaxIceServerSize = 8 };

// template <typename T>
// using vector = bsp::inlined_vector<T, 16, true>;

template <typename Key, typename T>
using map = std::map<Key, T>;

enum class MediaSecurityType { kSRTP_None = 0, kSDES_SRTP, kDTLS_SRTP };

enum class RTCMediaType { AUDIO, VIDEO, DATA, UNSUPPORTED };

using string = portable::string;

// template <typename Key, typename T>
// using map = portable::map<Key, T>;

template <typename T>
using vector = portable::vector<T>;

struct IceServer {
  string uri;
  string username;
  string password;
};

enum class IceTransportsType { kNone, kRelay, kNoHost, kAll };

enum class TcpCandidatePolicy {
  kTcpCandidatePolicyEnabled,
  kTcpCandidatePolicyDisabled
};

enum class CandidateNetworkPolicy {
  kCandidateNetworkPolicyAll,
  kCandidateNetworkPolicyLowCost
};

enum class RtcpMuxPolicy {
  kRtcpMuxPolicyNegotiate,
  kRtcpMuxPolicyRequire,
};

enum BundlePolicy {
  kBundlePolicyBalanced,
  kBundlePolicyMaxBundle,
  kBundlePolicyMaxCompat
};

enum class SdpSemantics { kPlanB, kUnifiedPlan };

struct RTCConfiguration {
  IceServer ice_servers[kMaxIceServerSize];
  IceTransportsType type = IceTransportsType::kAll;
  BundlePolicy bundle_policy = BundlePolicy::kBundlePolicyBalanced;
  RtcpMuxPolicy rtcp_mux_policy = RtcpMuxPolicy::kRtcpMuxPolicyRequire;
  CandidateNetworkPolicy candidate_network_policy =
      CandidateNetworkPolicy::kCandidateNetworkPolicyAll;
  TcpCandidatePolicy tcp_candidate_policy =
      TcpCandidatePolicy::kTcpCandidatePolicyEnabled;

  int ice_candidate_pool_size = 0;

  MediaSecurityType srtp_type = MediaSecurityType::kDTLS_SRTP;
  SdpSemantics sdp_semantics = SdpSemantics::kUnifiedPlan;
  bool offer_to_receive_audio = true;
  bool offer_to_receive_video = true;

  bool disable_ipv6 = false;
  bool disable_ipv6_on_wifi = false;
  int max_ipv6_networks = 5;
  bool disable_link_local_networks = false;
  int screencast_min_bitrate = -1;

  // private
  bool use_rtp_mux = true;
  uint32_t local_audio_bandwidth = 128;
  uint32_t local_video_bandwidth = 512;
};

struct SdpParseError {
 public:
  // The sdp line that causes the error.
  string line;
  // Explains the error.
  string description;
};

enum DesktopType { kScreen, kWindow };

}  // namespace libwebrtc

#endif  // LIB_WEBRTC_RTC_TYPES_HXX
