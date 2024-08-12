import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:medea_flutter_webrtc/medea_flutter_webrtc.dart';

class VideoCodecInfoSample extends StatefulWidget {
  const VideoCodecInfoSample({super.key});

  @override
  State<VideoCodecInfoSample> createState() => _State();
}

class _State extends State<VideoCodecInfoSample> {
  String text = '';

  @override
  void initState() {
    super.initState();

    _renderState();
  }

  void _renderState() async {
    var senderCaps = await RtpSender.getCapabilities(MediaKind.video);
    var encoders = await PeerConnection.videoEncoders();
    var decoders = await PeerConnection.videoDecoders();

    setState(() {
      var codecs = '';
      for (var enc in encoders) {
        codecs += 'Encoder: ${enc.codec} HW: ${enc.isHardwareAccelerated}\n';
      }
      codecs += '\n';
      for (var dec in decoders) {
        codecs += 'Decoder: ${dec.codec} HW: ${dec.isHardwareAccelerated}\n';
      }

      codecs += '\n';
      for (var c in senderCaps.codecs) {
        codecs += 'Sender Codec: ${c.kind} ${c.name} ${c.mimeType} '
            '${json.encode(c.parameters)}\n';
      }

      text = codecs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Codecs Info'),
      ),
      body: Center(child: Text(text)),
    );
  }
}
