import 'package:collection/collection.dart';

import '/src/api/bridge/api.dart' as ffi;

/// Tries to parse the provided [value] as [int].
///
/// If the provided [value] is a [String] then parses it as hexadecimal.
int? tryParse(dynamic value) {
  switch (value.runtimeType) {
    case const (int):
      {
        return value;
      }
    case const (String):
      {
        return int.tryParse(value, radix: 16);
      }
    default:
      {
        return null;
      }
  }
}

/// Represents the [stats object] constructed by inspecting a specific
/// [monitored object].
///
/// [Full doc on W3C][1].
///
/// [stats object]: https://w3.org/TR/webrtc-stats#dfn-stats-object
/// [monitored object]: https://w3.org/TR/webrtc-stats#dfn-monitored-object
/// [1]: https://w3.org/TR/webrtc#rtcstats-dictionary
class RtcStats {
  RtcStats(
    this.id,
    this.timestampUs,
    this.type,
  );

  /// Creates [RTCStats] basing on the [ffi.RtcStats] received from the native
  /// side.
  static RtcStats? fromFFI(ffi.RtcStats stats) {
    var kind = RtcStatsType.fromFFI(stats.kind);
    if (kind == null) {
      return null;
    } else {
      return RtcStats(
        stats.id,
        stats.timestampUs,
        kind,
      );
    }
  }

  /// Creates [RTCStats] basing on the [Map] received from the native side.
  static RtcStats? fromMap(dynamic stats) {
    var kind = RtcStatsType.fromMap(stats);
    if (kind == null) {
      return null;
    } else {
      return RtcStats(
        stats['id'],
        stats['timestampUs'],
        kind,
      );
    }
  }

  /// Unique ID that is associated with the object that was inspected to produce
  /// these [RTCStats].
  ///
  /// [RTCStats]: https://w3.org/TR/webrtc#dom-rtcstats
  String id;

  /// Timestamp associated with this object.
  ///
  /// The time is relative to the UNIX epoch (Jan 1, 1970, UTC).
  ///
  /// For statistics that came from a remote source (e.g., from received RTCP
  /// packets), timestamp represents the time at which the information arrived
  /// at the local endpoint. The remote timestamp can be found in an additional
  /// field in an [RTCStats]-derived dictionary, if applicable.
  ///
  /// [RTCStats]: https://w3.org/TR/webrtc#dom-rtcstats
  int timestampUs;

  /// Actual stats of these [RtcStats].
  ///
  /// All possible stats are described in the [RtcStatsType] abstract class.
  RtcStatsType type;
}

/// Each candidate pair in the check list has a foundation and a state.
/// The foundation is the combination of the foundations of the local and remote
/// candidates in the pair. The state is assigned once the check list for each
/// media stream has been computed. There are five potential values that the
/// state can have.
enum RtcStatsIceCandidatePairState {
  /// Check for this pair hasn't been performed, and it can't yet be performed
  /// until some other check succeeds, allowing this pair to unfreeze and move
  /// into the [waiting] state.
  frozen,

  /// Check has not been performed for this pair, and can be performed as soon
  /// as it is the highest-priority Waiting pair on the check list.
  waiting,

  /// Check has been sent for this pair, but the transaction is in progress.
  inProgress,

  /// Check for this pair was already done and failed, either never producing
  /// any response or producing an unrecoverable failure response.
  failed,

  /// Check for this pair was already done and produced a successful result.
  succeeded,
}

/// Tries to parse a [String] as an [RtcStatsIceCandidatePairState].
RtcStatsIceCandidatePairState? iceCandidatePairStateTryFromString(
    String state) {
  switch (state) {
    case ('frozen'):
      {
        return RtcStatsIceCandidatePairState.frozen;
      }
    case ('waiting'):
      {
        return RtcStatsIceCandidatePairState.waiting;
      }
    case ('in-progress'):
      {
        return RtcStatsIceCandidatePairState.inProgress;
      }
    case ('failed'):
      {
        return RtcStatsIceCandidatePairState.failed;
      }
    case ('succeeded'):
      {
        return RtcStatsIceCandidatePairState.succeeded;
      }
    default:
      {
        return null;
      }
  }
}

/// Variants of [ICE roles][1].
///
/// More info in the [RFC 5245].
///
/// [RFC 5245]: https://tools.ietf.org/html/rfc5245
/// [1]: https://w3.org/TR/webrtc#dom-icetransport-role
enum IceRole {
  /// Agent whose role as defined by [Section 3 in RFC 5245][1], has not yet
  /// been determined.
  ///
  /// [1]: https://tools.ietf.org/html/rfc5245#section-3
  unknown,

  /// Controlling agent as defined by [Section 3 in RFC 5245][1].
  ///
  /// [1]: https://tools.ietf.org/html/rfc5245#section-3
  controlling,

  /// Controlled agent as defined by [Section 3 in RFC 5245][1].
  ///
  /// [1]: https://tools.ietf.org/html/rfc5245#section-3
  controlled,
}

/// [RTCIceCandidateType] represents the type of the ICE candidate, as defined
/// in [Section 15.1 of RFC 5245][1].
///
/// [RTCIceCandidateType]: https://w3.org/TR/webrtc#rtcicecandidatetype-enum
/// [1]: https://tools.ietf.org/html/rfc5245#section-15.1
enum CandidateType {
  /// Host candidate, as defined in [Section 4.1.1.1 of RFC 5245][1].
  ///
  /// [1]: https://tools.ietf.org/html/rfc5245#section-4.1.1.1
  host,

  /// Server reflexive candidate, as defined in
  /// [Section 4.1.1.2 of RFC 5245][1].
  ///
  /// [1]: https://tools.ietf.org/html/rfc5245#section-4.1.1.2
  srflx,

  /// Peer reflexive candidate, as defined in [Section 4.1.1.2 of RFC 5245][1].
  ///
  /// [1]: https://tools.ietf.org/html/rfc5245#section-4.1.1.2
  prflx,

  /// Relay candidate, as defined in [Section 7.1.3.2.1 of RFC 5245][1].
  ///
  /// [1]: https://tools.ietf.org/html/rfc5245#section-7.1.3.2.1
  relay,
}

