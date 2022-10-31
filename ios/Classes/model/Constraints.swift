import AVFoundation

/// Direction in which a camera produces video.
///
/// [Int] value is representation of this enum which will be expected on Flutter
/// side.
enum FacingMode: Int {
  /// Video source is facing toward the user (this includes, for example, the
  /// front-facing camera on a smartphone).
  case user = 0

  /// Video source is facing away from the user, thereby viewing their
  /// environment (this is the back camera on a smartphone).
  case environment = 1

  /// Checks whether the provided `position` fits into this `FacingMode`.
  func isFits(position: AVCaptureDevice.Position) -> Bool {
    var facingModeInt = 0
    switch self {
    case .user:
      facingModeInt = 2
    case .environment:
      facingModeInt = 1
    }
    return facingModeInt == position.rawValue
  }
}

/// Score of [VideoConstraints].
///
/// This score will be determined by a `ConstraintChecker`, and, basing on it,
/// more suitable video device will be selected by `getUserMedia` request.
enum ConstraintScore {
  /// Constraint is not suitable at all.
  ///
  /// So, the device with this score wouldn't used event if there is no other
  /// devices.
  case no

  /// Constraint can be used, but more suitable devices can be found.
  case maybe

  /// Constraint suits ideally.
  case yes

  /// Calculates the total score, based on which media devices will be sorted.
  static func totalScore(scores: [ConstraintScore]) -> Int? {
    var total = 1
    for score in scores {
      switch score {
      case .no:
        return nil
      case .yes:
        total += 1
      case .maybe:
        ()
      }
    }

    return total
  }
}

/// Video constraint which can check suitability of some device.
class ConstraintChecker {
  /// Indicator whether this constraint is mandatory or not.
  var isMandatory: Bool = false

  /// Calculates a `ConstraintScore` of the `device` based on the underlying
  /// algorithm of the concrete constraint.
  func score(device: AVCaptureDevice) throws -> ConstraintScore {
    let fits = try self.isFits(device: device)
    if fits {
      return ConstraintScore.yes
    } else if self.isMandatory, !fits {
      return ConstraintScore.no
    } else {
      return ConstraintScore.maybe
    }
  }

  /// Calculates suitability for the provided `device`.
  func isFits(device _: AVCaptureDevice) throws -> Bool {
    fatalError("isFits is not implemented")
  }
}

/// Constraint searching for a device with some concrete `deviceId`.
class DeviceIdConstraint: ConstraintChecker {
  /// Concrete `deviceId` to be searched.
  var id: String

  /// Initializes a constraint searcher for a device with the specified device
  /// `id`.
  ///
  /// `isMandatory` indicates that the specified constraint is mandatory.
  init(id: String, isMandatory: Bool) {
    self.id = id
    super.init()
    super.isMandatory = isMandatory
  }

  /// Calculates suitability for the provided `device`.
  override func isFits(device: AVCaptureDevice) throws -> Bool {
    device.uniqueID == self.id
  }
}

/// Constraint searching for a device with some [FacingMode].
class FacingModeConstraint: ConstraintChecker {
  /// [FacingMode] to be searched.
  var facingMode: FacingMode

  /// Initializes a constraint searcher for a device with the specified
  /// `FacingMode`.
  ///
  /// `isMandatory` indicates that the specified constraint is mandatory.
  init(facingMode: FacingMode, isMandatory: Bool) {
    self.facingMode = facingMode
    super.init()
    super.isMandatory = isMandatory
  }

  /// Calculates suitability for the provided `device`.
  override func isFits(device: AVCaptureDevice) throws -> Bool {
    self.facingMode.isFits(position: device.position)
  }
}

/// List of constraints for video devices.
class VideoConstraints {
  /// List of the `DeviceIdConstraint`s provided by the user.
  var deviceIdConstraints: [DeviceIdConstraint] = []

  /// List of the `FacingModeConstraint`s provided by the user.
  var facingModeConstraints: [FacingModeConstraint] = []

  /// Width of the device video.
  var width: Int?

  /// Height of the device video.
  var height: Int?

  /// FPS of the device video.
  var fps: Int?

  /// Initializes new `VideoConstraints` based on the method call received from
  /// Flutter side.
  init(map: [String: Any]) {
    let mandatoryArgs = map["mandatory"] as? [String: Any]
    if mandatoryArgs != nil {
      for (key, value) in mandatoryArgs! {
        switch key {
        case "deviceId":
          self.deviceIdConstraints
            .append(DeviceIdConstraint(id: value as! String, isMandatory: true))
        case "facingMode":
          self.facingModeConstraints.append(
            FacingModeConstraint(
              facingMode: FacingMode(rawValue: value as! Int)!,
              isMandatory: true
            )
          )
        case "width":
          self.width = value as! Int
        case "height":
          self.height = value as! Int
        case "fps":
          self.fps = value as! Int
        default:
          ()
        }
      }
    }

    let optionalArgs = map["optional"] as? [String: Any]
    if optionalArgs != nil {
      for (key, value) in optionalArgs! {
        switch key {
        case "deviceId":
          self.deviceIdConstraints
            .append(DeviceIdConstraint(id: value as! String,
                                       isMandatory: false))
        case "facingMode":
          self.facingModeConstraints.append(
            FacingModeConstraint(
              facingMode: FacingMode(rawValue: value as! Int)!,
              isMandatory: false
            )
          )
        case "width":
          self.width = value as! Int
        case "height":
          self.height = value as! Int
        case "fps":
          self.fps = value as! Int
        default:
          ()
        }
      }
    }
  }

  /// Calculates a score for the specified `device`.
  func calculateScoreForDevice(device: AVCaptureDevice) -> Int? {
    var scores: [ConstraintScore] = []
    for c in self.facingModeConstraints {
      scores.append(try! c.score(device: device))
    }
    for c in self.deviceIdConstraints {
      scores.append(try! c.score(device: device))
    }

    return ConstraintScore.totalScore(scores: scores)
  }
}

/// List of constraints for audio devices.
class AudioConstraints {}

/// United audio and video constraints.
class Constraints {
  /// Optional constraints to lookup video devices with.
  var video: VideoConstraints?

  /// Optional constraints to lookup audio devices with.
  var audio: AudioConstraints?

  /// Initializes new `Constraints` based on the method call received from
  /// Flutter side.
  init(map: [String: Any]) {
    let videoArg = map["video"] as? [String: Any]
    if videoArg != nil, !videoArg!.isEmpty {
      self.video = VideoConstraints(map: videoArg!)
    }
    let audioArg = map["audio"] as? [String: Any]
    if audioArg != nil, !audioArg!.isEmpty {
      self.audio = AudioConstraints()
    }
  }
}
