#include "libwebrtc-sys/src/bridge.rs.h"
#include "stats.h"

namespace bridge {

// Tries to cast `RTCStats` into wrapped `RTCMediaSourceStats`.
RTCMediaSourceStatsWrap cast_to_rtc_media_source_stats(
    std::unique_ptr<RTCStats> stats) {
  auto type = std::string(stats->type());
  if (type == "media-source") {
    auto cast = std::unique_ptr<RTCMediaSourceStats>(
        static_cast<RTCMediaSourceStats*>(stats.release()));
    auto track_identifier = init_option_string();

    MediaKind kind = MediaKind::Audio;
    if (*cast->kind == "video") {
      kind = MediaKind::Video;
    }

    if (cast->track_identifier.has_value()) {
      track_identifier->set_value(rust::String(*cast->track_identifier));
    }

    return RTCMediaSourceStatsWrap{std::move(track_identifier), kind,
                                   std::move(cast)};
  }
  throw std::invalid_argument(
      "Invalid type. Expected `ice-candidate` but found: " + type);
}

// Tries to cast `RTCStats` into wrapped `RTCIceCandidateStats`.
RTCIceCandidateStatsWrap cast_to_rtc_ice_candidate_stats(
    std::unique_ptr<RTCStats> stats) {
  auto type = std::string(stats->type());
  if (type == "remote-candidate" || type == "local-candidate") {
    auto cast = std::unique_ptr<RTCIceCandidateStats>(
        static_cast<RTCIceCandidateStats*>(stats.release()));
    auto transport_id = init_option_string();
    if (cast->transport_id.has_value()) {
      transport_id->set_value(rust::String(*cast->transport_id));
    }

    auto address = init_option_string();
    if (cast->address.has_value()) {
      address->set_value(rust::String(*cast->address));
    }

    auto port = init_option_i32();
    if (cast->port.has_value()) {
      port->set_value(*cast->port);
    }

    auto protocol = init_option_string();
    if (cast->protocol.has_value()) {
      protocol->set_value(rust::String(*cast->protocol));
    }

    auto priority = init_option_i32();
    if (cast->priority.has_value()) {
      priority->set_value(*cast->priority);
    }

    auto url = init_option_string();
    if (cast->url.has_value()) {
      url->set_value(rust::String(*cast->url));
    }

    CandidateType candidate_type;
    auto candidate_type_str = *cast->candidate_type;
    if (candidate_type_str == "host") {
      candidate_type = CandidateType::kHost;
    } else if (candidate_type_str == "prflx") {
      candidate_type = CandidateType::kPrflx;
    } else if (candidate_type_str == "srflx") {
      candidate_type = CandidateType::kSrflx;
    } else if (candidate_type_str == "relay") {
      candidate_type = CandidateType::kRelay;
    }

    return RTCIceCandidateStatsWrap{
        *cast->is_remote,    std::move(transport_id), std::move(address),
        std::move(port),     std::move(protocol),     candidate_type,
        std::move(priority), std::move(url)};
  }
  throw std::invalid_argument(
      "Invalid type. Expected `local-candidate` or `remote-candidate` but "
      "found: " +
      type);
}

// Tries to cast `RTCStats` into wrapped `RTCOutboundRTPStreamStats`.
RTCOutboundRTPStreamStatsWrap cast_to_rtc_outbound_rtp_stream_stats(
    std::unique_ptr<RTCStats> stats) {
  auto type = std::string(stats->type());
  if (type == "outbound-rtp") {
    auto cast = std::unique_ptr<RTCOutboundRTPStreamStats>(
        static_cast<RTCOutboundRTPStreamStats*>(stats.release()));

    auto track_id = init_option_string();
    if (cast->remote_id.has_value()) {
      track_id->set_value(rust::String(*cast->remote_id));
    }

    auto bytes_sent = init_option_u64();
    if (cast->bytes_sent.has_value()) {
      bytes_sent->set_value(*cast->bytes_sent);
    }

    auto packets_sent = init_option_u32();
    if (cast->packets_sent.has_value()) {
      packets_sent->set_value(*cast->packets_sent);
    }

    auto media_source_id = init_option_string();
    if (cast->media_source_id.has_value()) {
      media_source_id->set_value(rust::String(*cast->media_source_id));
    }

    auto frame_width = init_option_u32();
    auto frame_height = init_option_u32();
    auto frames_per_second = init_option_f64();
    MediaKind kind;
    if (*cast->kind == "audio") {
      kind = MediaKind::Audio;
    } else {
      kind = MediaKind::Video;

      if (cast->frame_width.has_value()) {
        frame_width->set_value(*cast->frame_width);
      }

      if (cast->frame_height.has_value()) {
        frame_height->set_value(*cast->frame_height);
      }

      if (cast->frames_per_second.has_value()) {
        frames_per_second->set_value(*cast->frames_per_second);
      }
    }

    return RTCOutboundRTPStreamStatsWrap{
        std::move(track_id),          kind,
        std::move(frame_width),       std::move(frame_height),
        std::move(frames_per_second), std::move(bytes_sent),
        std::move(packets_sent),      std::move(media_source_id),
    };
  }
  throw std::invalid_argument(
      "Invalid type. Expected `outbound-rtp` but found: " + type);
}

// Tries to cast `RTCStats` into wrapped `RTCInboundRTPStreamStats`.
RTCInboundRTPStreamStatsWrap cast_to_rtc_inbound_rtp_stream_stats(
    std::unique_ptr<RTCStats> stats) {
  auto type = std::string(stats->type());
  if (type == "inbound-rtp") {
    auto cast = std::unique_ptr<RTCInboundRTPStreamStats>(
        static_cast<RTCInboundRTPStreamStats*>(stats.release()));

    auto remote_id = init_option_string();
    if (cast->remote_id.has_value()) {
      remote_id->set_value(rust::String(*cast->remote_id));
    }

    auto total_samples_received = init_option_u64();
    auto concealed_samples = init_option_u64();
    auto silent_concealed_samples = init_option_u64();
    auto audio_level = init_option_f64();
    auto total_audio_energy = init_option_f64();
    auto total_samples_duration = init_option_f64();

    auto frames_decoded = init_option_u32();
    auto key_frames_decoded = init_option_u32();
    auto frame_width = init_option_u32();
    auto frame_height = init_option_u32();
    auto total_inter_frame_delay = init_option_f64();
    auto frames_per_second = init_option_f64();
    auto fir_count = init_option_u32();
    auto pli_count = init_option_u32();
    auto concealment_events = init_option_u64();
    auto frames_received = init_option_i32();
    auto bytes_received = init_option_u64();
    auto packets_received = init_option_u32();
    auto total_decode_time = init_option_f64();
    auto jitter_buffer_emitted_count = init_option_u64();

    MediaKind media_type;
    if (*cast->kind == "audio") {
      media_type = MediaKind::Audio;
      if (cast->total_samples_received.has_value()) {
        total_samples_received->set_value(*cast->total_samples_received);
      }

      if (cast->concealed_samples.has_value()) {
        concealed_samples->set_value(*cast->concealed_samples);
      }

      if (cast->silent_concealed_samples.has_value()) {
        silent_concealed_samples->set_value(*cast->silent_concealed_samples);
      }

      if (cast->audio_level.has_value()) {
        audio_level->set_value(*cast->audio_level);
      }

      if (cast->total_audio_energy.has_value()) {
        total_audio_energy->set_value(*cast->total_audio_energy);
      }

      if (cast->total_samples_duration.has_value()) {
        total_samples_duration->set_value(*cast->total_samples_duration);
      }
    } else {
      media_type = MediaKind::Video;
      if (cast->frames_decoded.has_value()) {
        frames_decoded->set_value(*cast->frames_decoded);
      }

      if (cast->key_frames_decoded.has_value()) {
        key_frames_decoded->set_value(*cast->key_frames_decoded);
      }

      if (cast->frame_width.has_value()) {
        frame_width->set_value(*cast->frame_width);
      }

      if (cast->frame_height.has_value()) {
        frame_height->set_value(*cast->frame_height);
      }

      if (cast->total_inter_frame_delay.has_value()) {
        total_inter_frame_delay->set_value(*cast->total_inter_frame_delay);
      }

      if (cast->frames_per_second.has_value()) {
        frames_per_second->set_value(*cast->frames_per_second);
      }

      if (cast->fir_count.has_value()) {
        fir_count->set_value(*cast->fir_count);
      }

      if (cast->pli_count.has_value()) {
        pli_count->set_value(*cast->pli_count);
      }

      if (cast->concealment_events.has_value()) {
        concealment_events->set_value(*cast->concealment_events);
      }

      if (cast->frames_received.has_value()) {
        frames_received->set_value(*cast->frames_received);
      }
    }

    if (cast->bytes_received.has_value()) {
      bytes_received->set_value(*cast->bytes_received);
    }

    if (cast->packets_received.has_value()) {
      packets_received->set_value(*cast->packets_received);
    }

    if (cast->total_decode_time.has_value()) {
      total_decode_time->set_value(*cast->total_decode_time);
    }
    if (cast->jitter_buffer_emitted_count.has_value()) {
      jitter_buffer_emitted_count->set_value(
          *cast->jitter_buffer_emitted_count);
    }

    return RTCInboundRTPStreamStatsWrap{
        std::move(remote_id),
        media_type,
        std::move(total_samples_received),
        std::move(concealed_samples),
        std::move(silent_concealed_samples),
        std::move(audio_level),
        std::move(total_audio_energy),
        std::move(total_samples_duration),
        std::move(frames_decoded),
        std::move(key_frames_decoded),
        std::move(frame_width),
        std::move(frame_height),
        std::move(total_inter_frame_delay),
        std::move(frames_per_second),
        std::move(fir_count),
        std::move(pli_count),
        std::move(concealment_events),
        std::move(frames_received),
        std::move(bytes_received),
        std::move(packets_received),
        std::move(total_decode_time),
        std::move(jitter_buffer_emitted_count),
    };
  }

  throw std::invalid_argument(
      "Invalid type. Expected `inbound-rtp` but found: " + type);
}

// Tries to cast `RTCStats` into wrapped `RTCIceCandidatePairStats`.
RTCIceCandidatePairStatsWrap cast_to_rtc_ice_candidate_pair_stats(
    std::unique_ptr<RTCStats> stats) {
  auto type = std::string(stats->type());
  if (type == "candidate-pair") {
    auto cast = std::unique_ptr<RTCIceCandidatePairStats>(
        static_cast<RTCIceCandidatePairStats*>(stats.release()));

    RTCStatsIceCandidatePairState state;
    auto state_str = *cast->state;
    if (state_str == "frozen") {
      state = RTCStatsIceCandidatePairState::kFrozen;
    } else if (state_str == "waiting") {
      state = RTCStatsIceCandidatePairState::kWaiting;
    } else if (state_str == "in-progress") {
      state = RTCStatsIceCandidatePairState::kInProgress;
    } else if (state_str == "failed") {
      state = RTCStatsIceCandidatePairState::kFailed;
    } else if (state_str == "succeeded") {
      state = RTCStatsIceCandidatePairState::kSucceeded;
    }

    auto nominated = init_option_bool();
    if (cast->nominated.has_value()) {
      nominated->set_value(*cast->nominated);
    }

    auto bytes_sent = init_option_u64();
    if (cast->bytes_sent.has_value()) {
      bytes_sent->set_value(*cast->bytes_sent);
    }

    auto bytes_received = init_option_u64();
    if (cast->bytes_received.has_value()) {
      bytes_received->set_value(*cast->bytes_received);
    }

    auto total_round_trip_time = init_option_f64();
    if (cast->total_round_trip_time.has_value()) {
      total_round_trip_time->set_value(*cast->total_round_trip_time);
    }

    auto current_round_trip_time = init_option_f64();
    if (cast->current_round_trip_time.has_value()) {
      current_round_trip_time->set_value(*cast->current_round_trip_time);
    }

    auto available_outgoing_bitrate = init_option_f64();
    if (cast->available_outgoing_bitrate.has_value()) {
      available_outgoing_bitrate->set_value(*cast->available_outgoing_bitrate);
    }

    return RTCIceCandidatePairStatsWrap{
        state,
        std::move(nominated),
        std::move(bytes_sent),
        std::move(bytes_received),
        std::move(total_round_trip_time),
        std::move(current_round_trip_time),
        std::move(available_outgoing_bitrate),
    };
  }
  throw std::invalid_argument(
      "Invalid type. Expected `candidate-pair` but found: " + type);
}

// Tries to cast `RTCStats` into wrapped `RTCTransportStats`.
RTCTransportStatsWrap cast_to_rtc_transport_stats(
    std::unique_ptr<RTCStats> stats) {
  auto type = std::string(stats->type());
  if (type == "transport") {
    auto cast = std::unique_ptr<RTCTransportStats>(
        static_cast<RTCTransportStats*>(stats.release()));

    auto packets_sent = init_option_u64();
    if (cast->packets_sent.has_value()) {
      packets_sent->set_value(*cast->packets_sent);
    }

    auto packets_received = init_option_u64();
    if (cast->packets_received.has_value()) {
      packets_received->set_value(*cast->packets_received);
    }

    auto bytes_sent = init_option_u64();
    if (cast->bytes_sent.has_value()) {
      bytes_sent->set_value(*cast->bytes_sent);
    }

    auto bytes_received = init_option_u64();
    if (cast->bytes_received.has_value()) {
      bytes_received->set_value(*cast->bytes_received);
    }

    return RTCTransportStatsWrap{
        std::move(packets_sent),
        std::move(packets_received),
        std::move(bytes_sent),
        std::move(bytes_received),
    };
  }
  throw std::invalid_argument("Invalid type. Expected `transport` but found: " +
                              type);
}

// Tries to cast `RTCStats` into wrapped `RTCRemoteInboundRtpStreamStats`.
RTCRemoteInboundRtpStreamStatsWrap cast_to_rtc_remote_inbound_rtp_stream_stats(
    std::unique_ptr<RTCStats> stats) {
  auto type = std::string(stats->type());
  if (type == "remote-inbound-rtp") {
    auto cast = std::unique_ptr<RTCRemoteInboundRtpStreamStats>(
        static_cast<RTCRemoteInboundRtpStreamStats*>(stats.release()));
    auto local_id = init_option_string();
    if (cast->local_id.has_value()) {
      local_id->set_value(rust::String(*cast->local_id));
    }

    auto round_trip_time = init_option_f64();
    if (cast->round_trip_time.has_value()) {
      round_trip_time->set_value(*cast->round_trip_time);
    }

    auto fraction_lost = init_option_f64();
    if (cast->fraction_lost.has_value()) {
      fraction_lost->set_value(*cast->fraction_lost);
    }

    auto round_trip_time_measurements = init_option_i32();
    if (cast->round_trip_time_measurements.has_value()) {
      round_trip_time_measurements->set_value(
          *cast->round_trip_time_measurements);
    }

    return RTCRemoteInboundRtpStreamStatsWrap{
        std::move(local_id),
        std::move(round_trip_time),
        std::move(fraction_lost),
        std::move(round_trip_time_measurements),
    };
  }
  throw std::invalid_argument(
      "Invalid type. Expected `remote-inbound-rtp` but found: " + type);
}

// Tries to cast `RTCStats` into wrapped `RTCRemoteOutboundRtpStreamStats`.
RTCRemoteOutboundRtpStreamStatsWrap
cast_to_rtc_remote_outbound_rtp_stream_stats(std::unique_ptr<RTCStats> stats) {
  auto type = std::string(stats->type());
  if (type == "remote-outbound-rtp") {
    auto cast = std::unique_ptr<RTCRemoteOutboundRtpStreamStats>(
        static_cast<RTCRemoteOutboundRtpStreamStats*>(stats.release()));

    auto local_id = init_option_string();
    if (cast->local_id.has_value()) {
      local_id->set_value(rust::String(*cast->local_id));
    }
    auto remote_timestamp = init_option_f64();
    if (cast->remote_timestamp.has_value()) {
      remote_timestamp->set_value(*cast->remote_timestamp);
    }
    auto reports_sent = init_option_u64();
    if (cast->reports_sent.has_value()) {
      reports_sent->set_value(*cast->reports_sent);
    }

    return RTCRemoteOutboundRtpStreamStatsWrap{
        std::move(local_id),
        std::move(remote_timestamp),
        std::move(reports_sent),
    };
  }
  throw std::invalid_argument(
      "Invalid type. Expected `remote-outbound-rtp` but found: " + type);
}

// Tries to cast `RTCMediaSourceStats` into wrapped `RTCVideoSourceStats`.
RTCVideoSourceStatsWrap cast_to_rtc_video_source_stats(
    std::unique_ptr<RTCMediaSourceStats> stats) {
  auto kind = *stats->kind;
  if (kind == "video") {
    auto cast = std::unique_ptr<RTCVideoSourceStats>(
        static_cast<RTCVideoSourceStats*>(stats.release()));

    auto width = init_option_u32();
    if (cast->width.has_value()) {
      width->set_value(*cast->width);
    }
    auto height = init_option_u32();
    if (cast->height.has_value()) {
      height->set_value(*cast->height);
    }
    auto frames = init_option_u32();
    if (cast->frames.has_value()) {
      frames->set_value(*cast->frames);
    }
    auto frames_per_second = init_option_f64();
    if (cast->frames_per_second.has_value()) {
      frames_per_second->set_value(*cast->frames_per_second);
    }

    return RTCVideoSourceStatsWrap{
        std::move(width),
        std::move(height),
        std::move(frames),
        std::move(frames_per_second),

    };
  }
  throw std::invalid_argument("Invalid kind. Expected `video` but found: " +
                              kind);
}

// Tries to cast `RTCMediaSourceStats` into wrapped `RTCAudioSourceStats`.
RTCAudioSourceStatsWrap cast_to_rtc_audio_source_stats(
    std::unique_ptr<RTCMediaSourceStats> stats) {
  auto kind = *stats->kind;
  if (kind == "audio") {
    auto cast = std::unique_ptr<RTCAudioSourceStats>(
        static_cast<RTCAudioSourceStats*>(stats.release()));

    auto audio_level = init_option_f64();
    if (cast->audio_level.has_value()) {
      audio_level->set_value(*cast->audio_level);
    }

    auto total_audio_energy = init_option_f64();
    if (cast->total_audio_energy.has_value()) {
      total_audio_energy->set_value(*cast->total_audio_energy);
    }

    auto total_samples_duration = init_option_f64();
    if (cast->total_samples_duration.has_value()) {
      total_samples_duration->set_value(*cast->total_samples_duration);
    }

    auto echo_return_loss = init_option_f64();
    if (cast->echo_return_loss.has_value()) {
      echo_return_loss->set_value(*cast->echo_return_loss);
    }

    auto echo_return_loss_enhancement = init_option_f64();
    if (cast->echo_return_loss_enhancement.has_value()) {
      echo_return_loss_enhancement->set_value(
          *cast->echo_return_loss_enhancement);
    }

    return RTCAudioSourceStatsWrap{
        std::move(audio_level),
        std::move(total_audio_energy),
        std::move(total_samples_duration),
        std::move(echo_return_loss),
        std::move(echo_return_loss_enhancement),

    };
  }
  throw std::invalid_argument("Invalid kind. Expected `audio` but found: " +
                              kind);
}

// Returns collection of wrapped `RTCStats` of the provided `RTCStatsReport`.
rust::Vec<RTCStatsWrap> rtc_stats_report_get_stats(
    const RTCStatsReport& report) {
  rust::Vec<RTCStatsWrap> stats_result;

  for (const RTCStats& stats : *report) {
    auto type_str = stats.type();
    RTCStatsType type;

    if (strcmp(type_str, "media-source") == 0) {
      type = RTCStatsType::RTCMediaSourceStats;
    } else if (strcmp(type_str, "local-candidate") == 0 ||
               strcmp(type_str, "remote-candidate") == 0) {
      type = RTCStatsType::RTCIceCandidateStats;
    } else if (strcmp(type_str, "outbound-rtp") == 0) {
      type = RTCStatsType::RTCOutboundRTPStreamStats;
    } else if (strcmp(type_str, "inbound-rtp") == 0) {
      type = RTCStatsType::RTCInboundRTPStreamStats;
    } else if (strcmp(type_str, "candidate-pair") == 0) {
      type = RTCStatsType::RTCIceCandidatePairStats;
    } else if (strcmp(type_str, "transport") == 0) {
      type = RTCStatsType::RTCTransportStats;
    } else if (strcmp(type_str, "remote-inbound-rtp") == 0) {
      type = RTCStatsType::RTCRemoteInboundRtpStreamStats;
    } else if (strcmp(type_str, "remote-outbound-rtp") == 0) {
      type = RTCStatsType::RTCRemoteOutboundRtpStreamStats;
    } else {
      type = RTCStatsType::Unimplemented;
    }

    RTCStatsWrap wrap_stat = {rust::String(stats.id()), stats.timestamp().us(),
                              type, stats.copy()};
    stats_result.push_back(std::move(wrap_stat));
  }
  return stats_result;
}

}  // namespace bridge
