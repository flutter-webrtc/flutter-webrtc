enum PlayerState { connecting, connected, paused, resumed, error }

extension PlayerStateExt on PlayerState {
  String get label {
    switch (this) {
      case PlayerState.connecting:
        return "Connecting...";
      case PlayerState.connected:
        return "Connected";
      case PlayerState.paused:
        return "Paused";
      case PlayerState.resumed:
        return 'Resumed';
      case PlayerState.error:
        return "Connection error, please retry";
    }
  }

  bool get isConnecting => this == PlayerState.connecting;

  bool get isConnected => this == PlayerState.connected || isResumed;

  bool get isError => this == PlayerState.error;

  bool get isPaused => this == PlayerState.paused;

  bool get isResumed => this == PlayerState.resumed;
}

enum PlayerSpeed {
  s4,
  s2,
  x1,
  x2,
  x4;

  String get label {
    switch (this) {
      case s4:
        return '0.25x';
      case s2:
        return '0.5x';
      case x2:
        return '2x';
      case x4:
        return '4x';
      default:
        return '1x';
    }
  }

  double get textScaleFactor {
    switch (this) {
      case s4:
      case s2:
        return 0.8;
      default:
        return 1.0;
    }
  }

  double get value {
    switch (this) {
      case s4:
        return 0.25;
      case s2:
        return 0.5;
      case x2:
        return 2;
      case x4:
        return 4;
      default:
        return 1;
    }
  }
}
