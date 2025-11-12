import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:autochef/models/recipe.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchService {
  static Future<List<Recipe>> searchResep(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse("https://backend.autochef.site/api/recipes?search=$encodedQuery");

    debugPrint('Mencari resep (GET) ke: $url');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final isLoggedIn = prefs.getBool('hasLoggedAsUser') ?? false;

    final Map<String, String> headers = {
      'Accept': 'application/json',
    };

    if (isLoggedIn && token != null) {
      headers['Authorization'] = 'Bearer $token';
      debugPrint('Menggunakan auth token untuk pencarian');
    }

    try {
      final response = await http.get(
        url,
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      debugPrint('Search response code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'];

        if (data == null || data is! List) {
          throw Exception("Data tidak valid atau kosong.");
        }

        return data
            .map((json) => Recipe.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
            "Gagal mengambil data pencarian resep");
      }
    } catch (e) {
      debugPrint("Error di searchResep: $e");
      throw Exception("Terjadi kesalahan saat mencari resep: $e");
    }
  }
}
