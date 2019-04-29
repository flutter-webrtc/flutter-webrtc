## Changelog
--------------------------------------------
[0.1.6] - 2019.01.31

* Add getConfiguration/setConfiguration methods for Peerconnection.
* Add object fit for RTCVideoView.

[0.1.5] - 2019.03.27

* Remove unnecessary parameter for getLocalDescription method.

[0.1.4] - 2019.03.26

* switchCamera method now returns future with isFrontCamera as result
* Fix camera stuck in rare cases
* Add getLocalDescription/getRemoteDescription methods

[0.1.3] - 2019.03.25

* Add horizontal flip (mirror) function for RTCVideoView.
* Fixed ScreenCapture preview aspect ratio for Android.

[0.1.2] - 2019.03.24

* Fix compilation failure caused by invalid code.

[0.1.1] - 2019.03.24

* Migrated to AndroidX using Refactoring from Andoid Studio
* Fix mediaStreamTrackSetEnable not working.
* Fix iOS can't render video when resolution changes.
* Some code style changes.

[0.1.0] - 2019.01.21

* Fix camera switch issues.
* Support data channel, please use the latest demo to test.
* Support screen sharing, but the work is not perfect, there is a problem with the local preview.

[0.0.3] - 2018.12.20

* Update WebRTC to 1.0.25821.
* Implemented MediaStreamTrack.setVolume().
* Add public getter for texture id.
* Fixed getUserMedia does not work for capturing audio only.

[0.0.2] - 2018.11.04

* Add 'enabled' method for MediaStreamTrack.
* Implement switch camera.
* Add arm64-v8a and x86_64 architecture support for android.

[0.0.1] - 2018.05.30

* Initial release.
