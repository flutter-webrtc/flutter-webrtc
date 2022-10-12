/// Generator of names for Flutter method/event channels.
enum ChannelNameGenerator {
  /// Static prefix for all channels of this plugin
  private static let prefix: String = "FlutterWebRtc"

  /// Last generated ID.
  private static var lastId: Int = 0

  /// Returns a new ID for a channel.
  static func nextId() -> Int {
    ChannelNameGenerator.lastId += 1
    return self.lastId
  }

  /// Returns a name for a channel with the provided `name` and `id`.
  static func name(name: String, id: Int) -> String {
    "\(ChannelNameGenerator.prefix)/\(name)/\(id)"
  }
}