/// Transport protocols used in [WebRTC].
///
/// [WebRTC]: https://w3.org/TR/webrtc
enum Protocol {
  /// [Transmission Control Protocol][1].
  ///
  /// [1]: https://en.wikipedia.org/wiki/Transmission_Control_Protocol
  tcp,

  /// [User Datagram Protocol][1].
  ///
  /// [1]: https://en.wikipedia.org/wiki/User_Datagram_Protocol
  udp,
}

/// All known types of [RtcStats].
///
/// [List of all RTCStats types on W3C][1].
///
/// [1]: https://w3.org/TR/webrtc-stats#rtctatstype-%2A
abstract class RtcStatsType {
  RtcStatsType();

  /// Creates an [RtcStatsType] basing on the [ffi.RtcStatsType] received from
  /// the native side.
  static RtcStatsType? fromFFI(ffi.RtcStatsType stats) {
    switch (stats.runtimeType.toString().substring(2)) // Skip '_$' prefix.
    {
      case 'RtcStatsType_RtcMediaSourceStatsImpl':
        {
          var source = (stats as ffi.RtcStatsType_RtcMediaSourceStats);
          if (source.kind
              is ffi.RtcMediaSourceStatsMediaType_RtcAudioSourceStats) {
            return RtcAudioSourceStats.fromFFI(
                stats.kind
                    as ffi.RtcMediaSourceStatsMediaType_RtcAudioSourceStats,
                stats.trackIdentifier);
          } else {
            return RtcVideoSourceStats.fromFFI(
                stats.kind
                    as ffi.RtcMediaSourceStatsMediaType_RtcVideoSourceStats,
                stats.trackIdentifier);
          }
        }

      case 'RtcStatsType_RtcIceCandidateStatsImpl':
        {
          return RtcIceCandidateStats.fromFFI(
              stats as ffi.RtcStatsType_RtcIceCandidateStats);
        }

      case 'RtcStatsType_RtcOutboundRtpStreamStatsImpl':
        {
          return RtcOutboundRtpStreamStats.fromFFI(
              stats as ffi.RtcStatsType_RtcOutboundRtpStreamStats);
        }

      case 'RtcStatsType_RtcInboundRtpStreamStatsImpl':
        {
          return RtcInboundRtpStreamStats.fromFFI(
              stats as ffi.RtcStatsType_RtcInboundRtpStreamStats);
        }
      case 'RtcStatsType_RtcTransportStatsImpl':
        {
          return RtcTransportStats.fromFFI(
              stats as ffi.RtcStatsType_RtcTransportStats);
        }
      case 'RtcStatsType_RtcRemoteInboundRtpStreamStatsImpl':
        {
          return RtcRemoteInboundRtpStreamStats.fromFFI(
              stats as ffi.RtcStatsType_RtcRemoteInboundRtpStreamStats);
        }
      case 'RtcStatsType_RtcRemoteOutboundRtpStreamStatsImpl':
        {
          return RtcRemoteOutboundRtpStreamStats.fromFFI(
              stats as ffi.RtcStatsType_RtcRemoteOutboundRtpStreamStats);
        }
      case 'RtcStatsType_RtcIceCandidatePairStatsImpl':
        {
          return RtcIceCandidatePairStats.fromFFI(
              stats as ffi.RtcStatsType_RtcIceCandidatePairStats);
        }
      default:
        {
          return null;
        }
    }
  }

  /// Creates an [RtcStatsType] basing on the [Map] received from the native
  /// side.
  static RtcStatsType? fromMap(dynamic stats) {
    switch (stats['type']) {
      case 'media-source':
        {
          if (stats['kind'] == 'audio') {
            return RtcAudioSourceStats.fromMap(stats);
          } else {
            return RtcVideoSourceStats.fromMap(stats);
          }
        }

      case 'remote-candidate':
        {
          return RtcIceCandidateStats.fromMap(stats);
        }
      case 'local-candidate':
        {
          return RtcIceCandidateStats.fromMap(stats);
        }

      case 'outbound-rtp':
        {
          return RtcOutboundRtpStreamStats.fromMap(stats);
        }
      case 'inbound-rtp':
        {
          return RtcInboundRtpStreamStats.fromMap(stats);
        }
      case 'transport':
        {
          return RtcTransportStats.fromMap(stats);
        }
      case 'remote-inbound-rtp':
        {
          return RtcRemoteInboundRtpStreamStats.fromMap(stats);
        }
      case 'remote-outbound-rtp':
        {
          return RtcRemoteOutboundRtpStreamStats.fromMap(stats);
        }
      case 'candidate-pair':
        {
          return RtcIceCandidatePairStats.fromMap(stats);
        }
      default:
        {
          return null;
        }
    }
  }
}

/// Statistics for the media produced by a [MediaStreamTrack][1] that is
/// currently attached to an [RTCRtpSender]. This reflects the media that is fed
/// to the encoder after [getUserMedia()] constraints have been applied (i.e.
/// not the raw media produced by the camera).
///
/// [RTCRtpSender]: https://w3.org/TR/webrtc#rtcrtpsender-interface
/// [getUserMedia()]: https://tinyurl.com/sngpyr6
/// [1]: https://w3.org/TR/mediacapture-streams#mediastreamtrack
abstract class RtcMediaSourceStats extends RtcStatsType {
  RtcMediaSourceStats(this.trackIdentifier);

  /// Value of the [MediaStreamTrack][1]'s ID attribute.
  ///
  /// [1]: https://w3.org/TR/mediacapture-streams#mediastreamtrack
  String? trackIdentifier;
}

/// [RtcStats] fields of audio [RtcMediaSourceStats].
class RtcAudioSourceStats extends RtcMediaSourceStats {
  RtcAudioSourceStats(
      this.audioLevel,
      this.totalAudioEnergy,
      this.totalSamplesDuration,
      this.echoReturnLoss,
      this.echoReturnLossEnhancement,
      String? trackIdentifier)
      : super(trackIdentifier);

  /// Creates [RtcAudioSourceStats] basing on the
  /// [ffi.RtcMediaSourceStatsMediaType_RtcAudioSourceStats] received from the
  /// native side.
  static RtcAudioSourceStats fromFFI(
      ffi.RtcMediaSourceStatsMediaType_RtcAudioSourceStats stats,
      String? trackIdentifier) {
    return RtcAudioSourceStats(
      stats.audioLevel,
      stats.totalAudioEnergy,
      stats.totalSamplesDuration,
      stats.echoReturnLoss,
      stats.echoReturnLossEnhancement,
      trackIdentifier,
    );
  }

