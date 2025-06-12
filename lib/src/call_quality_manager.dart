import 'dart:async';
import 'dart:math'; // For min/max

import 'package:webrtc_interface/webrtc_interface.dart';

class CallQualityManagerSettings {
  final double packetLossThresholdPercent;
  final double rttThresholdSeconds;
  final double jitterThresholdSeconds;
  final double bweMinDecreaseFactor; // e.g., 0.8 (if BWE is < 80% of current, consider it much lower)
  final double bweMinIncreaseFactor; // e.g., 1.2 (if BWE is > 120% of current, consider it much higher)
  final double bweTargetHeadroomFactor; // e.g., 0.9 (target 90% of BWE)
  final double cautiousIncreaseFactor; // e.g., 1.1 (increase current by 10%)
  final double packetLossBitrateFactor; // e.g., 0.8 (reduce bitrate to 80%)
  final double rttBitrateFactor; // e.g., 0.85
  final double jitterBitrateFactor; // e.g., 0.90
  final int minSensibleBitrateBps; // e.g., 50000
  final bool autoRestartLocallyEndedTracks;
  final Map<String, dynamic>? defaultAudioRestartConstraints;
  final Map<String, dynamic>? defaultVideoRestartConstraints;

  CallQualityManagerSettings({
    this.packetLossThresholdPercent = 10.0,
    this.rttThresholdSeconds = 0.5, // 500ms
    this.jitterThresholdSeconds = 0.03, // 30ms
    this.bweMinDecreaseFactor = 0.8,
    this.bweMinIncreaseFactor = 1.2,
    this.bweTargetHeadroomFactor = 0.9,
    this.cautiousIncreaseFactor = 1.1,
    this.packetLossBitrateFactor = 0.8,
    this.rttBitrateFactor = 0.85,
    this.jitterBitrateFactor = 0.90,
    this.minSensibleBitrateBps = 50000,
    this.autoRestartLocallyEndedTracks = true, // Default to true
    this.defaultAudioRestartConstraints = const {'audio': true}, // Sensible default
    this.defaultVideoRestartConstraints = const {'video': true}, // Sensible default
  });
}

class CallQualityManager {
  final RTCPeerConnection _peerConnection;
  final CallQualityManagerSettings _settings;
  Timer? _timer;

  // Stream controller for track restarted events
  final StreamController<MediaStreamTrack> _onTrackRestartedController = StreamController<MediaStreamTrack>.broadcast();
  /// Emits the new MediaStreamTrack instance when a local track is successfully restarted.
  Stream<MediaStreamTrack> get onTrackRestarted => _onTrackRestartedController.stream;

  // To keep track of local tracks and their senders for potential restart
  final Map<String, RTCRtpSender> _monitoredLocalTrackIdToSender = {};
  final List<StreamSubscription<void>> _trackEndedSubscriptions = [];

  CallQualityManager(this._peerConnection, [CallQualityManagerSettings? settings])
      : _settings = settings ?? CallQualityManagerSettings();

  Future<void> _handleLocalTrackEnded(MediaStreamTrack endedTrack, RTCRtpSender sender) async {
    print('CallQualityManager: Local track ${endedTrack.id} associated with sender ${sender.senderId} has ended.');

    // Remove from monitoring to prevent trying to restart multiple times if events are duplicated
    _monitoredLocalTrackIdToSender.remove(endedTrack.id);

    if (_settings.autoRestartLocallyEndedTracks) {
      print('CallQualityManager: Auto-restart policy enabled. Attempting to restart track ${endedTrack.id}.');
      Map<String, dynamic>? restartConstraints;
      if (endedTrack.kind == 'audio') {
        restartConstraints = _settings.defaultAudioRestartConstraints;
      } else if (endedTrack.kind == 'video') {
        restartConstraints = _settings.defaultVideoRestartConstraints;
      }

      if (restartConstraints == null) {
        print('CallQualityManager: No default restart constraints found for track kind ${endedTrack.kind}. Cannot restart.');
        return;
      }

      if (endedTrack is MediaStreamTrackNative) { // Ensure it's our native track type with restart()
        try {
          final newTrack = await endedTrack.restart(restartConstraints);
          if (newTrack != null) {
            print('CallQualityManager: Track ${endedTrack.id} restarted successfully. New track ID: ${newTrack.id}. Replacing on sender ${sender.senderId}.');
            await sender.replaceTrack(newTrack);

            if (!_onTrackRestartedController.isClosed) {
              _onTrackRestartedController.add(newTrack);
            }

            // After replacing, we should monitor the new track
             _monitorTrack(newTrack, sender); // Re-monitor the new track
          } else {
            print('CallQualityManager: Restart for track ${endedTrack.id} did not yield a new track.');
          }
        } catch (e) {
          print('CallQualityManager: Error restarting track ${endedTrack.id}: $e');
        }
      } else {
        print('CallQualityManager: Track ${endedTrack.id} is not a MediaStreamTrackNative instance, cannot call restart().');
      }
    } else {
      print('CallQualityManager: Auto-restart policy disabled. Not restarting track ${endedTrack.id}.');
    }
  }
   void _monitorTrack(MediaStreamTrack track, RTCRtpSender sender) {
    if (track is MediaStreamTrackNative && track.isLocal) {
      if (_monitoredLocalTrackIdToSender.containsKey(track.id!)) {
        // Already monitoring or re-monitoring after restart
        // Potentially cancel old subscription if any for this track ID before adding new one
        // For simplicity, assume this is handled if track IDs are unique for new tracks
      }
      _monitoredLocalTrackIdToSender[track.id!] = sender;
      _trackEndedSubscriptions.add(track.onEnded.listen((_) {
        _handleLocalTrackEnded(track, sender);
      }));
      print('CallQualityManager: Now monitoring local track ${track.id} for sender ${sender.senderId}.');
    }
  }


