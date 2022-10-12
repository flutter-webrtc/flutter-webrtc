/// Store for all created `MediaStreamTrackProxy`s in this plugin.
enum MediaStreamTrackStore {
  /// All the `MediaStreamTrackProxy`s created in this plugin.
  static var tracks: [String: MediaStreamTrackProxy] = [:]
}
