import WebRTC

/// Representation of an `RTCSdpType`.
enum SessionDescriptionType: Int {
  /// Description is the initial proposal in an offer/answer exchange.
  case offer

  /// Description is a provisional answer and may be changed when the definitive
  /// choice will be given.
  case prAnswer

  /// Description is the definitive choice in an offer/answer exchange.
  case answer

  /// Description rolls back from an offer/answer state to the last stable
  /// state.
  case rollback

  /// Initializes a new `SessionDescriptionType` based on the provided
  /// `RTCSdpType`.
  init(type: RTCSdpType) {
    switch type {
    case .offer:
      self = SessionDescriptionType.offer
    case .answer:
      self = SessionDescriptionType.answer
    case .prAnswer:
      self = SessionDescriptionType.prAnswer
    case .rollback:
      self = SessionDescriptionType.rollback
    }
  }

  /// Converts this `SessionDescriptionType` into an `RTCSdpType`.
  func intoWebRtc() -> RTCSdpType {
    switch self {
    case .offer:
      return RTCSdpType.offer
    case .answer:
      return RTCSdpType.answer
    case .prAnswer:
      return RTCSdpType.prAnswer
    case .rollback:
      return RTCSdpType.rollback
    }
  }
}
