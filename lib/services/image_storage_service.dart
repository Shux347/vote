import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ImageStorageService {
  final String _databaseUrl = dotenv.env['DATABASE_URL'];

  Future<void> saveImage(int userId, String imagePath) async {
    final imageBytes = File(imagePath).readAsBytesSync();
    final base64Image = base64Encode(imageBytes);

    final response = await http.post(
      Uri.parse('$_databaseUrl/saveImage'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'image': base64Image}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save image');
    }
  }

  Future<String> getImage(int userId) async {
    final response = await http.get(Uri.parse('$_databaseUrl/getImage/$userId'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['image'];
    } else {
      throw Exception('Failed to load image');
    }
  }
}