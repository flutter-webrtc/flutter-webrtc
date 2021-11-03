import '../interface/mediadevices.dart';
import '../interface/navigator.dart';
import 'mediadevices_impl.dart';

class NavigatorNative extends Navigator {
  @override
  MediaDevices get mediaDevices => MediaDeviceNative();
}
