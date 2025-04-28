import 'dart:convert';
import 'package:http/http.dart' as http;

class KategoriService {
  static const String baseUrl = "http://localhost:8000/api/resepmakanan"; // Pastikan URL betul

  // 🔍 Fungsi untuk mencari resep berdasarkan banyak kategori
  Future<List<Map<String, dynamic>>> searchRecipes(List<String> kategori) async {
    String kategoriQuery = kategori.join(',');
    final response = await http.get(Uri.parse("$baseUrl/search?kategori=$kategoriQuery"));

    if (response.statusCode == 200) {
      print("Response Body (searchRecipes): ${response.body}");

      try {
        final decodedResponse = jsonDecode(response.body);
        
        if (decodedResponse is List) {
          return List<Map<String, dynamic>>.from(decodedResponse);
        } else if (decodedResponse is Map<String, dynamic> && decodedResponse.containsKey('data')) {
          return List<Map<String, dynamic>>.from(decodedResponse['data']);
        } else {
          throw Exception("Format respons API tidak sesuai.");
        }
      } catch (e) {
        throw Exception("Gagal memproses JSON: $e");
      }
    } else {
      throw Exception("Gagal mengambil data resep. Kode status: ${response.statusCode}");
    }
  }

  // 🔥 Fungsi baru: Cari resep berdasarkan 1 kategori saja
  Future<List<Map<String, dynamic>>> getRecipesByKategori(String kategori) async {
    final response = await http.get(Uri.parse("$baseUrl/search?kategori=$kategori"));

    if (response.statusCode == 200) {
      print("Response Body (getRecipesByKategori): ${response.body}");

      try {
        final decodedResponse = jsonDecode(response.body);
        
        if (decodedResponse is List) {
          return List<Map<String, dynamic>>.from(decodedResponse);
        } else if (decodedResponse is Map<String, dynamic> && decodedResponse.containsKey('data')) {
          return List<Map<String, dynamic>>.from(decodedResponse['data']);
        } else {
          throw Exception("Format respons API tidak sesuai.");
        }
      } catch (e) {
        throw Exception("Gagal memproses JSON: $e");
      }
    } else {
      throw Exception("Gagal mengambil data resep. Kode status: ${response.statusCode}");
    }
  }
}
