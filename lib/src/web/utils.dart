class WebRTC {
  static bool get platformIsDesktop => false;

  static bool get platformIsWindows => false;

  static bool get platformIsMacOS => false;

  static bool get platformIsLinux => false;

  static bool get platformIsMobile => false;

  static bool get platformIsIOS => false;

  static bool get platformIsAndroid => false;

  static bool get platformIsWeb => true;

  static Future<T?> invokeMethod<T, P>(String methodName,
          [dynamic param]) async =>
      throw UnimplementedError();

  static Future<void> initialize({Map<String, dynamic>? options}) async =>
      throw UnimplementedError('initialize is not supported on web');
}
