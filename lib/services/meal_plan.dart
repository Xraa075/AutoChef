// (MODIFIKASI) meal_plan.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:autochef/models/recipe.dart';

// --- Model untuk Summary (Sudah Benar) ---
class WeeklyIngredient {
  final int idBahan;
  final String namaBahan;
  final IngredientDetail detailBahan;

  WeeklyIngredient({
    required this.idBahan,
    required this.namaBahan,
    required this.detailBahan,
  });

  factory WeeklyIngredient.fromJson(Map<String, dynamic> json) {
    return WeeklyIngredient(
      idBahan: json["id_bahan"],
      namaBahan: json["nama_bahan"],
      detailBahan: IngredientDetail.fromJson(json["detail_bahan"]),
    );
  }
}

class IngredientDetail {
  final num jumlah;
  final String satuan;
  final String? catatan;

  IngredientDetail({
    required this.jumlah,
    required this.satuan,
    this.catatan,
  });

  factory IngredientDetail.fromJson(Map<String, dynamic> json) {
    return IngredientDetail(
      jumlah: json["jumlah"],
      satuan: json["satuan"],
      catatan: json["catatan"],
    );
  }
}
// --- Akhir Model Summary ---

class MealPlanService {
  static const String _baseUrl = "https://backend.autochef.site/api";

  // (FUNGSI INI DIPERBAIKI KEMBALI)
  static Future<Map<String, List<Recipe>>> getMealPlans() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final isLoggedIn = prefs.getBool('hasLoggedAsUser') ?? false;

      if (!isLoggedIn || token == null) {
        throw Exception("Anda harus login untuk melihat meal plan.");
      }

      final String requestUrl = '$_baseUrl/meal-plans/';
      debugPrint('Fetching meal plans from: $requestUrl');

      final Map<String, String> headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(Uri.parse(requestUrl), headers: headers);
      debugPrint('Get Meal Plans response code: ${response.statusCode}');

      if (response.statusCode == 200) {
        // (PERBAIKAN 1) Kembalikan ke Map, karena responsnya adalah Object
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final Map<String, List<Recipe>> finalMealPlan = {};

        // (PERBAIKAN 2) Iterasi menggunakan .values() dari Map
        for (var dayData in responseData.values) {
          if (dayData is Map<String, dynamic>) {
            final String dayName = dayData['day']; // "Senin", "Selasa", dst.
            final List<dynamic> recipesJson = dayData['recipes'] ?? [];
            final List<Recipe> recipesList = recipesJson.map((recipeJson) {
              return Recipe(
                id: recipeJson['id'],
                namaResep: recipeJson['nama_resep'], // Typo 'nama_rese' sudah diperbaiki
                gambar: recipeJson['url_gambar'],
                waktu: recipeJson['waktu_masak'],
                negara: recipeJson['negara'] ?? '',
                kategori: recipeJson['kategori'] ?? '',
                // Beri nilai default
                kalori: 0,
                protein: 0,
                karbohidrat: 0,
                bahan: '', // DetailMakanan akan mengambil ini
                steps: '', // DetailMakanan akan mengambil ini
              );
            }).toList();

            finalMealPlan[dayName] = recipesList;
          }
        }

        return finalMealPlan;
      } else {
        debugPrint('Failed to get meal plans: ${response.body}');
        throw Exception('Gagal memuat meal plan: ${response.statusCode}');
      }
    } catch (e, stacktrace) {
      debugPrint('Exception in getMealPlans: $e');
      debugPrint('Stacktrace: $stacktrace');
      throw Exception(
          'Terjadi kesalahan: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  // --- Fungsi getWeeklyIngredients (Sudah Benar) ---
  static Future<List<WeeklyIngredient>> getWeeklyIngredients() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final isLoggedIn = prefs.getBool('hasLoggedAsUser') ?? false;

      if (!isLoggedIn || token == null) {
        throw Exception("Anda harus login untuk melihat summary bahan.");
      }

      final String requestUrl = '$_baseUrl/meal-plans/weekly/ingredients';
      debugPrint('Fetching weekly ingredients from: $requestUrl');

      final Map<String, String> headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(Uri.parse(requestUrl), headers: headers);
      debugPrint(
          'Get Weekly Ingredients response code: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Ini sudah benar, '{"data": [...] }' adalah Map
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> ingredientsData = responseData['data'] ?? [];

        final List<WeeklyIngredient> ingredientsList = ingredientsData
            .map((item) =>
                WeeklyIngredient.fromJson(item as Map<String, dynamic>))
            .toList();

        return ingredientsList;
      } else {
        debugPrint('Failed to get weekly ingredients: ${response.body}');
        throw Exception(
            'Gagal memuat summary bahan: ${response.statusCode}');
      }
    } catch (e, stacktrace) {
      debugPrint('Exception in getWeeklyIngredients: $e');
      debugPrint('Stacktrace: $stacktrace');
      throw Exception(
          'Terjadi kesalahan: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  // --- Fungsi addRecipeToMealPlan (Sudah Benar) ---
  static Future<void> addRecipeToMealPlan({
    required String day,
    required int recipeId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final isLoggedIn = prefs.getBool('hasLoggedAsUser') ?? false;

      if (!isLoggedIn || token == null) {
        throw Exception("Anda harus login untuk menambah meal plan.");
      }

      final String requestUrl = '$_baseUrl/meal-plans/';
      debugPrint('Adding to meal plan: $requestUrl');

      final Map<String, String> headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final body = jsonEncode({
        'day': day.toLowerCase(),
        'recipes': [
          {'recipe_id': recipeId, 'quantity': 1}
        ]
      });

      debugPrint('Request body: $body');

      final response = await http.post(
        Uri.parse(requestUrl),
        headers: headers,
        body: body,
      );

      debugPrint('Meal Plan response code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Meal Plan added successfully: ${response.body}');
      } else {
        debugPrint('Failed to add meal plan: ${response.body}');

        String errorMessage = 'Gagal menyimpan meal plan.';
        try {
          final responseData = jsonDecode(response.body);
          if (responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          } else if (responseData.containsKey('error')) {
            errorMessage = responseData['error'];
          }
        } catch (e) {}
        throw Exception(errorMessage);
      }
    } catch (e, stacktrace) {
      debugPrint('Exception in addRecipeToMealPlan: $e');
      debugPrint('Stacktrace: $stacktrace');
      throw Exception(
          'Terjadi kesalahan: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }
}