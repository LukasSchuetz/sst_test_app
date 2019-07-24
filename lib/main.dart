import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import './SpeechToText.dart';
import 'dart:io';
import 'dart:convert';
import 'package:recorder_wav/recorder_wav.dart';
import './blinkingButton.dart';
import 'package:audio_recorder/audio_recorder.dart';
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
  Recording recording;

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
    final dir = Directory(path);
    dir.deleteSync(recursive: true);

    return transcript;
  }

  // Alternative with record_wav package. Works only with Android
  void recordWav() {
    RecorderWav.startRecorder();
  }


  void recordAudioRecorder() async {
    bool hasPermissions = await AudioRecorder.hasPermissions;
    if(hasPermissions) {
      print ("Has permissions to record");
    } else {
      print ("Error: Does not have permission to record");
    }
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    path = tempPath + "/audio5.wav";
    print(path);
    await AudioRecorder.start(path: path,audioOutputFormat: AudioOutputFormat.WAV);
  }

  /*
  void stopRecorderWav() async {
    path = await RecorderWav.StopRecorder();
  }
  */

  Future<void> stopAudioRecorder() async {
    recording = await AudioRecorder.stop();
    print("Path : ${recording.path},  Format : ${recording.audioOutputFormat},  Duration : ${recording.duration},  Extension : ${recording.extension},");
    path = recording.path;
  }

  void recordButtonToggled() async {
    if (isRecording) {
      print("Stop recording");
      isRecording = false;
      //await stopRecorderWav();
      await stopAudioRecorder();
      //print('Path: ${path}');
      String result = await speechToText(path);
      setState(() {
        transcript = result;
      });
    } else {
      print("Start recording");
      isRecording = true;
      //recordWav();
      recordAudioRecorder();
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
              },
            )
          ],
        )),
      ),
    );
  }
}
