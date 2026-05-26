#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_webrtc'
  s.version          = '1.4.0'
  s.summary          = 'Flutter WebRTC plugin for macOS.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'https://github.com/cloudwebrtc/flutter-webrtc'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'CloudWebRTC' => 'duanweiwei1982@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'flutter_webrtc/Sources/flutter_webrtc/**/*.{h,m}'
  s.public_header_files = 'flutter_webrtc/Sources/flutter_webrtc/include/flutter_webrtc/**/*.h'

  s.dependency 'FlutterMacOS'
  s.weak_frameworks = 'ScreenCaptureKit'
  s.dependency 'WebRTC-SDK', '144.7559.04'
  s.osx.deployment_target = '10.15'
  s.pod_target_xcconfig = {
    'USER_HEADER_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}/flutter_webrtc/Sources/flutter_webrtc/include/flutter_webrtc"'
  }
end
