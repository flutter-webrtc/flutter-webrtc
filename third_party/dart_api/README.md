Headers copied unchanged from the Dart SDK (`dart-sdk/include`), Dart 3.13.3.
Only the `Dart_CObject` definitions from `dart_native_api.h` are used, to post
data channel events to Dart through `NativeApi.postCObject`. `dart_api_dl.c` is
deliberately not bundled, so the plugin cannot clash with other plugins that
link their own copy.
