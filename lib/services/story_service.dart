import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intermediete_1/utils/env.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/story.dart';

class StoryService {
  static String get _baseUrl => Env.baseUrl;

  static Future<List<Story>> fetchStories({int page = 1, int size = 10}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$_baseUrl/stories?page=$page&size=$size'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List storiesJson = data['listStory'];
      return storiesJson.map((json) => Story.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat cerita');
    }
  }

  static Future<bool> uploadStory({
    required String description,
    required File imageFile,
    double? latitude,
    double? longitude,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      if (kDebugMode) {
        print('Token tidak ditemukan');
      }
      return false;
    }

    final url = Uri.parse('$_baseUrl/stories');

    final request =
        http.MultipartRequest('POST', url)
          ..headers['Authorization'] = 'Bearer $token'
          ..fields['description'] = description;

    if (latitude != null) {
      request.fields['lat'] = latitude.toString();
    }
    if (longitude != null) {
      request.fields['lon'] = longitude.toString();
    }

    request.files.add(
      await http.MultipartFile.fromPath('photo', imageFile.path),
    );

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        if (kDebugMode) {
          print('Pesan berhasil: $responseBody');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('Upload gagal: ${response.statusCode}');
          print('Pesan error: $responseBody');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Terjadi error saat upload: $e');
      }
      return false;
    }
  }
}
