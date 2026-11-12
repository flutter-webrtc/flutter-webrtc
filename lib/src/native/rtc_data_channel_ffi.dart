import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';

import 'utils.dart';

typedef _InitializeNative = Void Function(Pointer<Void> postCObject);
typedef _Initialize = void Function(Pointer<Void> postCObject);
typedef _AttachNative = Int32 Function(Int64 handle, Int64 port);
typedef _Attach = int Function(int handle, int port);
typedef _DetachNative = Void Function(Int64 handle);
typedef _Detach = void Function(int handle);
typedef _SendNative = Int32 Function(
    Int64 handle, Pointer<Uint8> data, Int64 length, Int32 binary);
typedef _Send = int Function(
    int handle, Pointer<Uint8> data, int length, int binary);
typedef _BufferedAmountNative = Int64 Function(Int64 handle);
typedef _BufferedAmount = int Function(int handle);
typedef _AllocNative = Pointer<Uint8> Function(Int64 size);
typedef _Alloc = Pointer<Uint8> Function(int size);
typedef _FreeNative = Void Function(Pointer<Uint8> pointer);
typedef _Free = void Function(Pointer<Uint8> pointer);

/// Event kinds posted by the native side, as the first element of each
/// message. Messages are lists: `[kind, id, ...]`.
///
/// * [kStateChanged]: `[kind, id, stateCode]`, with stateCode 0..3 in
///   [RTCDataChannelState] order (connecting, open, closing, closed).
/// * [kMessage]: `[kind, id, isBinary, Uint8List payload]`.
/// * [kBufferedAmount]: `[kind, id, bufferedAmount, changedAmount]`.
class DataChannelFfiEvent {
  static const kStateChanged = 0;
  static const kMessage = 1;
  static const kBufferedAmount = 2;
}

/// Sends and receives data channel payloads through FFI instead of the
/// method and event channels.
///
/// The platform hands out the addresses of its entry points through a single
/// `dataChannelFfiFunctions` call, so no symbol lookup is needed and stripped
/// release builds work. Events come back through `NativeApi.postCObject`.
/// Platforms without the entry points make [load] return null, and callers
/// keep using the channels.
class DataChannelFfi {
  DataChannelFfi._(Map<dynamic, dynamic> table)
      : _attach = _lookup<_AttachNative>(table, 'attach').asFunction<_Attach>(),
        _detach = _lookup<_DetachNative>(table, 'detach').asFunction<_Detach>(),
        _send = _lookup<_SendNative>(table, 'send').asFunction<_Send>(),
        _bufferedAmount =
            _lookup<_BufferedAmountNative>(table, 'bufferedAmount')
                .asFunction<_BufferedAmount>(),
        _alloc = _lookup<_AllocNative>(table, 'alloc').asFunction<_Alloc>(),
        _free = _lookup<_FreeNative>(table, 'free').asFunction<_Free>() {
    _lookup<_InitializeNative>(table, 'initialize')
        .asFunction<_Initialize>()(NativeApi.postCObject.cast());
  }

  static const _version = 1;

  static Future<DataChannelFfi?>? _loading;

  /// Set to false before creating data channels to keep them on the method
  /// and event channels, for example to compare the two transports.
  static bool enabled = true;

  /// The loaded instance, or null while [load] has not completed or when the
  /// platform does not support FFI.
  static DataChannelFfi? instance;

  /// Whether [load] has completed, whatever its outcome.
  static bool loaded = false;

  final _Attach _attach;
  final _Detach _detach;
  final _Send _send;
  final _BufferedAmount _bufferedAmount;
  final _Alloc _alloc;
  final _Free _free;

  // Reused for every send. Sends are synchronous and Dart is single
  // threaded per isolate, so one buffer is enough.
  Pointer<Uint8> _scratch = nullptr;
  int _scratchSize = 0;

  static Pointer<NativeFunction<T>> _lookup<T extends Function>(
          Map<dynamic, dynamic> table, String name) =>
      Pointer<NativeFunction<T>>.fromAddress(table[name] as int);

  static Future<DataChannelFfi?> load() => _loading ??= _load();

  static Future<DataChannelFfi?> _load() async {
    try {
      final table = await WebRTC.invokeMethod<Map<dynamic, dynamic>, dynamic>(
          'dataChannelFfiFunctions');
      if (table != null && table['version'] == _version) {
        instance = DataChannelFfi._(table);
      }
    } catch (_) {
      // Not implemented on this platform: stay on the channels.
    }
    loaded = true;
    return instance;
  }

  /// Routes the channel's events to [port]. Returns false when the native
  /// channel is gone.
  bool attach(int handle, SendPort port) =>
      _attach(handle, port.nativePort) != 0;

  /// Stops event delivery for the channel; events still in flight are dropped.
  void detach(int handle) => _detach(handle);

  /// Returns 1 when sent, 0 when the channel refused the data, -1 when the
  /// native channel is gone.
  int send(int handle, Uint8List data, bool binary) {
    if (data.length > _scratchSize) {
      if (_scratch != nullptr) _free(_scratch);
      _scratchSize = data.length < 4096 ? 4096 : data.length;
      _scratch = _alloc(_scratchSize);
    }
    _scratch.asTypedList(data.length).setAll(0, data);
    return _send(handle, _scratch, data.length, binary ? 1 : 0);
  }

  /// Returns -1 when the native channel is gone.
  int bufferedAmount(int handle) => _bufferedAmount(handle);
}
