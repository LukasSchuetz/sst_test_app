import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import './SpeechToText.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_sound/android_encoder.dart';
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
  bool iconRecording = false;
  String path;
  SpeechToText stt = SpeechToText();
  String transcript = 'Please upload a audio file to STT service';

  void speechToText(String path) async {
    String encodedAudio = encodeAudioFile(path);
    transcript = await stt.recognizeText(encodedAudio);
    if (transcript == null) transcript = 'Nothing Recognized';
    print(transcript);
  }

  String encodeAudioFile(String filePath) {
    print("Read file");
    File audioFile = new File(filePath);
    List<int> audioBytes = audioFile.readAsBytesSync();
    String audioBase64 = base64Encode(audioBytes);
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

  void play() async {
    if (flutterSound.isRecording) {
      iconRecording = false;
      stopRecording();
    }

    path = await flutterSound.startPlayer(null);
    print('startPlayer: $path');

    _playerSubscription = flutterSound.onPlayerStateChanged.listen((e) {
      if (e != null) {
        DateTime date =
            new DateTime.fromMillisecondsSinceEpoch(e.currentPosition.toInt());
        String txt = 'mm:ss:SS';
      }
    });
  }

  void record() async {
    path = await flutterSound.startRecorder(path,
        sampleRate: 8000,
        numChannels: 1,
        androidEncoder: AndroidEncoder.AMR_WB);
    print('startRecorder: $path');

    _recorderSubscription = flutterSound.onRecorderStateChanged.listen((e) {
      DateTime date =
          new DateTime.fromMillisecondsSinceEpoch(e.currentPosition.toInt());
    });
  }

  void stopRecording() async {
    String result = await flutterSound.stopRecorder();
    print('stopRecorder: $result');

    if (_recorderSubscription != null) {
      _recorderSubscription.cancel();
      _recorderSubscription = null;
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
      body: Column(children: <Widget>[
        Row(
          children: <Widget>[
            RaisedButton(
              child: iconRecording
                  ? Icon(
                      Icons.mic,
                      color: Colors.red,
                    )
                  : Icon(
                      Icons.mic,
                      color: Colors.black,
                    ),
              onPressed: () {
                setState(() {
                  if (flutterSound.isRecording) {
                    stopRecording();
                    iconRecording = false;
                  } else
                    record();
                  iconRecording = true;
                });
              },
            ),
            RaisedButton(
              child: Icon(Icons.play_circle_outline),
              onPressed: () {
                play();
              },
            ),
            RaisedButton(
              child: Icon(Icons.cloud_upload),
              onPressed: () async {
                await speechToText(path);
                setState(() {});
              },
            ),
          ],
        ),
        Center(
          child: Text('Recognized text: ' + transcript),
        ),
      ]),
    ));
  }
}
