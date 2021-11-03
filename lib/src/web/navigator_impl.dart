import '../interface/mediadevices.dart';
import '../interface/navigator.dart';
import 'mediadevices_impl.dart';

class NavigatorWeb extends Navigator {
  @override
  MediaDevices get mediaDevices => MediaDevicesWeb();
}
