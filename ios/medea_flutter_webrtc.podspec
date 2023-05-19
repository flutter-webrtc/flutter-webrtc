#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint medea_flutter_webrtc.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'medea_flutter_webrtc'
  s.version          = '0.8.0'
  s.summary          = 'Flutter WebRTC plugin based on Google WebRTC'
  s.description      = <<-DESC
Flutter WebRTC plugin based on Google WebRTC.
                       DESC
  s.homepage         = 'https://github.com/instrumentisto/flutter-webrtc'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Instrumentisto Team' => 'developer@instrumentisto.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'instrumentisto-libwebrtc-bin', '108.0.5359.124'
  s.dependency 'libyuv-iOS'
  s.platform         = :ios, '13.0'
  s.static_framework = true

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
