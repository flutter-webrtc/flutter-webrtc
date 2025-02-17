/// Type of a [SessionDescription].
enum SessionDescriptionType {
  /// Indicates that description is the initial proposal in an offer/answer
  /// exchange.
  offer,

  /// Indicates that the description is a provisional answer and may be changed
  /// when the definitive choice will be given.
  pranswer,

  /// Indicates that description is the definitive choice in an offer/answer
  /// exchange.
  answer,

  /// Indicates that description rolls back for an offer/answer state to the
  /// last stable state.
  rollback,
}

/// SDP offer which can be set to a peer connection.
class SessionDescription {
  /// Constructs a new [SessionDescription] with the provided type and SDP.
  SessionDescription(this.type, this.description);

  /// Creates a [SessionDescription] basing on the [Map] received from the
  /// native side.
  SessionDescription.fromMap(dynamic map) {
    type = SessionDescriptionType.values[map['type']];
    description = map['description'];
  }

  /// Type of this [SessionDescription].
  late SessionDescriptionType type;

  /// SDP of this [SessionDescription].
  late String description;

  /// Converts this model to the [Map] expected by Flutter.
  Map<String, dynamic> toMap() {
    return {'type': type.index, 'description': description};
  }
}
