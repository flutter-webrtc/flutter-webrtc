package com.instrumentisto.medea_flutter_webrtc.model

/**
 * Representation of an [org.webrtc.RTCStatsReport].
 *
 * @property stats `stats` of this [RtcStatsReport].
 */
data class RtcStatsReport(val stats: Map<String, RtcStats>) {
  companion object {
    /**
     * Converts the provided [org.webrtc.RTCStatsReport] into an [RtcStatsReport].
     *
     * @return [RtcStatsReport] created based on the provided [org.webrtc.RTCStatsReport].
     */
    fun fromWebRtc(report: org.webrtc.RTCStatsReport): RtcStatsReport {
      return RtcStatsReport(report.statsMap.mapValues { RtcStats.fromWebRtc(it.value) })
    }
  }

  /** Converts this [RtcStatsReport] into a [Map] which can be returned to the Flutter side. */
  fun asFlutterResult(): List<Map<String, Any>> {
    return stats.map { it.value.asFlutterResult() }
  }
}
