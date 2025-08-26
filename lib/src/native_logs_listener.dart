import 'package:logger/logger.dart';

import './native/utils.dart';
import 'native/event_channel.dart';

class NativeLogsListener {
  NativeLogsListener._internal() {
    FlutterWebRTCEventChannel.instance.handleEvents.stream.listen((data) {
      var event = data.keys.first;
      Map<dynamic, dynamic> map = data[event];
      handleEvent(event, map);
    });
  }

  static final NativeLogsListener instance = NativeLogsListener._internal();
  Logger? _logger;
  String _severity = 'none';

  String get severity => _severity;

  /// Set Logger object;
  ///
  /// Params:
  ///
  /// "severity": possible values: ['verbose', 'info', 'warning', 'error', 'none']
  void setLogger(Logger logger, [String severity = 'none']) {
    _logger = logger;
    _severity = severity;

    WebRTC.invokeMethod('setLogSeverity', {
      'severity': severity,
    });
  }

  void handleEvent(String event, final Map<dynamic, dynamic> map) async {
    switch (map['event']) {
      case 'onLogData':
        if (_logger != null) {
          _logger?.i('webrtc: ${map['data']}');
        }
        break;
    }
  }
}
