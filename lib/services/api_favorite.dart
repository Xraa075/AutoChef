import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiFavorite {
  static const String _baseUrl = 'http://100.120.18.38:8080/api';
  // static const String _baseUrl = 'https://backend.autochef.site/api';

  // Get All Favorites
  static Future<List<dynamic>> getAllFavorites(String token) async {
    List<dynamic> allData = [];
    String? nextUrl = '$_baseUrl/favorites';

    try {
      while (nextUrl != null) {
        final response = await http.get(
          Uri.parse(nextUrl!),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
            final List<dynamic> pageData = responseData['data'];
            allData.addAll(pageData);
            
            if (responseData.containsKey('links') && 
                responseData['links'] is Map && 
                responseData['links']['next'] != null) {
              
              nextUrl = responseData['links']['next'];
            
            } else {
              nextUrl = null;
            }
          } 
          else if (responseData is List) {
            return responseData; 
          } else {
            nextUrl = null;
          }
        } else {
          throw Exception('Gagal memuat halaman');
        }
      }
      
      return allData;

    } catch (e) {
      if (allData.isNotEmpty) return allData;
      throw Exception('Gagal memuat data favorites');
    }
  }

  static Future<bool> checkStatus({
    required int recipeId,
    required String token,
  }) async {
    try {
      final List<dynamic> allFavorites = await getAllFavorites(token);
      for (var item in allFavorites) {
        if (item is Map<String, dynamic>) {
          if (item['id'] == recipeId) return true;
          if (item['recipe_id'] == recipeId) return true;
          if (item['recipe'] != null && item['recipe']['id'] == recipeId) return true;
        } 
        else if (item == recipeId) {
          return true;
        }
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  static Future<Map<String, dynamic>> toggle({
    required int recipeId,
    required String token,
    required bool isCurrentlyFavorite,
  }) async {
    final url = Uri.parse('$_baseUrl/recipes/$recipeId/favorites');
  
    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      final result = <String, dynamic>{
        'success': false,
        'message': '',
      };
      if (response.statusCode >= 200 && response.statusCode < 300) {
        result['success'] = true;
        result['message'] = ""; 
      } else {
        result['message'] = "Gagal mengubah status favorite.";
        try {
          final responseData = jsonDecode(response.body);
          if (responseData is Map<String, dynamic> &&
              responseData.containsKey('message')) {
            result['message'] = responseData['message'];
          }
        } catch (_) {}
      }
      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi.',
      };
    }
  }
}