import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiRekomendasi {
  static const String baseUrl =
      'http://156.67.214.60/api/resepmakanan/rekomendasi';

  static Future<List<Recipe>> fetchRekomendasi() async {
    try {
      // Get the user's token for personalized recommendations
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final isLoggedIn = prefs.getBool('hasLoggedAsUser') ?? false;

      // PERBAIKAN: Gunakan URL yang sama, backend sudah menghandle personalisasi
      // berdasarkan token tanpa perlu endpoint berbeda
      final requestUrl = baseUrl;

      debugPrint('Fetching recommendations from: $requestUrl');
      debugPrint('User logged in: $isLoggedIn');

      // Add auth token if logged in
      final Map<String, String> headers = {'Accept': 'application/json'};

      if (isLoggedIn && token != null) {
        headers['Authorization'] = 'Bearer $token';
        debugPrint('Using auth token for recommendations');
      }

      final response = await http.get(Uri.parse(requestUrl), headers: headers);

      debugPrint('Recommendation response code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint(
          'Recommendation response: ${response.body.substring(0, min(300, response.body.length))}...',
        );

        final List<dynamic> resepList = data['data'];
        debugPrint('Found ${resepList.length} recommendations');

        return resepList.map((json) => Recipe.fromJson(json)).toList();
      } else {
        debugPrint('Error response: ${response.body}');
        throw Exception(
          'Gagal memuat data rekomendasi: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Exception in fetchRekomendasi: $e');
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Add new method to log recipe views
  static Future<void> logRecipeView(int recipeId) async {
    try {
      // Check if user is logged in
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final isLoggedIn = prefs.getBool('hasLoggedAsUser') ?? false;

      // Only log if user is logged in
      if (!isLoggedIn || token == null) {
        return;
      }

      // Endpoint for logging recipe views
      final url = Uri.parse('http://156.67.214.60/api/resepmakanan/log-view');

      final response = await http
          .post(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'recipe_id': recipeId}),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint('Failed to log recipe view. Status: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
      }
    } catch (e) {
      // Silently fail - logging should not affect user experience
      debugPrint('Error logging recipe view: $e');
    }
  }
}
