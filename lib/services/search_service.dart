import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:autochef/models/recipe.dart';

class SearchService {
  static Future<List<Recipe>> searchResep(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse("http://156.67.214.60/api/resepmakanan/search?nama_resep=$encodedQuery");

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'];

        if (data == null || data is! List) {
          throw Exception("Data tidak valid atau kosong.");
        }

        return data.map((json) => Recipe.fromJson(json)).toList();
      } else {
        throw Exception("Gagal mengambil data pencarian resep: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Terjadi kesalahan saat mencari resep: $e");
    }
  }
}
