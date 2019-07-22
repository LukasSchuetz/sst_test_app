import 'dart:io';
import 'dart:async';
import 'dart:convert' show json, utf8;

class SpeechToText {

  static final SpeechToText _singleton = SpeechToText._internal();
  final _httpClient = HttpClient();
  static const _apiKey = "AIzaSyAU-ZG_xaKyI20UGNbYEffwG9s4X_O_PRg";
  static const _apiURL = "speech.googleapis.com";

  factory SpeechToText() {
    return _singleton;
  }

  SpeechToText._internal();

  Future<String> recognizeText(String audioContent) async {

    try {
      //final uri = Uri.https(_apiURL, '/v1p1beta1/speech:longrunningrecognize');
      final uri = Uri.https(_apiURL, '/v1/speech:recognize');
      final Map json = {
        "config": {
          //"encoding": "AMR",
          "encoding": "ENCODING_UNSPECIFIED",
          "sampleRateHertz": 16000,
          "enableSeparateRecognitionPerChannel": false,
          "languageCode": "de-DE",
        },
        "audio": {
          "content": audioContent.toString(),
          //"uri":"gs://cloud-samples-tests/speech/brooklyn.flac"
        }
      };
      final jsonResponse = await _postJson(uri, json);
      if (jsonResponse == null) return null;
      print(jsonResponse);
      String transcript = '';
      try {
        transcript = jsonResponse['results'][0]['alternatives'][0]['transcript'];
      } on Error {
        transcript = 'Nothing recognized';
      }
      return transcript;

      //return audioContent;
    } on Exception catch(e) {
      print("$e");
      return null;
    }
  }

  Future<Map<String, dynamic>> _postJson(Uri uri, Map jsonMap) async {
    try {
      final httpRequest = await _httpClient.postUrl(uri);
      final jsonData = utf8.encode(json.encode(jsonMap));
      final jsonResponse = await _processRequestIntoJsonResponse(httpRequest, jsonData);
      return jsonResponse;
    } on Exception catch(e) {
      print("$e");
      return null;
    }
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    try {
      final httpRequest = await _httpClient.getUrl(uri);
      final jsonResponse = await _processRequestIntoJsonResponse(httpRequest, null);
      return jsonResponse;
    } on Exception catch(e) {
      print("$e");
      return null;
    }
  }

  Future<Map<String, dynamic>> _processRequestIntoJsonResponse(HttpClientRequest httpRequest, List<int> data) async {
    try {
      httpRequest.headers.add('X-Goog-Api-Key', _apiKey);
      httpRequest.headers.add(HttpHeaders.CONTENT_TYPE, 'application/json');
      if (data != null) {
        httpRequest.add(data);
      }
      final httpResponse = await httpRequest.close();
      if (httpResponse.statusCode != HttpStatus.OK) {
        final responseBody = await httpResponse.transform(utf8.decoder).join();
        print(json.decode(responseBody));
        throw Exception('Bad Response');
      }
      final responseBody = await httpResponse.transform(utf8.decoder).join();
      return json.decode(responseBody);
    } on Exception catch(e) {
      print("$e");
      return null;
    }
  }

}
