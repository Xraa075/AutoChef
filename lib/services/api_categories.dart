import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiCategories {
  static const String _baseUrl = "http://100.120.18.38:8080/api";
  // static const String _baseUrl = 'https://backend.autochef.site/api';

  static int _getCategoryId(String categoryName) {
    switch (categoryName) {
      case "Olahan Daging":
        return 1;
      case "Olahan Ayam":
        return 2;
      case "Makanan Laut":
        return 3;
      case "Menu Harian":
        return 4;
      case "Cemilan":
        return 5;
      default:
        return 1;
    }
  }

  static Future<List<dynamic>> fetchRecipesByCategory(String categoryName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final isLoggedIn = prefs.getBool('hasLoggedAsUser') ?? false;

      final categoryId = _getCategoryId(categoryName);
      final requestUrl = '$_baseUrl/categories/$categoryId/recipes';

      debugPrint('Fetching category recipes from: $requestUrl');

      final Map<String, String> headers = {'Accept': 'application/json'};

      if (isLoggedIn && token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(Uri.parse(requestUrl), headers: headers);

      debugPrint('Category response code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] as List<dynamic>;
      } else {
        throw Exception('Gagal memuat resep kategori');
      }
    } catch (e, stacktrace) {
      debugPrint('Exception in fetchRecipesByCategory: $e');
      debugPrint('Stacktrace: $stacktrace');
      throw Exception('Terjadi kesalahan saat memuat kategori: $e');
    }
  }
}