class MediaConstraints {
  MediaConstraints({this.mandatory, this.optional});
  final List<KeyValuePair> mandatory;
  final List<KeyValuePair> optional;
}

class KeyValuePair {
  KeyValuePair({this.key, this.value});
  final String key;
  final String value;
}
