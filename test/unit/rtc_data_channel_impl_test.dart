import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/src/native/rtc_data_channel_impl.dart';
import 'package:flutter_webrtc/src/native/utils.dart';
import 'package:webrtc_interface/webrtc_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const peerConnectionId = 'pc';
  const flutterId = 'dc';
  const eventChannelName = 'FlutterWebRTC/dataChannelEventpcdc';
  const methodChannel = MethodChannel('FlutterWebRTC.Method');
  const eventMethodChannel = MethodChannel(eventChannelName);

  RTCDataChannelNative createChannel() =>
      RTCDataChannelNative(peerConnectionId, 'label', 1, flutterId);

  setUp(() {
    methodChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'initialize':
        case 'dataChannelClose':
        case 'dataChannelSend':
          return null;
        case 'dataChannelGetBufferedAmount':
          return <String, dynamic>{'bufferedAmount': 0};
        default:
          return null;
      }
    });

    eventMethodChannel
        .setMockMethodCallHandler((MethodCall methodCall) async => null);
  });

  tearDown(() {
    methodChannel.setMockMethodCallHandler(null);
    eventMethodChannel.setMockMethodCallHandler(null);
    WebRTC.initialized = false;
  });

  test('handles single data channel events', () async {
    final channel = createChannel();

    final callbackMessages = <String>[];
    final streamMessages = <String>[];
    final callbackStates = <RTCDataChannelState>[];
    final streamStates = <RTCDataChannelState>[];
    final bufferedChanges = <List<int>>[];
    final lowBufferedAmounts = <int>[];

    channel.onMessage = (RTCDataChannelMessage message) {
      if (!message.isBinary) {
        callbackMessages.add(message.text);
      }
    };
    channel.onDataChannelState = callbackStates.add;
    channel.onBufferedAmountChange = (int current, int changed) {
      bufferedChanges.add(<int>[current, changed]);
    };
    channel.onBufferedAmountLow = lowBufferedAmounts.add;
    channel.bufferedAmountLowThreshold = 10;

    final messageSub =
        channel.messageStream.listen((RTCDataChannelMessage msg) {
      if (!msg.isBinary) {
        streamMessages.add(msg.text);
      }
    });
    final stateSub =
        channel.stateChangeStream.listen((state) => streamStates.add(state));

    channel.eventListener(<String, dynamic>{
      'event': 'dataChannelStateChanged',
      'id': 1,
      'state': 'open',
    });
    channel.eventListener(<String, dynamic>{
      'event': 'dataChannelReceiveMessage',
      'id': 1,
      'type': 'text',
      'data': 'hello',
    });
    channel.eventListener(<String, dynamic>{
      'event': 'dataChannelBufferedAmountChange',
      'id': 1,
      'bufferedAmount': 5,
      'changedAmount': 2,
    });

    expect(channel.state, RTCDataChannelState.RTCDataChannelOpen);
    expect(callbackStates,
        <RTCDataChannelState>[RTCDataChannelState.RTCDataChannelOpen]);
    expect(streamStates,
        <RTCDataChannelState>[RTCDataChannelState.RTCDataChannelOpen]);
    expect(callbackMessages, <String>['hello']);
    expect(streamMessages, <String>['hello']);
    expect(bufferedChanges, <List<int>>[
      <int>[5, 2]
    ]);
    expect(lowBufferedAmounts, <int>[5]);

    await messageSub.cancel();
    await stateSub.cancel();
    await channel.close();
  });

  test('handles batched data channel events in order', () async {
    final channel = createChannel();

    final callbackMessages = <String>[];
    final streamMessages = <String>[];
    final callbackBinary = <Uint8List>[];
    final streamBinary = <Uint8List>[];

    channel.onMessage = (RTCDataChannelMessage message) {
      if (message.isBinary) {
        callbackBinary.add(message.binary);
      } else {
        callbackMessages.add(message.text);
      }
    };

    final messageSub =
        channel.messageStream.listen((RTCDataChannelMessage msg) {
      if (msg.isBinary) {
        streamBinary.add(msg.binary);
      } else {
        streamMessages.add(msg.text);
      }
    });

    channel.eventListener(<String, dynamic>{
      'event': 'dataChannelEventsBatch',
      'events': <Map<String, dynamic>>[
        <String, dynamic>{
          'event': 'dataChannelReceiveMessage',
          'id': 1,
          'type': 'text',
          'data': 'one',
        },
        <String, dynamic>{
          'event': 'dataChannelReceiveMessage',
          'id': 1,
          'type': 'binary',
          'data': Uint8List.fromList(<int>[1, 2, 3]),
        },
        <String, dynamic>{
          'event': 'dataChannelReceiveMessage',
          'id': 1,
          'type': 'text',
          'data': 'two',
        },
      ],
    });

    expect(callbackMessages, <String>['one', 'two']);
    expect(streamMessages, <String>['one', 'two']);
    expect(callbackBinary.single, Uint8List.fromList(<int>[1, 2, 3]));
    expect(streamBinary.single, Uint8List.fromList(<int>[1, 2, 3]));

    await messageSub.cancel();
    await channel.close();
  });

  test('ignores malformed event payloads safely', () async {
    final channel = createChannel();

    expect(() => channel.eventListener('bad-event'), returnsNormally);
    expect(
      () => channel.eventListener(<String, dynamic>{
        'event': 'dataChannelEventsBatch',
        'events': 'not-a-list',
      }),
      returnsNormally,
    );

    await channel.close();
  });
}