  /// Creates [RtcAudioSourceStats] basing on the [Map] received from the native
  /// side.
  static RtcAudioSourceStats fromMap(dynamic stats) {
    return RtcAudioSourceStats(
      stats['audioLevel'],
      stats['totalAudioEnergy'],
      stats['totalSamplesDuration'],
      stats['echoReturnLoss'],
      stats['echoReturnLossEnhancement'],
      stats['trackIdentifier'],
    );
  }

  /// Audio level of the media source.
  double? audioLevel;

  /// Audio energy of the media source.
  double? totalAudioEnergy;

  /// Audio duration of the media source.
  double? totalSamplesDuration;

  /// Only exists when the [MediaStreamTrack][1] is sourced from a microphone
  /// where echo cancellation is applied.
  ///
  /// [1]: https://w3.org/TR/mediacapture-streams#mediastreamtrack
  double? echoReturnLoss;

  /// Only exists when the [MediaStreamTrack][1] is sourced from a microphone
  /// where echo cancellation is applied.
  ///
  /// [1]: https://w3.org/TR/mediacapture-streams#mediastreamtrack
  double? echoReturnLossEnhancement;
}

/// [RtcStats] fields of video [RtcMediaSourceStats].
class RtcVideoSourceStats extends RtcMediaSourceStats {
  RtcVideoSourceStats(this.width, this.height, this.frames,
      this.framesPerSecond, String? trackIdentifier)
      : super(trackIdentifier);

  /// Creates [RtcVideoSourceStats] basing on the
  /// [ffi.RtcMediaSourceStatsMediaType_RtcVideoSourceStats] received from the
  /// native side.
  static RtcVideoSourceStats fromFFI(
      ffi.RtcMediaSourceStatsMediaType_RtcVideoSourceStats stats,
      String? trackIdentifier) {
    return RtcVideoSourceStats(stats.width, stats.height, stats.frames,
        stats.framesPerSecond, trackIdentifier);
  }

  /// Creates [RtcVideoSourceStats] basing on the [Map] received from the native
  /// side.
  static RtcVideoSourceStats fromMap(dynamic stats) {
    return RtcVideoSourceStats(stats['width'], stats['height'], stats['frames'],
        stats['framesPerSecond'], stats['trackIdentifier']);
  }

  /// Width (in pixels) of the last frame originating from the source.
  /// Before a frame has been produced this attribute is missing.
  int? width;

  /// Height (in pixels) of the last frame originating from the source.
  /// Before a frame has been produced this attribute is missing.
  int? height;

  /// Total number of frames originating from this source.
  int? frames;

  /// Number of frames originating from the source, measured during the last
  /// second. For the first second of this object's lifetime this attribute is
  /// missing.
  double? framesPerSecond;
}

/// Properties of a `candidate` in [Section 15.1 of RFC 5245][1].
/// It corresponds to a [RTCIceTransport] object.
///
/// [Full doc on W3C][2].
///
/// [RTCIceTransport]: https://w3.org/TR/webrtc#dom-rtcicetransport
/// [1]: https://tools.ietf.org/html/rfc5245#section-15.1
/// [2]: https://w3.org/TR/webrtc-stats#icecandidate-dict%2A
abstract class RtcIceCandidateStats extends RtcStatsType {
  RtcIceCandidateStats(this.transportId, this.address, this.port, this.protocol,
      this.candidateType, this.priority, this.url, this.relayProtocol);

  /// Creates [RtcIceCandidateStats] basing on the
  /// [ffi.RtcStatsType_RtcIceCandidateStats] received from the native side.
  static RtcIceCandidateStats fromFFI(
      ffi.RtcStatsType_RtcIceCandidateStats stats) {
    Protocol? relayProtocol;
    if (stats.field0.field0.relayProtocol != null) {
      relayProtocol = Protocol.values[stats.field0.field0.relayProtocol!.index];
    }
    if (stats.field0 is ffi.RtcIceCandidateStats_Local) {
      var local = stats.field0 as ffi.RtcIceCandidateStats_Local;
      return RtcLocalIceCandidateStats(
          local.field0.transportId,
          local.field0.address,
          local.field0.port,
          Protocol.values[local.field0.protocol.index],
          CandidateType.values[local.field0.candidateType.index],
          local.field0.priority,
          local.field0.url,
          relayProtocol);
    } else {
      var remote = stats.field0 as ffi.RtcIceCandidateStats_Remote;
      return RtcRemoteIceCandidateStats(
          remote.field0.transportId,
          remote.field0.address,
          remote.field0.port,
          Protocol.values[remote.field0.protocol.index],
          CandidateType.values[remote.field0.candidateType.index],
          remote.field0.priority,
          remote.field0.url,
          relayProtocol);
    }
  }

  /// Creates [RtcIceCandidateStats] basing on the [Map] received from the
  /// native side.
  static RtcIceCandidateStats fromMap(dynamic stats) {
    if (stats['isRemote']) {
      return RtcRemoteIceCandidateStats(
          stats['transportId'],
          stats['address'],
          stats['port'],
          Protocol.values
              .firstWhere((element) => element.name == stats['protocol']),
          CandidateType.values
              .firstWhere((element) => element.name == stats['candidateType']),
          stats['priority'],
          stats['url'],
          Protocol.values.firstWhereOrNull(
              (element) => element.name == stats['relayProtocol']));
    } else {
      return RtcLocalIceCandidateStats(
          stats['transportId'],
          stats['address'],
          stats['port'],
          Protocol.values
              .firstWhere((element) => element.name == stats['protocol']),
          CandidateType.values
              .firstWhere((element) => element.name == stats['candidateType']),
          stats['priority'],
          stats['url'],
          Protocol.values.firstWhereOrNull(
              (element) => element.name == stats['relayProtocol']));
    }
  }

  /// Unique ID that is associated to the object that was inspected to produce
  /// the [RTCTransportStats][1] associated with this candidate.
  ///
  /// [1]: https://w3.org/TR/webrtc-stats#transportstats-dict%2A
  String? transportId;

  /// Address of the candidate, allowing for IPv4 addresses, IPv6 addresses, and
  /// fully qualified domain names (FQDNs).
  String? address;

