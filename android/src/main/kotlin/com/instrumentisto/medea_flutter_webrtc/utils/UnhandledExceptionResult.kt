package com.instrumentisto.medea_flutter_webrtc.utils

import io.flutter.plugin.common.MethodChannel

/**
 * Calls [MethodChannel.Result.error] with the provided [Exception] and `UnhandledException`'s'
 * `errorCode.
 */
fun resultUnhandledException(result: MethodChannel.Result, e: Exception) {
  result.error("UnhandledException", "Unexpected Exception was thrown by flutter_webrtc Android", e)
}
