import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import './SpeechToText.dart';
import 'dart:io';
import 'dart:convert';
import './blinkingButton.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  FlutterSound flutterSound = new FlutterSound();
  bool isRecording = false;
  String path = '';
  SpeechToText stt = SpeechToText();
  String transcript = 'Please record audio';

  Future<String> speechToText(String path) async {
    print("Read file");
    print(path);
    File audioFile = new File(path);
    print(audioFile);
    List<int> audioBytes = audioFile.readAsBytesSync();
    print(audioBytes);
    String audioBase64 = base64Encode(audioBytes);
    print(audioBase64);
    print("Audio file encoded");
    transcript = await stt.recognizeText(audioBase64);
    if (transcript == null) transcript = 'Nothing Recognized';
    print(transcript);
    return transcript;
  }


  // Record with flutter_sound package
  void recordFlutterSound() async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    path = tempPath;
    path = await flutterSound.startRecorder(null);
    print('startRecorder: $path');
  }

  Future<void> stopFlutterSoundRecording() async {
    String result = await flutterSound.stopRecorder();
    print('stopRecorder: $result');
  }

  void playRecord() async {
    path = await flutterSound.startPlayer(null);
    print('startPlayer: $path');
  }

  void recordButtonToggled() async {
    if (isRecording) {
      print("Stop recording");
      isRecording = false;
      //await stopRecorderWav();
      await stopFlutterSoundRecording();
      //print('Path: ${path}');
      String result = await speechToText(path);
      setState(() {
        transcript = result;
      });
    } else {
      print("Start recording");
      isRecording = true;
      //recordWav();
      recordFlutterSound();
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Speech to Text'),
        ),
        body: Center(
            child: Column(
          children: [
            isRecording
                ? BlinkingButton(recordButtonToggled)
                : RaisedButton(
                    child: Icon(
                      Icons.mic,
                    ),
                    onPressed: () {
                      setState(() {
                        recordButtonToggled();
                      });
                    },
                  ),
            Text(transcript),
            RaisedButton(
              child: Icon(Icons.play_circle_outline),
              onPressed: () {
                playRecord();
              },
            )
          ],
        )),
      ),
    );
  }
}
