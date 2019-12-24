#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_webrtc'
  s.version          = '0.2.2'
  s.summary          = 'Flutter WebRTC plugin for macOS.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'https://github.com/cloudwebrtc/flutter-webrtc'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'CloudWebRTC' => 'duanweiwei1982@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files     = ['Classes/**/*']

  s.vendored_frameworks = 'WebRTC.framework'
  s.private_header_files = 'third_party/include/**/*'
  $dir = File.dirname(__FILE__) + "/third_party/include"
  s.pod_target_xcconfig = { "HEADER_SEARCH_PATHS" => $dir}
  s.vendored_libraries = 'third_party/lib/*.a'

  s.dependency 'FlutterMacOS'
  s.platform = :osx
  s.osx.deployment_target = '10.11'
end
