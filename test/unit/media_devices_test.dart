import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/src/native/media_devices_impl.dart'; // The class to test
import 'package:webrtc_interface/webrtc_interface.dart'; // For WebRTC static and custom error types

// Note: MediaDeviceNative.instance is a singleton. Tests might interfere if not careful,
// but for these error mapping tests, it should be okay as we mock the channel response each time.

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Original MethodCallHandler for WebRTC.methodChannel
  MethodCallHandler? originalMethodCallHandler;

  setUp(() {
    // Store original handler and set a mock one for each test
    originalMethodCallHandler = WebRTC.methodChannel.checkMockMethodCallHandler((call) => null);
  });

  tearDown(() {
    // Restore original handler
    WebRTC.methodChannel.setMockMethodCallHandler(originalMethodCallHandler);
  });

  group('MediaDeviceNative getUserMedia error handling', () {
    test('throws PermissionDeniedError for permission denied messages', () async {
      WebRTC.methodChannel.setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'getUserMedia') {
          throw PlatformException(code: 'Error', message: 'User denied permission');
        }
        return null;
      });
      expect(
        () async => await MediaDeviceNative.instance.getUserMedia({}),
        throwsA(isA<PermissionDeniedError>())
      );

      WebRTC.methodChannel.setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'getUserMedia') {
          throw PlatformException(code: 'NotAllowedError', message: 'Some message');
        }
        return null;
      });
      expect(
        () async => await MediaDeviceNative.instance.getUserMedia({}),
        throwsA(isA<PermissionDeniedError>())
      );
       WebRTC.methodChannel.setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'getUserMedia') {
          throw PlatformException(code: ' irgendeinePlatformExceptionCode', message: 'java.lang.SecurityException: Not allowed to access camera.');
        }
        return null;
      });
      expect(
        () async => await MediaDeviceNative.instance.getUserMedia({}),
        throwsA(isA<PermissionDeniedError>())
      );
    });

    test('throws NotFoundError for not found messages', () async {
      WebRTC.methodChannel.setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'getUserMedia') {
          throw PlatformException(code: 'NotFoundError', message: 'Device not found');
        }
        return null;
      });
      expect(
        () async => await MediaDeviceNative.instance.getUserMedia({}),
        throwsA(isA<NotFoundError>())
      );
    });

    test('throws MediaDeviceAcquireError for other PlatformExceptions', () async {
      WebRTC.methodChannel.setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'getUserMedia') {
          throw PlatformException(code: 'SomeOtherError', message: 'Another issue');
        }
        return null;
      });
      expect(
        () async => await MediaDeviceNative.instance.getUserMedia({}),
        throwsA(isA<MediaDeviceAcquireError>())
      );
    });

     test('throws Exception for null response (should not happen with proper native code)', () async {
      WebRTC.methodChannel.setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'getUserMedia') {
          return null; // Simulate native returning null
        }
        return null;
      });
      expect(
        () async => await MediaDeviceNative.instance.getUserMedia({}),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('getUserMedia return null')))
      );
    });
  });

  group('MediaDeviceNative getDisplayMedia error handling', () {
    test('throws PermissionDeniedError for permission denied messages', () async {
      WebRTC.methodChannel.setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'getDisplayMedia') {
          throw PlatformException(code: 'PERMISSION_DENIED', message: 'User did not allow screen capture');
        }
        return null;
      });
      expect(
        () async => await MediaDeviceNative.instance.getDisplayMedia({}),
        throwsA(isA<PermissionDeniedError>())
      );
    });

    test('throws MediaDeviceAcquireError for other PlatformExceptions', () async {
      WebRTC.methodChannel.setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'getDisplayMedia') {
          throw PlatformException(code: 'OtherError', message: 'Screen capture failed');
        }
        return null;
      });
      expect(
        () async => await MediaDeviceNative.instance.getDisplayMedia({}),
        throwsA(isA<MediaDeviceAcquireError>())
      );
    });
  });
}
