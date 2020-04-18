import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map> getTurnCredential(String host, int port) async {
  var url = 'https://$host:$port/api/turn?service=turn&username=flutter-webrtc';
    final res = await http.get(url);
    if (res.statusCode == 200) {
      var data = json.decode(res.body);
      print('getTurnCredential:response => $data.');
      return data;
    }
    return {};
  }