/// Unique ID generator for the all local `MediaStreamTrackProxy`s.
class LocalTrackIdGenerator {
  /// Singleton instance of `LocalTrackIdGenerator`.
  static let shared: LocalTrackIdGenerator = .init()

  /// Last generated track ID.
  private var lastId: Int = 0

  /// Returns a new local `MediaStreamTrackProxy` unique ID.
  func nextId() -> String {
    self.lastId += 1
    return "local-\(self.lastId)"
  }
}
