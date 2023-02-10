class PlayerSettings {
  final bool canPause; // support play/pause live stream
  final bool canPtz; // support ptz
  final bool canHd; // support hd
  final bool canRecord; // support two way audio
  final bool canAudio; // support audio
  final bool canFullscreen; // support full/exit screen
  final bool canSpeed; // support switch play speed
  final bool canForward; // support forward 2 minutes
  final bool canRewind; // support rewind 2 minutes

  final bool canAutoHidden; // support auto hidden panel or not
  final int autoHiddenInterval; // auto hidden panel timer interval

  final bool canDoubleTap; // support double tap

  final bool liveBadge; // show live badge or not

  final bool canHdStandby; // standby or not
  final int hdStandbyInterval; // standby time interval (seconds)

  const PlayerSettings({
    this.canPause = true,
    this.canPtz = false,
    this.canHd = false,
    this.canRecord = false,
    this.canAudio = false,
    this.canFullscreen = true,
    this.canSpeed = false,
    this.canForward = false,
    this.canRewind = false,
    this.canAutoHidden = false,
    this.autoHiddenInterval = 3,
    this.canDoubleTap = false,
    this.liveBadge = true,
    this.canHdStandby = false,
    this.hdStandbyInterval = 270,
  });

  PlayerSettings copyWith({
    bool? canPause,
    bool? canPtz,
    bool? canHd,
    bool? canRecord,
    bool? canAudio,
    bool? canFullscreen,
    bool? canSpeed,
    bool? canForward,
    bool? canRewind,
    bool? canAutoHidden,
    bool? canDoubleTap,
    int? autoHiddenInterval,
    bool? liveBadge,
  }) {
    return PlayerSettings(
      canPause: canPause ?? this.canPause,
      canPtz: canPtz ?? this.canPtz,
      canHd: canHd ?? this.canHd,
      canRecord: canRecord ?? this.canRecord,
      canAudio: canAudio ?? this.canAudio,
      canFullscreen: canFullscreen ?? this.canFullscreen,
      canSpeed: canSpeed ?? this.canSpeed,
      canForward: canForward ?? this.canForward,
      canRewind: canRewind ?? this.canRewind,
      canAutoHidden: canAutoHidden ?? this.canAutoHidden,
      canDoubleTap: canDoubleTap ?? this.canDoubleTap,
      autoHiddenInterval: autoHiddenInterval ?? this.autoHiddenInterval,
      liveBadge: liveBadge ?? this.liveBadge,
    );
  }

  /// live
  factory PlayerSettings.live({
    bool canPause = true,
    bool canPtz = true,
    bool canHd = true,
    bool canRecord = false,
    bool canAudio = false,
    bool canFullscreen = true,
    bool canAutoHidden = true,
    int autoHiddenInterval = 3,
    bool canDoubleTap = true,
    bool canHdStandby = false,
    int hdStandbyInterval = 270,
  }) {
    return PlayerSettings(
      canPause: canPause,
      canPtz: canPtz,
      canHd: canHd,
      canRecord: canRecord,
      canAudio: canAudio,
      canFullscreen: canFullscreen,
      canAutoHidden: canAutoHidden,
      autoHiddenInterval: autoHiddenInterval,
      canDoubleTap: canDoubleTap,
      canHdStandby: canHdStandby,
      hdStandbyInterval: hdStandbyInterval,
    );
  }

  /// playback
  factory PlayerSettings.playback({
    bool canPause = true,
    bool canHd = false,
    bool canAudio = false,
    bool canFullscreen = true,
    bool canSpeed = true,
    bool canForward = true,
    bool canRewind = true,
  }) {
    return PlayerSettings(
      canPause: canPause,
      canHd: canHd,
      canAudio: canAudio,
      canFullscreen: canFullscreen,
      canSpeed: canSpeed,
      canForward: canForward,
      canRewind: canRewind,
    );
  }

  /// simple
  factory PlayerSettings.simple() {
    return const PlayerSettings(
      canPause: false,
      canFullscreen: false,
      canDoubleTap: true,
      liveBadge: false,
    );
  }

  /// center
  factory PlayerSettings.center({
    bool canPause = true,
    bool canPtz = false,
    bool canAudio = false,
    bool canFullscreen = true,
    bool canAutoHidden = true,
    int autoHiddenInterval = 3,
  }) {
    return PlayerSettings(
      canPause: canPause,
      canFullscreen: canFullscreen,
      canPtz: canPtz,
      canAudio: canAudio,
      canAutoHidden: canAutoHidden,
      autoHiddenInterval: autoHiddenInterval,
    );
  }

  /// ptz
  factory PlayerSettings.ptz({bool canPtz = false}) {
    return PlayerSettings(
      canPause: false,
      canFullscreen: true,
      canPtz: canPtz,
      canDoubleTap: true,
    );
  }
}
