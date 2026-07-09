import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:autochef/models/recipe.dart';

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

class MealPlanService {
  static const String _baseUrl = "http://100.120.18.38:8080/api";
  // static const String _baseUrl = "https://backend.autochef.site/api";

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
        final dynamic responseJson = jsonDecode(response.body);
        if (responseJson is! Map<String, dynamic>) {
          return {};
        }
        final Map<String, dynamic> responseData =
            responseJson;
        final Map<String, List<Recipe>> finalMealPlan = {};

        for (var dayData in responseData.values) {
          if (dayData is Map<String, dynamic>) {
            final String dayName = dayData['day'];
            final List<dynamic> recipesJson = dayData['recipes'] ?? [];
            final List<Recipe> recipesList = recipesJson.map((recipeJson) {
              return Recipe(
                id: recipeJson['id'],
                namaResep: recipeJson['nama_resep'],
                gambar: recipeJson['url_gambar'],
                waktu: recipeJson['waktu_masak'],
                negara: recipeJson['negara']?.toString() ?? '',
                kategori: recipeJson['kategori']?.toString() ?? '',
                kalori: 0,
                protein: 0,
                karbohidrat: 0,
                bahan: '',
                steps: '',
              );
            }).toList();

            finalMealPlan[dayName] = recipesList;
          }
        }

        return finalMealPlan;
      } else {
        debugPrint('Failed to get meal plans: ${response.body}');
        throw Exception('Gagal memuat meal plan');
      }
    } catch (e, stacktrace) {
      debugPrint('Exception in getMealPlans: $e');
      debugPrint('Stacktrace: $stacktrace');
      throw Exception(
          'Terjadi kesalahan: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

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
            'Gagal memuat summary bahan');
      }
    } catch (e, stacktrace) {
      debugPrint('Exception in getWeeklyIngredients: $e');
      debugPrint('Stacktrace: $stacktrace');
      throw Exception(
          'Terjadi kesalahan: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  static Future<void> addRecipeToMealPlan({
    required String day,
    required int recipeId,
    required int quantity,
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
          {'recipe_id': recipeId, 'quantity': quantity}
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

  static Future<void> removeRecipeFromMealPlan({
    required String day,
    required int recipeId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final isLoggedIn = prefs.getBool('hasLoggedAsUser') ?? false;

      if (!isLoggedIn || token == null) {
        throw Exception("Anda harus login untuk menghapus meal plan.");
      }

      final String requestUrl =
          '$_baseUrl/meal-plans/${day.toLowerCase()}/$recipeId';
      debugPrint('Deleting recipe from: $requestUrl');

      final Map<String, String> headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.delete(Uri.parse(requestUrl), headers: headers);
      debugPrint('Delete recipe response code: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        debugPrint('Failed to delete recipe: ${response.body}');
        throw Exception('Gagal menghapus resep');
      }

      debugPrint('Recipe deleted successfully');
    } catch (e, stacktrace) {
      debugPrint('Exception in removeRecipeFromMealPlan: $e');
      debugPrint('Stacktrace: $stacktrace');
      throw Exception(
          'Terjadi kesalahan: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }
}