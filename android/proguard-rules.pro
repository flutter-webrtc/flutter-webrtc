# Flutter WebRTC
-keep class com.cloudwebrtc.webrtc.** { *; }
-keep class org.webrtc.** { *; }
-keep class org.jni_zero.** { *; }

# org.jni_zero.JniZero references the code-generated org.jni_zero.JniZeroJni,
# which libwebrtc.aar does not ship (natives are registered from the .so
# instead). Nothing in WebRTC calls the one method that would touch it,
# JniZero.setJniClassLoader, so the dangling reference is unreachable.
-dontwarn org.jni_zero.JniZeroJni