  /// Port number of the candidate.
  int? port;

  /// Valid values for transport is one of [udp] and [tcp].
  Protocol protocol;

  /// Type of the ICE candidate.
  CandidateType candidateType;

  /// Calculated as defined in [Section 15.1 of RFC 5245][1].
  ///
  /// [1]: https://tools.ietf.org/html/rfc5245#section-15.1
  int? priority;

  /// For local candidates this is the URL of the ICE server from which the
  /// candidate was obtained. It is the same as the [url][2] surfaced in the
  /// [RTCPeerConnectionIceEvent][1].
  ///
  /// `null` for remote candidates.
  ///
  /// [1]: https://w3.org/TR/webrtc#rtcpeerconnectioniceevent
  /// [2]: https://w3.org/TR/webrtc#dom-rtcpeerconnectioniceevent-url
  String? url;

  /// Protocol used by the endpoint to communicate with the TURN server.
  ///
  /// Only present for local candidates.
  Protocol? relayProtocol;
}

/// Local [RtcIceCandidateStats].
class RtcLocalIceCandidateStats extends RtcIceCandidateStats {
  RtcLocalIceCandidateStats(
    super.transportId,
    super.address,
    super.port,
    super.protocol,
    super.candidateType,
    super.priority,
    super.url,
    super.relayProtocol,
  );
}

/// Remote [RtcIceCandidateStats].
class RtcRemoteIceCandidateStats extends RtcIceCandidateStats {
  RtcRemoteIceCandidateStats(
    super.transportId,
    super.address,
    super.port,
    super.protocol,
    super.candidateType,
    super.priority,
    super.url,
    super.relayProtocol,
  );
}

abstract class RtcOutboundRtpStreamStatsMediaType {}

/// Audio [RtcOutboundRtpStreamStatsMediaType].
class RtcOutboundRtpStreamStatsAudio
    extends RtcOutboundRtpStreamStatsMediaType {
  RtcOutboundRtpStreamStatsAudio(this.totalSamplesSent, this.voiceActivityFlag);

  /// Total number of samples that have been sent over this RTP stream.
  int? totalSamplesSent;

  /// Whether the last RTP packet sent contained voice activity or not
  /// based on the presence of the V bit in the extension header.
  bool? voiceActivityFlag;
}

/// Video [RtcOutboundRtpStreamStatsMediaType].
class RtcOutboundRtpStreamStatsVideo
    extends RtcOutboundRtpStreamStatsMediaType {
  RtcOutboundRtpStreamStatsVideo(
      this.frameWidth, this.frameHeight, this.framesPerSecond);

  /// Width of the last encoded frame.
  ///
  /// The resolution of the encoded frame may be lower than the media source
  /// (see [RTCVideoSourceStats.width][1]).
  ///
  /// Before the first frame is encoded this attribute is missing.
  ///
  /// [1]: https://w3.org/TR/webrtc-stats#dom-rtcvideosourcestats-width
  int? frameWidth;

  /// Height of the last encoded frame.
  ///
  /// The resolution of the encoded frame may be lower than the media source
  /// (see [RTCVideoSourceStats.height][1]).
  ///
  /// Before the first frame is encoded this attribute is missing.
  ///
  /// [1]: https://w3.org/TR/webrtc-stats#dom-rtcvideosourcestats-height
  int? frameHeight;

  /// Number of encoded frames during the last second.
  ///
  /// This may be lower than the media source frame rate (see
  /// [RTCVideoSourceStats.framesPerSecond][1]).
  ///
  /// [1]: https://tinyurl.com/rrmkrfk
  double? framesPerSecond;
}

/// Statistics for an outbound [RTP] stream that is currently sent with
/// [RTCPeerConnection] object.
///
/// When there are multiple [RTP] streams connected to the same sender, such as
/// when using simulcast or RTX, there will be one
/// [RTCOutboundRtpStreamStats][5] per RTP stream, with distinct values of the
/// [SSRC] attribute, and all these senders will have a reference to the same
/// "sender" object (of type [RTCAudioSenderStats][1] or
/// [RTCVideoSenderStats][2]) and "track" object (of type
/// [RTCSenderAudioTrackAttachmentStats][3] or
/// [RTCSenderVideoTrackAttachmentStats][4]).
///
/// [RTP]: https://en.wikipedia.org/wiki/Real-time_Transport_Protocol
/// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
/// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
/// [1]: https://w3.org/TR/webrtc-stats#dom-rtcaudiosenderstats
/// [2]: https://w3.org/TR/webrtc-stats#dom-rtcvideosenderstats
/// [3]: https://tinyurl.com/sefa5z4
/// [4]: https://tinyurl.com/rkuvpl4
/// [5]: https://w3.org/TR/webrtc-stats#dom-rtcoutboundrtpstreamstats
class RtcOutboundRtpStreamStats extends RtcStatsType {
  RtcOutboundRtpStreamStats(
    this.trackId,
    this.mediaType,
    this.bytesSent,
    this.packetsSent,
    this.mediaSourceId,
  );

  /// Creates [RtcOutboundRtpStreamStats] basing on the
  /// [ffi.RtcStatsType_RtcOutboundRtpStreamStats] received from the native
  /// side.
  static RtcOutboundRtpStreamStats fromFFI(
      ffi.RtcStatsType_RtcOutboundRtpStreamStats stats) {
    RtcOutboundRtpStreamStatsMediaType? mediaType;
    var kind = stats.mediaType.runtimeType.toString().substring(2);
    if (kind == 'RtcOutboundRtpStreamStatsMediaType_AudioImpl') {
      var cast =
          stats.mediaType as ffi.RtcOutboundRtpStreamStatsMediaType_Audio;
      mediaType = RtcOutboundRtpStreamStatsAudio(
          cast.totalSamplesSent?.toInt(), cast.voiceActivityFlag);
    } else if (kind == 'RtcOutboundRtpStreamStatsMediaType_VideoImpl') {
      var cast =
          stats.mediaType as ffi.RtcOutboundRtpStreamStatsMediaType_Video;
      mediaType = RtcOutboundRtpStreamStatsVideo(
          cast.frameWidth, cast.frameHeight, cast.framesPerSecond);
    }
    return RtcOutboundRtpStreamStats(
      stats.trackId,
      mediaType,
      stats.bytesSent?.toInt(),
      stats.packetsSent,
      stats.mediaSourceId,
    );
  }

