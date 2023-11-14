#ifndef BRIDGE_STATS_H_
#define BRIDGE_STATS_H_

#include "api/stats/rtc_stats_collector_callback.h"
#include "api/stats/rtcstats_objects.h"
#include "rust/cxx.h"

namespace bridge {

using RTCStatsReport = rtc::scoped_refptr<const webrtc::RTCStatsReport>;
using RTCStats = webrtc::RTCStats;

struct RTCStatsWrap;
struct RTCMediaSourceStatsWrap;
struct RTCVideoSourceStatsWrap;
struct RTCAudioSourceStatsWrap;
struct RTCIceCandidateStatsWrap;
struct RTCOutboundRTPStreamStatsWrap;
struct RTCInboundRTPStreamStatsWrap;
struct RTCIceCandidatePairStatsWrap;
struct RTCTransportStatsWrap;
struct RTCRemoteInboundRtpStreamStatsWrap;
struct RTCRemoteOutboundRtpStreamStatsWrap;

using RTCMediaSourceStats = webrtc::RTCMediaSourceStats;
using RTCVideoSourceStats = webrtc::RTCVideoSourceStats;
using RTCAudioSourceStats = webrtc::RTCAudioSourceStats;
using RTCIceCandidateStats = webrtc::RTCIceCandidateStats;
using RTCOutboundRTPStreamStats = webrtc::RTCOutboundRtpStreamStats;
using RTCInboundRTPStreamStats = webrtc::RTCInboundRtpStreamStats;
using RTCIceCandidatePairStats = webrtc::RTCIceCandidatePairStats;
using RTCTransportStats = webrtc::RTCTransportStats;
using RTCRemoteInboundRtpStreamStats = webrtc::RTCRemoteInboundRtpStreamStats;
using RTCRemoteOutboundRtpStreamStats = webrtc::RTCRemoteOutboundRtpStreamStats;

// Tries to cast `RTCStats` into wrapped `RTCIceCandidateStats`.
RTCIceCandidateStatsWrap cast_to_rtc_ice_candidate_stats(
    std::unique_ptr<RTCStats> stats);

// Tries to cast `RTCStats` into wrapped `RTCOutboundRTPStreamStats`.
RTCOutboundRTPStreamStatsWrap cast_to_rtc_outbound_rtp_stream_stats(
    std::unique_ptr<RTCStats> stats);

// Tries to cast `RTCStats` into wrapped `RTCInboundRTPStreamStats`.
RTCInboundRTPStreamStatsWrap cast_to_rtc_inbound_rtp_stream_stats(
    std::unique_ptr<RTCStats> stats);

// Tries to cast `RTCStats` into wrapped `RTCIceCandidatePairStats`.
RTCIceCandidatePairStatsWrap cast_to_rtc_ice_candidate_pair_stats(
    std::unique_ptr<RTCStats> stats);

// Tries to cast `RTCStats` into wrapped `RTCTransportStats`.
RTCTransportStatsWrap cast_to_rtc_transport_stats(
    std::unique_ptr<RTCStats> stats);

// Tries to cast `RTCStats` into wrapped `RTCRemoteInboundRtpStreamStats`.
RTCRemoteInboundRtpStreamStatsWrap cast_to_rtc_remote_inbound_rtp_stream_stats(
    std::unique_ptr<RTCStats> stats);

// Tries to cast `RTCStats` into wrapped `RTCRemoteOutboundRtpStreamStats`.
RTCRemoteOutboundRtpStreamStatsWrap
cast_to_rtc_remote_outbound_rtp_stream_stats(std::unique_ptr<RTCStats> stats);

// Tries to cast `RTCStats` into wrapped `RTCMediaSourceStats`.
RTCMediaSourceStatsWrap cast_to_rtc_media_source_stats(
    std::unique_ptr<RTCStats> stats);

// Tries to cast `RTCMediaSourceStats` into wrapped `RTCAudioSourceStats`.
RTCAudioSourceStatsWrap cast_to_rtc_audio_source_stats(
    std::unique_ptr<RTCMediaSourceStats> stats);

// Tries to cast `RTCMediaSourceStats` into wrapped `RTCVideoSourceStats`.
RTCVideoSourceStatsWrap cast_to_rtc_video_source_stats(
    std::unique_ptr<RTCMediaSourceStats> stats);

// Returns collection of wrapped `RTCStats` of the provided `RTCStatsReport`.
rust::Vec<RTCStatsWrap> rtc_stats_report_get_stats(
    const RTCStatsReport& report);

}  // namespace bridge

#endif // BRIDGE_STATS_H_
