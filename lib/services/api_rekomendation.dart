import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class ApiRekomendasi {
  static const String baseUrl = 'http://156.67.214.60/api/resepmakanan/rekomendasi';

  static Future<List<Recipe>> fetchRekomendasi() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> resepList = data['data'];

        return resepList.map((json) => Recipe.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat data rekomendasi');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}