  /// Creates [RtcOutboundRtpStreamStats] basing on the [Map] received from the
  /// native side.
  static RtcOutboundRtpStreamStats fromMap(dynamic stats) {
    RtcOutboundRtpStreamStatsMediaType? mediaType;
    if (stats['kind'] == 'audio') {
      mediaType = RtcOutboundRtpStreamStatsAudio(
          tryParse(stats['totalSamplesSent']), stats['voiceActivityFlag']);
    } else if (stats['kind'] == 'video') {
      mediaType = RtcOutboundRtpStreamStatsVideo(
          stats['frameWidth'], stats['frameHeight'], stats['framesPerSecond']);
    }

    return RtcOutboundRtpStreamStats(
      stats['trackId'],
      mediaType,
      tryParse(stats['bytesSent']),
      tryParse(stats['packetsSent']),
      stats['mediaSourceId'],
    );
  }

  /// ID of the stats object representing the current track attachment to the
  /// sender of the stream.
  String? trackId;

  RtcOutboundRtpStreamStatsMediaType? mediaType;

  /// Total number of bytes sent for this [SSRC].
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  int? bytesSent;

  /// Total number of RTP packets sent for this [SSRC].
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  int? packetsSent;

  /// ID of the stats object representing the track currently attached to the
  /// sender of the stream.
  String? mediaSourceId;
}

/// Media type pf [RtcInboundRtpStreamStats].
abstract class RtcInboundRtpStreamMediaType {}

/// Audio [RtcInboundRtpStreamMediaType].
class RtcInboundRtpStreamAudio extends RtcInboundRtpStreamMediaType {
  RtcInboundRtpStreamAudio(
    this.totalSamplesReceived,
    this.concealedSamples,
    this.silentConcealedSamples,
    this.audioLevel,
    this.totalAudioEnergy,
    this.totalSamplesDuration,
    this.voiceActivityFlag,
  );

  /// Total number of samples that have been received on this RTP stream.
  /// This includes [concealedSamples].
  ///
  /// [concealedSamples]: https://tinyurl.com/s6c4qe4
  int? totalSamplesReceived;

  /// Total number of samples that are concealed samples.
  ///
  /// A concealed sample is a sample that was replaced with synthesized samples
  /// generated locally before being played out.
  /// Examples of samples that have to be concealed are samples from lost
  /// packets (reported in [packetsLost]) or samples from packets that arrive
  /// too late to be played out (reported in [packetsDiscarded]).
  ///
  /// [packetsLost]: https://tinyurl.com/u2gq965
  /// [packetsDiscarded]: https://tinyurl.com/yx7qyox3
  int? concealedSamples;

  /// Total number of concealed samples inserted that are "silent".
  ///
  /// Playing out silent samples results in silence or comfort noise.
  /// This is a subset of [concealedSamples].
  ///
  /// [concealedSamples]: https://tinyurl.com/s6c4qe4
  int? silentConcealedSamples;

  /// Audio level of the receiving track.
  double? audioLevel;

  /// Audio energy of the receiving track.
  double? totalAudioEnergy;

  /// Audio duration of the receiving track.
  ///
  /// For audio durations of tracks attached locally, see
  /// [RTCAudioSourceStats][1] instead.
  ///
  /// [1]: https://w3.org/TR/webrtc-stats#dom-rtcaudiosourcestats
  double? totalSamplesDuration;

  /// Indicator whether the last RTP packet whose frame was delivered to the
  /// [RTCRtpReceiver]'s [MediaStreamTrack][1] for playout contained voice
  /// activity or not based on the presence of the V bit in the extension
  /// header, as defined in [RFC 6464].
  ///
  /// [RTCRtpReceiver]: https://w3.org/TR/webrtc#rtcrtpreceiver-interface
  /// [RFC 6464]: https://tools.ietf.org/html/rfc6464#page-3
  /// [1]: https://w3.org/TR/mediacapture-streams#mediastreamtrack
  bool? voiceActivityFlag;
}

/// Video [RtcInboundRtpStreamMediaType].
class RtcInboundRtpStreamVideo extends RtcInboundRtpStreamMediaType {
  RtcInboundRtpStreamVideo(
    this.framesDecoded,
    this.keyFramesDecoded,
    this.frameWidth,
    this.frameHeight,
    this.totalInterFrameDelay,
    this.framesPerSecond,
    this.firCount,
    this.pliCount,
    this.concealmentEvents,
    this.framesReceived,
    this.sliCount,
  );

  /// Total number of frames correctly decoded for this RTP stream, i.e. frames
  /// that would be displayed if no frames are dropped.
  int? framesDecoded;

  /// Total number of key frames, such as key frames in VP8 [RFC 6386] or
  /// IDR-frames in H.264 [RFC 6184], successfully decoded for this RTP media
  /// stream.
  ///
  /// This is a subset of [framesDecoded].
  /// [framesDecoded] - [keyFramesDecoded] gives you the number of delta frames
  /// decoded.
  ///
  /// [RFC 6386]: https://w3.org/TR/webrtc-stats#bib-rfc6386
  /// [RFC 6184]: https://w3.org/TR/webrtc-stats#bib-rfc6184
  /// [framesDecoded]: https://tinyurl.com/srfwrwt
  /// [keyFramesDecoded]: https://tinyurl.com/qtdmhtm
  int? keyFramesDecoded;

  /// Width of the last decoded frame.
  ///
  /// Before the first frame is decoded this attribute is missing.
  int? frameWidth;

  /// Height of the last decoded frame.
  ///
  /// Before the first frame is decoded this attribute is missing.
  int? frameHeight;

  /// Sum of the interframe delays in seconds between consecutively
  /// decoded frames, recorded just after a frame has been decoded.
  double? totalInterFrameDelay;

  /// Number of decoded frames in the last second.
  double? framesPerSecond;

  /// Total number of Full Intra Request (FIR) packets sent by this receiver.
  int? firCount;

  /// Total number of Picture Loss Indication (PLI) packets sent by this
  /// receiver.
  int? pliCount;

  /// Number of concealment events.
  ///
  /// This counter increases every time a concealed sample is synthesized after
  /// a non-concealed sample. That is, multiple consecutive concealed samples
  /// will increase the [concealedSamples] count multiple times but is a single
  /// concealment event.
  ///
  /// [concealedSamples]: https://tinyurl.com/s6c4qe4
  int? concealmentEvents;