  Future<void> _monitorCallQuality(Timer timer) async {
    print('CallQualityManager: Running quality check...');

    num? estimatedAvailableSendBitrate;

    try {
      // 1. Get overall peer connection stats, including candidate pair for BWE
      final allStats = await _peerConnection.getStats(null);
      for (final report in allStats) {
        if (report.type == 'candidate-pair' &&
            (report.values['state'] == 'succeeded' || report.values['state'] == 'inprogress') &&
            report.values.containsKey('availableOutgoingBitrate')) {
          estimatedAvailableSendBitrate = report.values['availableOutgoingBitrate'] as num?;
          if (report.values['state'] == 'succeeded') {
            break;
          }
        }
      }

      if (estimatedAvailableSendBitrate != null) {
        print('CallQualityManager: Estimated available outgoing bitrate: ${(estimatedAvailableSendBitrate! / 1000).toStringAsFixed(0)} kbps');
      } else {
        print('CallQualityManager: availableOutgoingBitrate not found in candidate-pair stats.');
      }

      final senders = await _peerConnection.getSenders();
      for (final sender in senders) {
        if (sender.track != null && sender.track!.kind == 'video') {
          print('CallQualityManager: Checking stats for video sender: ${sender.senderId}');
          final trackStats = await _peerConnection.getStats(sender.track!);

          RTCRtpParameters parameters = await sender.getParameters();
          if (parameters.encodings == null || parameters.encodings!.isEmpty) {
            print('CallQualityManager: Sender ${sender.senderId} has no encodings, skipping.');
            continue;
          }
          final currentEncoding = parameters.encodings![0];
          int? currentMaxBitrate = currentEncoding.maxBitrate;

          if (currentMaxBitrate == null || currentMaxBitrate == 0) {
             print('CallQualityManager: Sender ${sender.senderId} has no current maxBitrate set. Quality metrics might suggest setting one if issues arise.');
          }

          int? newProposedMaxBitrate = currentMaxBitrate;

          if (estimatedAvailableSendBitrate != null && currentMaxBitrate != null && currentMaxBitrate > 0) {
            if (estimatedAvailableSendBitrate! < currentMaxBitrate * _settings.bweMinDecreaseFactor) {
              newProposedMaxBitrate = (estimatedAvailableSendBitrate! * _settings.bweTargetHeadroomFactor).toInt();
              print('CallQualityManager: BWE is significantly lower. Proposing new maxBitrate: $newProposedMaxBitrate based on BWE.');
            }
          }

          double qualityAdjustmentFactor = 1.0;
          bool qualityIssueDetected = false;

          for (final report in trackStats) {
            if (report.type == 'outbound-rtp' && report.values.containsKey('packetsSent')) {
              final packetsSent = report.values['packetsSent'] as num?;
              final packetsLost = report.values['packetsLost'] as num?;
              final roundTripTime = report.values['roundTripTime'] as num? ??
                                    ((report.values['totalRoundTripTime'] as num? ?? 0.0) /
                                     (report.values['responsesReceived'] as num? ?? 1.0));
              final jitter = report.values['jitter'] as num?;

              if (packetsSent != null && packetsLost != null && packetsSent > 0) {
                double packetLossPercentage = (packetsLost / packetsSent) * 100;
                print('CallQualityManager: Sender ${sender.senderId} (outbound-rtp) - Packets Sent: $packetsSent, Packets Lost: $packetsLost, Loss: ${packetLossPercentage.toStringAsFixed(2)}%');

                if (packetLossPercentage > _settings.packetLossThresholdPercent) {
                  print('CallQualityManager: High packet loss detected (${packetLossPercentage.toStringAsFixed(2)}%).');
                  qualityAdjustmentFactor = (qualityAdjustmentFactor * _settings.packetLossBitrateFactor).clamp(0.0, 1.0);
                  qualityIssueDetected = true;
                }
              }

              if (roundTripTime != null && roundTripTime > 0) {
                print('CallQualityManager: Sender ${sender.senderId} (outbound-rtp) - RTT: ${(roundTripTime * 1000).toStringAsFixed(0)}ms');
                if (roundTripTime > _settings.rttThresholdSeconds) {
                  print('CallQualityManager: High RTT detected (${(roundTripTime * 1000).toStringAsFixed(0)}ms).');
                  qualityAdjustmentFactor = (qualityAdjustmentFactor * _settings.rttBitrateFactor).clamp(0.0, 1.0);
                  qualityIssueDetected = true;
                }
              } else if (report.values.containsKey('roundTripTime') || report.values.containsKey('totalRoundTripTime')) {
                 print('CallQualityManager: Sender ${sender.senderId} (outbound-rtp) - RTT: N/A (or 0)');
              }

              if (jitter != null) {
                print('CallQualityManager: Sender ${sender.senderId} (outbound-rtp) - Jitter: ${(jitter * 1000).toStringAsFixed(0)}ms');
                if (jitter > _settings.jitterThresholdSeconds) {
                  print('CallQualityManager: High jitter detected (${(jitter * 1000).toStringAsFixed(0)}ms).');
                  qualityAdjustmentFactor = (qualityAdjustmentFactor * _settings.jitterBitrateFactor).clamp(0.0, 1.0);
                  qualityIssueDetected = true;
                }
              } else if (report.values.containsKey('jitter')) {
                 print('CallQualityManager: Sender ${sender.senderId} (outbound-rtp) - Jitter: N/A');
              }
              break;
            }
          }

          int finalProposedBitrate = newProposedMaxBitrate ?? currentMaxBitrate ?? 0;

          if (qualityIssueDetected) {
            finalProposedBitrate = (finalProposedBitrate * qualityAdjustmentFactor).toInt();
            print('CallQualityManager: Quality issues detected. Adjusting proposed bitrate to $finalProposedBitrate.');
          }

          if (!qualityIssueDetected &&
              estimatedAvailableSendBitrate != null &&
              currentMaxBitrate != null && currentMaxBitrate > 0 &&
              estimatedAvailableSendBitrate! > currentMaxBitrate * _settings.bweMinIncreaseFactor) {
            int upwardAdjustedBitrate = (currentMaxBitrate * _settings.cautiousIncreaseFactor).toInt();
            upwardAdjustedBitrate = upwardAdjustedBitrate.clamp(0, (estimatedAvailableSendBitrate! * _settings.bweTargetHeadroomFactor).toInt());
            // Only take this if it's higher than what quality metrics (which should be good) might have proposed
            // This essentially means, if quality is good, try to ramp up to BWE.
             if (upwardAdjustedBitrate > finalProposedBitrate) {
               finalProposedBitrate = upwardAdjustedBitrate;
               print('CallQualityManager: Good quality and BWE allows. Proposing upward adjustment to $finalProposedBitrate.');
            }
          }

          // Determine if an actual change should be applied
          bool shouldApplyChange = false;
          if (currentMaxBitrate == null || currentMaxBitrate == 0) {
            // If no bitrate is set, and we have a BWE-based proposal, consider setting it.
            if (estimatedAvailableSendBitrate != null && newProposedMaxBitrate != null && newProposedMaxBitrate > _settings.minSensibleBitrateBps) {
                finalProposedBitrate = newProposedMaxBitrate; // Use BWE based proposal primarily
                if (qualityIssueDetected) { // If quality issues, still apply factor
                    finalProposedBitrate = (finalProposedBitrate * qualityAdjustmentFactor).toInt();
                }
                print('CallQualityManager: Current maxBitrate is not set. Proposing to set to $finalProposedBitrate.');
                shouldApplyChange = true;
            } else {
                 print('CallQualityManager: Current maxBitrate is not set and no reliable BWE to initialize. No change.');
            }
          } else if (finalProposedBitrate < currentMaxBitrate!) {
            shouldApplyChange = true;
          } else if (finalProposedBitrate > currentMaxBitrate! && !qualityIssueDetected) { // Only increase if quality is good
            shouldApplyChange = true;
          }


          if (shouldApplyChange) {
            int bitrateToApply = finalProposedBitrate;
            if (currentMaxBitrate != null && currentMaxBitrate! > 0 && bitrateToApply < _settings.minSensibleBitrateBps && currentMaxBitrate! > _settings.minSensibleBitrateBps) {
                bitrateToApply = _settings.minSensibleBitrateBps;
                print('CallQualityManager: Adjusted proposed bitrate to minimum sensible ${_settings.minSensibleBitrateBps}bps.');
            } else if (bitrateToApply < _settings.minSensibleBitrateBps && (currentMaxBitrate == null || currentMaxBitrate == 0) ){
                bitrateToApply = _settings.minSensibleBitrateBps;
                print('CallQualityManager: Current maxBitrate is not set, ensuring proposed $bitrateToApply is at least min sensible.');
            }


            if (bitrateToApply != currentMaxBitrate) {
                print('CallQualityManager: Attempting to set maxBitrate to $bitrateToApply for sender ${sender.senderId}. Current: $currentMaxBitrate');
                try {
                    currentEncoding.maxBitrate = bitrateToApply;
                    await sender.setParameters(parameters);
                    print('CallQualityManager: Successfully applied new bitrate $bitrateToApply for sender ${sender.senderId}.');
                } catch (e) {
                    print('CallQualityManager: Error adjusting bitrate for sender ${sender.senderId}: $e');
                }
            } else {
                 print('CallQualityManager: Proposed bitrate ($bitrateToApply) is same as current ($currentMaxBitrate). No change applied.');
            }
          } else {
            print('CallQualityManager: No bitrate adjustment deemed necessary for sender ${sender.senderId}. Final proposed: $finalProposedBitrate, Current: $currentMaxBitrate, Quality Issues: $qualityIssueDetected');
          }
        }
      }
    } catch (e) {
      print('CallQualityManager: Error in _monitorCallQuality: $e');
    }
  }

