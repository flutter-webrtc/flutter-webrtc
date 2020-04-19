Map<String, dynamic> connectionConfiguration = {
  "iceServers": [
    {"url": "stun:stun.l.google.com:19302"},
    {
      "urls": [
        "turn:209.85.235.127:19305?transport=udp",
        "turn:[2607:f8b0:4003:c19::7f]:19305?transport=udp",
        "turn:209.85.235.127:19305?transport=tcp",
        "turn:[2607:f8b0:4003:c19::7f]:19305?transport=tcp"
      ],
      "username": "CPKu8vQFEgZTECXgsNYYzc/s6OMTIICjBQ",
      "credential": "t/+udhmnS2wR3bJutk0A54Ufuxo=",
      "maxRateKbps": "8000"
    }
  ]
};
