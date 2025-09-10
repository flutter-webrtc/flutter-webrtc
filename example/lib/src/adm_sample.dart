import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class AdmSample extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('ADM Sample'),
        ),
        body: ListView(
          children: [
            ListTile(
              title: Text('startLocalRecording'),
              onTap: () async {
                await NativeAudioManagement.startLocalRecording();
              },
            ),
            ListTile(
              title: Text('stopLocalRecording'),
              onTap: () async {
                await NativeAudioManagement.stopLocalRecording();
              },
            ),
            ListTile(
              title: Text('isVoiceProcessingEnabled'),
              onTap: () async {
                final result = await NativeAudioManagement.isVoiceProcessingEnabled();
                print('isVoiceProcessingEnabled: $result');
              },
            ),
            ListTile(
              title: Text('Get isVoiceProcessingBypassed'),
              onTap: () async {
                final result = await NativeAudioManagement.isVoiceProcessingBypassed();
                print('isVoiceProcessingBypassed: $result');
              },
            ),
            ListTile(
              title: Text('Toggle isVoiceProcessingBypassed'),
              onTap: () async {
                final result = await NativeAudioManagement.isVoiceProcessingBypassed();
                await NativeAudioManagement.setIsVoiceProcessingBypassed(!result);
                print('isVoiceProcessingBypassed: $result');
              },
            ),
          ],
        ),
      );
}