  /// Total number of complete frames received on this RTP stream.
  ///
  /// This metric is incremented when the complete frame is received.
  int? framesReceived;

  /// Total number of Slice Loss Indication (SLI) packets sent by this receiver.
  int? sliCount;
}

/// Statistics for an inbound [RTP] stream that is currently received with
/// [RTCPeerConnection] object.
///
/// [RTP]: https://en.wikipedia.org/wiki/Real-time_Transport_Protocol
/// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
class RtcInboundRtpStreamStats extends RtcStatsType {
  RtcInboundRtpStreamStats(
    this.remoteId,
    this.bytesReceived,
    this.packetsReceived,
    this.totalDecodeTime,
    this.jitterBufferEmittedCount,
    this.mediaType,
  );

  /// Creates [RtcInboundRtpStreamStats] basing on the
  /// [ffi.RtcStatsType_RtcInboundRtpStreamStats] received from the native side.
  static RtcInboundRtpStreamStats fromFFI(
      ffi.RtcStatsType_RtcInboundRtpStreamStats stats) {
    RtcInboundRtpStreamMediaType? mediaType;
    var type = stats.mediaType.runtimeType.toString().substring(2);
    if (type == 'RtcInboundRtpStreamMediaType_AudioImpl') {
      var cast = stats.mediaType as ffi.RtcInboundRtpStreamMediaType_Audio;
      mediaType = RtcInboundRtpStreamAudio(
          cast.totalSamplesReceived?.toInt(),
          cast.concealedSamples?.toInt(),
          cast.silentConcealedSamples?.toInt(),
          cast.audioLevel,
          cast.totalAudioEnergy,
          cast.totalSamplesDuration,
          cast.voiceActivityFlag);
    } else if (type == 'RtcInboundRtpStreamMediaType_VideoImpl') {
      var cast = stats.mediaType as ffi.RtcInboundRtpStreamMediaType_Video;
      mediaType = RtcInboundRtpStreamVideo(
        cast.framesDecoded,
        cast.keyFramesDecoded,
        cast.frameWidth,
        cast.frameHeight,
        cast.totalInterFrameDelay,
        cast.framesPerSecond,
        cast.firCount,
        cast.pliCount,
        cast.concealmentEvents?.toInt(),
        cast.framesReceived,
        cast.sliCount,
      );
    }

    return RtcInboundRtpStreamStats(
        stats.remoteId,
        stats.bytesReceived?.toInt(),
        stats.packetsReceived,
        stats.totalDecodeTime,
        stats.jitterBufferEmittedCount?.toInt(),
        mediaType);
  }

  /// Creates [RtcInboundRtpStreamStats] basing on the [Map] received from the
  /// native side.
  static RtcInboundRtpStreamStats fromMap(dynamic stats) {
    RtcInboundRtpStreamMediaType? mediaType;
    if (stats['kind'] == 'audio') {
      mediaType = RtcInboundRtpStreamAudio(
          tryParse(stats['totalSamplesReceived']),
          tryParse(stats['concealedSamples']),
          tryParse(stats['silentConcealedSamples']),
          stats['audioLevel'],
          stats['totalAudioEnergy'],
          stats['totalSamplesDuration'],
          stats['voiceActivityFlag']);
    } else if (stats['kind'] == 'video') {
      mediaType = RtcInboundRtpStreamVideo(
        stats['framesDecoded'],
        stats['keyFramesDecoded'],
        stats['frameWidth'],
        stats['frameHeight'],
        stats['totalInterFrameDelay'],
        stats['framesPerSecond'],
        stats['firCount'],
        stats['pliCount'],
        stats['concealmentEvents'],
        stats['framesReceived'],
        stats['sliCount'],
      );
    }

    return RtcInboundRtpStreamStats(
        stats['trackId'],
        tryParse(stats['bytesReceived']),
        stats['packetsReceived'],
        stats['totalDecodeTime'],
        tryParse(stats['jitterBufferEmittedCount']),
        mediaType);
  }

  /// ID of the stats object representing the receiving track.
  String? remoteId;

  /// Total number of bytes received for this [SSRC].
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  int? bytesReceived;

  /// Total number of RTP data packets received for this [SSRC].
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  int? packetsReceived;

  /// Total number of RTP data packets for this [SSRC] that have been lost since
  /// the beginning of reception.
  ///
  /// This number is defined to be the number of packets expected less the
  /// number of packets actually received, where the number of packets received
  /// includes any which are late or duplicates. Thus, packets that arrive late
  /// are not counted as lost, and the loss **may be negative** if there are
  /// duplicates.
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  int? packetsLost;

  /// Packet jitter measured in seconds for this [SSRC].
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  int? jitter;

  /// Total number of seconds that have been spent decoding the [framesDecoded]
  /// frames of the stream.
  ///
  /// The average decode time can be calculated by dividing this value with
  /// [framesDecoded]. The time it takes to decode one frame is the time passed
  /// between feeding the decoder a frame and the decoder returning decoded data
  /// for that frame.
  ///
  /// [framesDecoded]: https://tinyurl.com/srfwrwt
  double? totalDecodeTime;

  /// Total number of audio samples or video frames that have come out of the
  /// jitter buffer (increasing [jitterBufferDelay]).
  ///
  /// [jitterBufferDelay]: https://tinyurl.com/qvoojt5
  int? jitterBufferEmittedCount;

  /// Fields which should be in these [`RtcStats`] based on `mediaType`.
  RtcInboundRtpStreamMediaType? mediaType;
}

/// ICE candidate pair statistics related to the [RTCIceTransport] objects.
///
/// A candidate pair that is not the current pair for a transport is [deleted]
/// when the [RTCIceTransport] does an ICE restart, at the time the state
/// changes to [new][1].
///
/// A candidate pair that is the current pair for a transport is [deleted] after
/// an ICE restart when the [RTCIceTransport] switches to using a candidate pair
/// generated from the new candidates; this time doesn't correspond to any other
/// externally observable event.
///
/// [deleted]: https://w3.org/TR/webrtc-stats#dfn-deleted
/// [RTCIceTransport]: https://w3.org/TR/webrtc#dom-rtcicetransport
/// [1]: https://w3.org/TR/webrtc#dom-rtcicetransportstate-new
class RtcIceCandidatePairStats extends RtcStatsType {
  RtcIceCandidatePairStats(
    this.state,
    this.nominated,
    this.bytesSent,
    this.bytesReceived,
    this.totalRoundTripTime,
    this.currentRoundTripTime,
    this.availableOutgoingBitrate,
  );

