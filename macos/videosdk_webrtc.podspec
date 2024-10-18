#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'videosdk_webrtc'
  s.version          = '0.0.4'
  s.summary          = 'Flutter WebRTC plugin for macOS.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'https://www.videosdk.live'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'VideoSDK' => 'sdk@videosdk.live' }
  s.source           = { :path => '.' }
  s.source_files     = ['Classes/**/*']

  s.dependency 'FlutterMacOS'
  s.dependency 'WebRTC-SDK', '114.5735.09'
  s.osx.deployment_target = '10.13'
end
