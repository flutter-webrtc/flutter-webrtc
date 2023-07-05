import 'package:flutter/foundation.dart';

enum AdapterType {
  adapterTypeUnknown,
  adapterTypeEthernet,
  adapterTypeWifi,
  adapterTypeCellular,
  adapterTypeVpn,
  adapterTypeLoopback,
  adapterTypeAny
}

extension AdapterTypeExt on AdapterType {
  String get value => describeEnum(this);
}