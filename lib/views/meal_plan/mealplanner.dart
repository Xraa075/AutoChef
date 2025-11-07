import 'package:flutter/material.dart';
import 'package:autochef/widgets/header.dart';
import 'package:autochef/widgets/recipe_card.dart';
import 'package:autochef/models/recipe.dart';
import 'package:autochef/views/recipe/recipe_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  final List<String> days = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];

  final List<String> summaryItems = [
    '100 bawang',
    '100 butir telur',
    '100 gram gula',
    '100 gram minyak',
  ];
  
  Map<String, List<Recipe>> _mealPlan = {}; 
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMealPlan();
  }

  Future<void> _loadMealPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, List<Recipe>> newMealPlan = {};

    for (var day in days) {
      final key = 'meal_planner_$day';
      final recipesJson = prefs.getStringList(key); 
      
      if (recipesJson != null && recipesJson.isNotEmpty) {
        newMealPlan[day] = recipesJson
            .map((jsonString) => Recipe.fromJson(jsonDecode(jsonString)))
            .toList();
      }
    }

    if (mounted) {
      setState(() {
        _mealPlan = newMealPlan;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBC72A),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: CustomHeader(
          mainTitle: "Meal Planner",
          title: "Rencanakan bahan masakan mingguan mu",
          mainTitleStyle: const TextStyle(
            fontFamily: 'Poppins', fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28), topRight: Radius.circular(28),
          ),
        ),
        // Menggunakan RefreshIndicator dari kode baru
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFF46A06)))
            : RefreshIndicator(
                onRefresh: _loadMealPlan,
                child: SingleChildScrollView(
                  // Menggunakan padding dari kode lama
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...days.map((day) => _buildDayTile(day)).toList(),
                      
                      // --- BAGIAN SUMMARY DARI KODE LAMA DIKEMBALIKAN ---
                      const SizedBox(height: 30),
                      const Text(
                        'Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...summaryItems.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            item,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        );
                      }).toList(),
                      // --- SAMPAI SINI ---
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildDayTile(String day) {
    final recipes = _mealPlan[day] ?? [];

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        // Menggunakan styling dari kode lama
        tilePadding: EdgeInsets.zero,
        title: Text(
          day,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        children: recipes.isEmpty
            ? [
                // Menggunakan widget pesan kosong dari kode lama
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Text(
                      'Belum ada resep untuk hari $day.',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ]
            : recipes.map((recipe) {
                return RecipeCard(
                  recipe: recipe,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailMakanan(recipe: recipe),
                      ),
                    ).then((_) => _loadMealPlan());
                  },
                );
              }).toList(),
      ),
    );
  }
}