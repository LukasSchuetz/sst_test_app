import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import './SpeechToText.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_sound/android_encoder.dart';
import 'package:recorder_wav/recorder_wav.dart';
import './blinkingButton.dart';

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
  var _recorderSubscription;
  var _playerSubscription;
  bool isRecording = false;
  String path = '';
  SpeechToText stt = SpeechToText();
  String transcript = 'Please record audio';

  Future<String> speechToText(String path) async {
    String encodedAudio = encodeAudioFile(path);
    String transcript = await stt.recognizeText(encodedAudio);
    if (transcript == null) transcript = 'Nothing Recognized';
    print('transcript: ${transcript}');
    return transcript;
  }

  String encodeAudioFile(String filePath) {
    print("Read file");
    File audioFile = new File(filePath);
    List<int> audioBytes = audioFile.readAsBytesSync();
    String audioBase64 = base64Encode(audioBytes);
    print("Base64: " + audioBase64);
    print("Audio file encoded");
    return audioBase64;
  }

  void speechToTextScreen(String path) async {
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
  }

  void recordWav() {
    RecorderWav.startRecorder();
  }



  void stopRecorderWav() async {
    path = await RecorderWav.StopRecorder();
  }

  void recordButtonToggled() async {
    if (isRecording) {
      print("Stop recording");
      isRecording = false;
      await stopRecorderWav();
      print('Path: ${path}');
      String result = await speechToText(path);
      setState(() {
        transcript = result;
      });
    } else {
      print("Start recording");
      isRecording = true;
      recordWav();
    }
  }

  void playAudioFile() async {
    await flutterSound.startPlayer(path);
    print('startPlayer: $path');

    _playerSubscription = flutterSound.onPlayerStateChanged.listen((e) {});
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
                playAudioFile();
              },
            )
          ],
        )),
      ),
    );
  }
}
