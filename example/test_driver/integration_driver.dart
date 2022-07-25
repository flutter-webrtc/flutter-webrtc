import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:integration_test/integration_test_driver_extended.dart';

const String _packageName = 'com.instrumentisto.medea_flutter_webrtc_example';

const List<String> _androidPermissions = ['CAMERA', 'RECORD_AUDIO'];

Future<void> main() async {
  var driver = await FlutterDriver.connect();

  if ((await driver.serviceClient.getVM()).operatingSystem == 'android') {
    for (var permission in _androidPermissions) {
      await Process.run('adb', [
        'shell',
        'pm',
        'grant',
        _packageName,
        'android.permission.$permission'
      ]);
    }
  }

  await integrationDriver(driver: driver);
}
