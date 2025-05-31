import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://156.67.214.60/api/resepmakanan";

  // 🔍 Fungsi untuk mencari resep berdasarkan bahan
  Future<List<Map<String, dynamic>>> searchRecipes(List<String> bahan) async {
  String bahanQuery = bahan.join(',');

  final response = await http.get(Uri.parse("$baseUrl/search?bahan=$bahanQuery"));

    if (response.statusCode == 200) {
      // Tambahkan debug print

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