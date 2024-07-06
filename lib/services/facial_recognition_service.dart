import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FacialRecognitionService {
  final String _subscriptionKey = dotenv.env['AZURE_FACE_API_KEY']!;
  final String _endpoint = dotenv.env['AZURE_FACE_API_ENDPOINT']!;

  Future<String> detectFaces(String imagePath) async {
    final imageBytes = File(imagePath).readAsBytesSync();
    final uri = Uri.parse('$_endpoint/face/v1.0/detect');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/octet-stream',
        'Ocp-Apim-Subscription-Key': _subscriptionKey,
      },
      body: imageBytes,
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody.isNotEmpty ? responseBody[0]['faceId'] : null;
    } else {
      throw Exception('Failed to detect face: ${response.reasonPhrase}');
    }
  }

  Future<bool> compareFaces(String faceId1, String faceId2) async {
    final uri = Uri.parse('$_endpoint/face/v1.0/verify');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Ocp-Apim-Subscription-Key': _subscriptionKey,
      },
      body: jsonEncode({
        'faceId1': faceId1,
        'faceId2': faceId2,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody['isIdentical'];
    } else {
      throw Exception('Failed to compare faces: ${response.reasonPhrase}');
    }
  }
}