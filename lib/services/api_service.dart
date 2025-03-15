import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/api/resepmakanan";

  // 🔍 Fungsi untuk mencari resep berdasarkan bahan
  Future<List<Map<String, dynamic>>> searchRecipes(List<String> bahan) async {
    String bahanQuery = bahan.join(',');

    final response = await http.get(Uri.parse("$baseUrl/search?bahan=$bahanQuery"));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      
      // Pastikan 'data' ada dalam respons
      if (jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
        return List<Map<String, dynamic>>.from(jsonResponse['data']);
      } else {
        throw Exception("Format respons API tidak sesuai.");
      }
    } else {
      throw Exception("Gagal mengambil data resep. Kode status: ${response.statusCode}");
    }
  }
}
