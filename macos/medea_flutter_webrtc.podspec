#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint medea_flutter_webrtc.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'medea_flutter_webrtc'
  s.version          = '0.12.0'
  s.summary          = 'Flutter WebRTC plugin based on Google WebRTC'
  s.description      = <<-DESC
Flutter WebRTC plugin based on Google WebRTC.
                       DESC
  s.homepage         = 'https://github.com/instrumentisto/medea-flutter-webrtc'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Instrumentisto Team' => 'developer@instrumentisto.com' }

  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'

  s.osx.deployment_target = '10.11'
  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.static_framework = true
  s.vendored_libraries = 'rust/lib/*.dylib'
end
