// (MODIFIKASI) mealplanner.dart
import 'package:flutter/material.dart';
import 'package:autochef/widgets/header.dart';
import 'package:autochef/widgets/recipe_card.dart';
import 'package:autochef/models/recipe.dart';
import 'package:autochef/views/recipe/recipe_detail_screen.dart';
// (MODIFIKASI) Import service dan model baru
import 'package:autochef/services/meal_plan.dart';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  final List<String> days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu'
  ];

  // (DIHAPUS) List summaryItems yang di-hardcode
  // final List<String> summaryItems = [ ... ];

  // (BARU) State untuk menampung data dari API
  Map<String, List<Recipe>> _mealPlan = {};
  List<WeeklyIngredient> _summaryItems = []; // <-- State baru
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData(); // Ganti nama fungsi
  }

  // (MODIFIKASI) Ganti nama dan gunakan Future.wait
  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      // (BARU) Panggil kedua API secara bersamaan
      final results = await Future.wait([
        MealPlanService.getMealPlans(),
        MealPlanService.getWeeklyIngredients(),
      ]);

      // (BARU) Ekstrak hasil dari Future.wait
      final newMealPlan = results[0] as Map<String, List<Recipe>>;
      final newSummary = results[1] as List<WeeklyIngredient>;

      // Atur meal plan
      final Map<String, List<Recipe>> orderedMealPlan = {};
      for (var day in days) {
        orderedMealPlan[day] = newMealPlan[day] ?? [];
      }

      if (mounted) {
        setState(() {
          _mealPlan = orderedMealPlan;
          _summaryItems = newSummary; // <-- Set state baru
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _mealPlan = {};
          _summaryItems = []; // <-- Kosongkan state baru jika error
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Gagal memuat data meal plan: ${e.toString().replaceFirst("Exception: ", "")}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
            fontFamily: 'Poppins',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFF46A06)))
            : RefreshIndicator(
                onRefresh: _loadData, // Panggil fungsi baru
                color: const Color(0xFFF46A06),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(), // Agar bisa refresh
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bagian Resep per Hari
                      ...days.map((day) => _buildDayTile(day)).toList(),

                      // Bagian Summary
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

                      // (MODIFIKASI) Tampilkan data summary dari API
                      if (_summaryItems.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'Belum ada summary bahan.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      else
                        ..._summaryItems.map((item) {
                          // Format string dari data model
                          final String catatan =
                              item.detailBahan.catatan != null &&
                                      item.detailBahan.catatan!.isNotEmpty
                                  ? " (${item.detailBahan.catatan})"
                                  : "";
                          // Format jumlah, hapus .0 jika tidak perlu
                          final String jumlah =
                              item.detailBahan.jumlah.toStringAsFixed(
                            item.detailBahan.jumlah.truncateToDouble() ==
                                    item.detailBahan.jumlah
                                ? 0
                                : 1,
                          );

                          final String text =
                              "$jumlah ${item.detailBahan.satuan} ${item.namaBahan}$catatan";

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              text,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          );
                        }).toList(),
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
        tilePadding: EdgeInsets.zero,
        title: Text(
          day,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        initiallyExpanded: recipes.isNotEmpty,
        children: recipes.isEmpty
            ? [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
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
                    ).then((_) =>
                        _loadData()); // Muat ulang data setelah kembali
                  },
                );
              }).toList(),
      ),
    );
  }
}