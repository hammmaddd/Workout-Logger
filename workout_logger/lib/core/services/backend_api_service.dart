import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/detected_food_item_model.dart';

class BackendApiService {
  static const String _defaultBaseUrl = 'http://192.168.1.8:5000/api/v1';
  static const String _prefsKey = 'backend_base_url';

  static String _baseUrl = _defaultBaseUrl;

  static String get baseUrl => _baseUrl;

  static Future<void> loadSavedUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved != null && saved.trim().isNotEmpty) {
      _baseUrl = saved.trim();
    }
  }

  /// Accepts either "192.168.1.20:5000" or a full URL — normalizes either way.
  static Future<void> updateBaseUrl(String input) async {
    String url = input.trim();
    if (url.isEmpty) return;

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
    }
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    if (!url.endsWith('/api/v1')) {
      url = '$url/api/v1';
    }

    _baseUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, url);
  }

  static Future<void> resetToDefault() async {
    _baseUrl = _defaultBaseUrl;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  Future<void> syncProfile({required String idToken, String? email, String? displayName}) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/firebase/sync-profile'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
          body: jsonEncode({'email': email, 'displayName': displayName}),
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Backend sync failed (${response.statusCode})');
    }
  }

  Future<List<DetectedFoodItemModel>> analyzeFoodPhoto({
    required String idToken,
    required String imageBase64,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/nutrition/analyze-photo'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
          body: jsonEncode({'imageBase64': imageBase64, 'mimeType': 'image/jpeg'}),
        )
        .timeout(const Duration(seconds: 75));

    Map<String, dynamic>? decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      decoded = null;
    }

    if (response.statusCode != 200 || decoded == null || decoded['success'] != true) {
      final message = (decoded != null && decoded['message'] is String)
          ? decoded['message'] as String
          : 'Analysis failed (${response.statusCode})';
      throw Exception(message);
    }

    final rawItems = decoded['data']['items'] as List<dynamic>? ?? [];
    return rawItems.map((e) => DetectedFoodItemModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<String> sendCoachMessage({
    required String idToken,
    required List<Map<String, dynamic>> messages,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/coach/chat'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
          body: jsonEncode({'messages': messages}),
        )
        .timeout(const Duration(seconds: 40));

    Map<String, dynamic>? decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      decoded = null;
    }

    if (response.statusCode != 200 || decoded == null || decoded['success'] != true) {
      final message = (decoded != null && decoded['message'] is String)
          ? decoded['message'] as String
          : 'Coach Glow is unavailable right now (${response.statusCode})';
      throw Exception(message);
    }

    return decoded['data']['reply'] as String;
  }
}