  Future<void> start({Duration period = const Duration(seconds: 5)}) async {
    print('CallQualityManager: Starting quality monitoring with period $period.');
    // Stop any existing monitoring first
    await stop();

    // Start the stats monitoring timer
    _timer = Timer.periodic(period, _monitorCallQuality);
    print('CallQualityManager: Stats monitoring timer started.');

    // Discover and monitor local tracks for 'onEnded' events
    try {
      final senders = await _peerConnection.getSenders();
      for (final sender in senders) {
        if (sender.track != null) {
           // We need to ensure sender.track is MediaStreamTrackNative and has 'isLocal'
           // This cast might fail if the track is not of this specific type.
           // It's safer if MediaStreamTrack interface itself could indicate locality or if
           // local tracks are explicitly passed to the CallQualityManager.
          var track = sender.track; // Assuming it's already MediaStreamTrackNative or similar
          if (track is MediaStreamTrackNative && track.isLocal) {
             _monitorTrack(track, sender);
          }
        }
      }
    } catch (e) {
      print('CallQualityManager: Error during initial track scan for monitoring: $e');
    }
  }

  Future<void> stop() async {
    print('CallQualityManager: Stopping quality monitoring...');
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
      print('CallQualityManager: Stats monitoring timer stopped.');
    }
    _timer = null;

    for (var sub in _trackEndedSubscriptions) {
      await sub.cancel();
    }
    _trackEndedSubscriptions.clear();
    _monitoredLocalTrackIdToSender.clear();
    print('CallQualityManager: Local track monitoring stopped and subscriptions cleared.');
  }

  // Optional: A method to dispose of the manager if the peer connection is closed.
  Future<void> dispose() async {
    await stop();
    if (!_onTrackRestartedController.isClosed) {
      _onTrackRestartedController.close();
    }
    // Any other cleanup related to CallQualityManager itself.
    print('CallQualityManager: Disposed.');
  }
}
