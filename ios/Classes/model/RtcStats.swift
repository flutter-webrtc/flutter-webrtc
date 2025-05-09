import WebRTC

/// Representation of an `RTCStatisticsReport`.
class RtcStats {
  /// List of all RTC stats reports converted to flat `Map`.
  var statsList: [[String: Any]] = []

  /// Converts the provided `RTCStatisticsReport` into `RtcStats`.
  init(report: RTCStatisticsReport) {
    for (_, stats) in report.statistics {
      var statDetails: [String: Any] = [:]
      statDetails["id"] = stats.id
      statDetails["type"] = stats.type
      statDetails["timestampUs"] = Int(stats.timestamp_us)

      for (statName, statValue) in stats.values {
        statDetails[statName] = statValue
      }

      self.statsList.append(statDetails)
    }
  }

  /// Converts these `RtcStats` into a `Map` which can be returned to the
  /// Flutter side.
  func asFlutterResult() -> [[String: Any]] {
    return self.statsList
  }
}