  /// Creates [RtcIceCandidatePairStats] basing on the
  /// [ffi.RtcStatsType_RtcIceCandidatePairStats] received from the native side.
  static RtcIceCandidatePairStats fromFFI(
      ffi.RtcStatsType_RtcIceCandidatePairStats stats) {
    return RtcIceCandidatePairStats(
      RtcStatsIceCandidatePairState.values[stats.state.index],
      stats.nominated,
      stats.bytesSent?.toInt(),
      stats.bytesReceived?.toInt(),
      stats.totalRoundTripTime,
      stats.currentRoundTripTime,
      stats.availableOutgoingBitrate,
    );
  }

  /// Creates [RtcIceCandidatePairStats] basing on the [Map] received from the
  /// native side.
  static RtcIceCandidatePairStats fromMap(dynamic stats) {
    return RtcIceCandidatePairStats(
      iceCandidatePairStateTryFromString(stats['state'])!,
      stats['nominated'],
      tryParse(stats['bytesSent']),
      tryParse(stats['bytesReceived']),
      stats['totalRoundTripTime'],
      stats['currentRoundTripTime'],
      stats['availableOutgoingBitrate'],
    );
  }

  /// State of the checklist for the local and remote candidates in a pair.
  RtcStatsIceCandidatePairState state;

  /// Related to updating the nominated flag described in
  /// [Section 7.1.3.2.4 of RFC 5245][1].
  ///
  /// [1]: https://tools.ietf.org/html/rfc5245#section-7.1.3.2.4
  bool? nominated;

  /// Total number of payload bytes sent on this candidate pair, i.e. not
  /// including headers or padding.
  int? bytesSent;

  /// Total number of payload bytes received on this candidate pair, i.e. not
  /// including headers or padding.
  int? bytesReceived;

  /// Sum of all round trip time measurements in seconds since the beginning of
  /// the session, based on STUN connectivity check [STUN-PATH-CHAR] responses
  /// ([responsesReceived][2]), including those that reply to requests that are
  /// sent in order to verify consent [RFC 7675].
  ///
  /// The average round trip time can be computed from [totalRoundTripTime][1]
  /// by dividing it by [responsesReceived][2].
  ///
  /// [STUN-PATH-CHAR]: https://w3.org/TR/webrtc-stats#bib-stun-path-char
  /// [RFC 7675]: https://tools.ietf.org/html/rfc7675
  /// [1]: https://tinyurl.com/tgr543a
  /// [2]: https://tinyurl.com/r3zo2um
  double? totalRoundTripTime;

  /// Latest round trip time measured in seconds, computed from both STUN
  /// connectivity checks [STUN-PATH-CHAR], including those that are sent for
  /// consent verification [RFC 7675].
  ///
  /// [STUN-PATH-CHAR]: https://w3.org/TR/webrtc-stats#bib-stun-path-char
  /// [RFC 7675]: https://tools.ietf.org/html/rfc7675
  double? currentRoundTripTime;

  /// Calculated by the underlying congestion control by combining the available
  /// bitrate for all the outgoing RTP streams using this candidate pair. The
  /// bitrate measurement does not count the size of the IP or other transport
  /// layers like TCP or UDP. It is similar to the TIAS defined in [RFC 3890],
  /// i.e. it is measured in bits per second and the bitrate is calculated over
  /// a 1 second window.
  ///
  /// Implementations that do not calculate a sender-side estimate MUST leave
  /// this undefined. Additionally, the value MUST be undefined for candidate
  /// pairs that were never used. For pairs in use, the estimate is normally no
  /// lower than the bitrate for the packets sent at
  /// [lastPacketSentTimestamp][1], but might be higher. For candidate pairs
  /// that are not currently in use but were used before, implementations MUST
  /// return undefined.
  ///
  /// [RFC 3890]: https://tools.ietf.org/html/rfc3890
  /// [1]: https://tinyurl.com/rfc72eh
  double? availableOutgoingBitrate;
}

/// Transport statistics related to the [RTCPeerConnection] object.
///
/// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
class RtcTransportStats extends RtcStatsType {
  RtcTransportStats(
    this.packetsSent,
    this.packetsReceived,
    this.bytesSent,
    this.bytesReceived,
    this.iceRole,
  );

  /// Creates [RtcIceCandidatePairStats] basing on the
  /// [ffi.RtcStatsType_RtcIceCandidatePairStats] received from the native side.
  static RtcTransportStats fromFFI(ffi.RtcStatsType_RtcTransportStats stats) {
    IceRole? role;
    if (stats.iceRole != null) {
      role = IceRole.values[stats.iceRole!.index];
    }
    return RtcTransportStats(
        stats.packetsSent?.toInt(),
        stats.packetsReceived?.toInt(),
        stats.bytesSent?.toInt(),
        stats.bytesReceived?.toInt(),
        role);
  }

  /// Creates [RtcTransportStats] basing on the [Map] received from the native
  /// side.
  static RtcTransportStats fromMap(dynamic stats) {
    return RtcTransportStats(
        tryParse(stats['packetsSent']),
        tryParse(stats['packetsReceived']),
        tryParse(stats['bytesSent']),
        tryParse(stats['bytesReceived']),
        IceRole.values.byName(stats['iceRole']));
  }

  /// Total number of packets sent over this transport.
  int? packetsSent;

  /// Total number of packets received on this transport.
  int? packetsReceived;

  /// Total number of payload bytes sent on this [RTCPeerConnection], i.e. not
  /// including headers or padding.
  ///
  /// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
  int? bytesSent;

  /// Total number of bytes received on this [RTCPeerConnection], i.e. not
  /// including headers or padding.
  ///
  /// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
  int? bytesReceived;

  /// Set to the current value of the [role][1] of the underlying
  /// [RTCDtlsTransport][2]'s [transport][3].
  ///
  /// [1]: https://w3.org/TR/webrtc#dom-icetransport-role
  /// [2]: https://w3.org/TR/webrtc#rtcdtlstransport-interface
  /// [3]: https://w3.org/TR/webrtc#dom-rtcdtlstransport-icetransport
  IceRole? iceRole;
}

