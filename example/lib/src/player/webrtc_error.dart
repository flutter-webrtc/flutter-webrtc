class WebrtcError {
  final int ec;
  final String em;
  final String dm;

  const WebrtcError(this.ec, this.em, this.dm);

  static const none = WebrtcError(ErrorCode.success, '', '');
  static const unknown = WebrtcError(ErrorCode.unknown, '', 'unknown');
  static const timeout = WebrtcError(
    ErrorCode.receiveTimeout,
    "The connection has timed out. Check your network connection and try again.",
    "Connection Timed Out",
  );

  bool get isNotNone => ec != ErrorCode.success;

  @override
  String toString() {
    return 'ErrorCode: $ec\nErrorMessage: $em\nDebugMessage: $dm';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;

    return other is WebrtcError &&
        other.ec == ec &&
        other.em == em &&
        other.dm == dm;
  }

  @override
  int get hashCode => ec.hashCode ^ em.hashCode ^ dm.hashCode;
}

class ErrorCode {
  static const success = 0;
  static const connectTimeout = -1;
  static const sendTimeout = -2;
  static const receiveTimeout = -3;
  static const response = -4;
  static const cancel = -5;
  static const other = -6;
  static const socket = -7;
  static const ignore = -8;
  static const unknown = -10;
}
