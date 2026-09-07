import 'package:flutter/services.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_webrtc/src/picture_in_picture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final methodChannel = MethodChannel('FlutterWebRTC.Method');
  final eventChannel = MethodChannel('FlutterWebRTC.Event');
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    messenger.setMockMethodCallHandler(methodChannel, (call) async {
      calls.add(call);
      switch (call.method) {
        case 'pipIsSupported':
        case 'pipStart':
          return true;
        case 'pipIsActive':
          return false;
      }
      return null;
    });
    messenger.setMockMethodCallHandler(eventChannel, (call) async => null);
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(methodChannel, null);
    messenger.setMockMethodCallHandler(eventChannel, null);
  });

  Future<void> emit(Map<String, dynamic> event) async {
    await messenger.handlePlatformMessage(
      'FlutterWebRTC.Event',
      const StandardMethodCodec().encodeSuccessEnvelope(event),
      (_) {},
    );
    await pumpEventQueue();
  }

  test('isSupported forwards to the platform', () async {
    expect(await RTCPictureInPictureController.isSupported(), isTrue);
    expect(calls.map((c) => c.method), contains('pipIsSupported'));
  });

  test('configure sends the expected arguments', () async {
    final controller = RTCPictureInPictureController();
    await controller.configure(
      sourceRect: Rect.fromLTWH(10, 20, 100, 50),
      aspectRatio: 1.5,
      autoEnter: false,
    );
    final call = calls.singleWhere((c) => c.method == 'pipConfigure');
    final args = call.arguments as Map;
    expect(args['streamId'], '');
    expect(args['trackId'], '0');
    expect(args['aspectRatio'], 1.5);
    expect(args['autoEnter'], isFalse);
    expect(args['seamlessResize'], isTrue);
    expect(args['objectFit'], 'contain');
    expect(args['sourceRect'],
        {'left': 10.0, 'top': 20.0, 'right': 110.0, 'bottom': 70.0});
    await controller.dispose();
    expect(calls.last.method, 'pipDispose');
  });

  test('state events update the notifier and the stream', () async {
    final controller = RTCPictureInPictureController();
    final received = <RTCPictureInPictureState>[];
    controller.events.listen((e) => received.add(e.state));

    await emit({'event': 'pictureInPictureStateChanged', 'state': 'started'});
    expect(controller.value, isTrue);

    await emit({
      'event': 'pictureInPictureStateChanged',
      'state': 'failed',
      'error': 'boom',
    });
    expect(controller.value, isFalse);

    await emit({'event': 'onDeviceChange'});

    expect(received, [
      RTCPictureInPictureState.started,
      RTCPictureInPictureState.failed,
    ]);
    await controller.dispose();
  });

  test('methods throw after dispose', () async {
    final controller = RTCPictureInPictureController();
    await controller.dispose();
    expect(() => controller.start(), throwsStateError);
  });
}