/// Statistics for the remote endpoint's inbound [RTP] stream corresponding to
/// an outbound stream that is currently sent with [RTCPeerConnection] object.
///
/// It is measured at the remote endpoint and reported in a RTCP Receiver Report
/// (RR) or RTCP Extended Report (XR).
///
/// [RTP]: https://en.wikipedia.org/wiki/Real-time_Transport_Protocol
/// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
class RtcRemoteInboundRtpStreamStats extends RtcStatsType {
  RtcRemoteInboundRtpStreamStats(
    this.localId,
    this.roundTripTime,
    this.fractionLost,
    this.roundTripTimeMeasurements,
    this.jitter,
    this.reportsReceived,
  );

  /// Creates [RtcRemoteInboundRtpStreamStats] basing on the
  /// [ffi.RtcStatsType_RtcRemoteInboundRtpStreamStats] received from the native
  /// side.
  static RtcRemoteInboundRtpStreamStats fromFFI(
      ffi.RtcStatsType_RtcRemoteInboundRtpStreamStats stats) {
    return RtcRemoteInboundRtpStreamStats(
      stats.localId,
      stats.roundTripTime,
      stats.fractionLost,
      stats.roundTripTimeMeasurements,
      stats.jitter,
      stats.reportsReceived?.toInt(),
    );
  }

  /// Creates [RtcRemoteInboundRtpStreamStats] basing on the [Map] received from
  /// the native side.
  static RtcRemoteInboundRtpStreamStats fromMap(dynamic stats) {
    return RtcRemoteInboundRtpStreamStats(
      stats['localId'],
      stats['roundTripTime'],
      stats['fractionLost'],
      stats['roundTripTimeMeasurements'],
      stats['jitter'],
      stats['reportsReceived'],
    );
  }

  /// [localId] is used for looking up the local [RTCOutboundRtpStreamStats][1]
  /// object for the same [SSRC].
  ///
  /// [localId]: https://tinyurl.com/r8uhbo9
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  /// [1]: https://w3.org/TR/webrtc-stats#dom-rtcoutboundrtpstreamstats
  String? localId;

  /// Packet jitter measured in seconds for this [SSRC].
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  double? jitter;

  /// Estimated round trip time for this [SSRC] based on the RTCP timestamps in
  /// the RTCP Receiver Report (RR) and measured in seconds.
  /// Calculated as defined in [Section 6.4.1 of RFC 3550][1].
  /// If no RTCP Receiver Report is received with a DLSR value other than 0, the
  /// round trip time is left undefined.
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  /// [1]: https://tools.ietf.org/html/rfc3550#section-6.4.1
  double? roundTripTime;

  /// Fraction packet loss reported for this [SSRC].
  /// Calculated as defined in [Section 6.4.1 of RFC 3550][1] and
  /// [Appendix A.3][2].
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  /// [1]: https://tools.ietf.org/html/rfc3550#section-6.4.1
  /// [2]: https://tools.ietf.org/html/rfc3550#appendix-A.3
  double? fractionLost;

  /// Total number of RTCP RR blocks received for this [SSRC].
  ///
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  int? reportsReceived;

  /// Total number of RTCP RR blocks received for this [SSRC] that contain a
  /// valid round trip time. This counter will increment if the [roundTripTime]
  /// is undefined.
  ///
  /// [roundTripTime]: https://tinyurl.com/ssg83hq
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  int? roundTripTimeMeasurements;
}

/// Statistics for the remote endpoint's outbound [RTP] stream corresponding to
/// an inbound stream that is currently received with [RTCPeerConnection]
/// object.
///
/// It is measured at the remote endpoint and reported in an RTCP Sender Report
/// (SR).
///
/// [RTP]: https://en.wikipedia.org/wiki/Real-time_Transport_Protocol
/// [RTCPeerConnection]: https://w3.org/TR/webrtc#dom-rtcpeerconnection
class RtcRemoteOutboundRtpStreamStats extends RtcStatsType {
  RtcRemoteOutboundRtpStreamStats(
    this.localId,
    this.remoteTimestamp,
    this.reportsSent,
  );

  /// Creates [RtcRemoteOutboundRtpStreamStats] basing on the
  /// [ffi.RtcStatsType_RtcRemoteOutboundRtpStreamStats] received from the
  /// native side.
  static RtcRemoteOutboundRtpStreamStats fromFFI(
      ffi.RtcStatsType_RtcRemoteOutboundRtpStreamStats stats) {
    return RtcRemoteOutboundRtpStreamStats(
      stats.localId,
      stats.remoteTimestamp,
      stats.reportsSent?.toInt(),
    );
  }

  /// Creates [RtcRemoteOutboundRtpStreamStats] basing on the [Map] received
  /// from the native side.
  static RtcRemoteOutboundRtpStreamStats fromMap(dynamic stats) {
    return RtcRemoteOutboundRtpStreamStats(
      stats['localId'],
      stats['remoteTimestamp'],
      tryParse(stats['reportsSent']),
    );
  }

  /// [localId] is used for looking up the local [RTCInboundRtpStreamStats][1]
  /// object for the same [SSRC].
  ///
  /// [localId]: https://tinyurl.com/vu9tb2e
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssrc
  /// [1]: https://w3.org/TR/webrtc-stats#dom-rtcinboundrtpstreamstats
  String? localId;

  /// [remoteTimestamp] (as [HIGHRES-TIME]) is the remote timestamp at which
  /// these statistics were sent by the remote endpoint. This differs from
  /// timestamp, which represents the time at which the statistics were
  /// generated or received by the local endpoint. The [remoteTimestamp],
  /// if present, is derived from the NTP timestamp in an RTCP Sender Report
  /// (SR) block, which reflects the remote endpoint's clock. That clock may not
  /// be synchronized with the local clock.
  ///
  /// [HIGRES-TIME]: https://w3.org/TR/webrtc-stats#bib-highres-time
  /// [remoteTimestamp]: https://tinyurl.com/rzlhs87
  double? remoteTimestamp;

  /// Total number of RTCP SR blocks sent for this [SSRC].
  /// [SSRC]: https://w3.org/TR/webrtc-stats#dfn-ssr
  int? reportsSent;
}
