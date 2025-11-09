import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:autochef/models/recipe_detail_model.dart';

class ApiRekomendasi {
  static const String _baseUrl = "https://backend.autochef.site/api";

  static Future<List<Recipe>> fetchRekomendasi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final isLoggedIn = prefs.getBool('hasLoggedAsUser') ?? false;

      final requestUrl = '$_baseUrl/recipes/recommendations';

      debugPrint('Fetching recommendations from: $requestUrl');
      debugPrint('User logged in: $isLoggedIn');

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

        final List<Recipe> recipes = resepList
            .map((json) => Recipe.fromJson(json as Map<String, dynamic>))
            .toList();

        return recipes;
      } else {
        debugPrint('Error response: ${response.body}');
        throw Exception(
          'Gagal memuat data rekomendasi: ${response.statusCode}',
        );
      }
    } catch (e, stacktrace) {
      debugPrint('Exception in fetchRekomendasi: $e');
      debugPrint('Stacktrace: $stacktrace');
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  static Future<RecipeDetail> fetchRecipeDetail(int recipeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final isLoggedIn = prefs.getBool('hasLoggedAsUser') ?? false;

      final requestUrl = '$_baseUrl/recipes/$recipeId';
      debugPrint('Fetching recipe detail from: $requestUrl');

      final Map<String, String> headers = {'Accept': 'application/json'};

      if (isLoggedIn && token != null) {
        headers['Authorization'] = 'Bearer $token';
        debugPrint('Using auth token for recipe detail');
      }

      final response = await http.get(Uri.parse(requestUrl), headers: headers);
      debugPrint('Recipe Detail response code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return RecipeDetail.fromJson(data['data'] as Map<String, dynamic>);
      } else {
        debugPrint('Error response detail: ${response.body}');
        throw Exception(
          'Gagal memuat detail resep: ${response.statusCode}',
        );
      }
    } catch (e, stacktrace) {
      debugPrint('Exception in fetchRecipeDetail: $e');
      debugPrint('Stacktrace: $stacktrace');
      throw Exception('Terjadi kesalahan saat mengambil detail: $e');
    }
  }

  static Future<void> logRecipeView(int recipeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final isLoggedIn = prefs.getBool('hasLoggedAsUser') ?? false;

      if (!isLoggedIn || token == null) {
        return;
      }

      final url = Uri.parse('http://20.6.107.2:8002/api/resepmakanan/log-view');

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
      debugPrint('Error logging recipe view: $e');
    }
  }
}