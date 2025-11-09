// (MODIFIKASI) mealplanner.dart
import 'package:flutter/material.dart';
import 'package:autochef/widgets/header.dart';
import 'package:autochef/widgets/recipe_card.dart';
import 'package:autochef/models/recipe.dart';
import 'package:autochef/views/recipe/recipe_detail_screen.dart';
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

  Map<String, List<Recipe>> _mealPlan = {};
  List<WeeklyIngredient> _summaryItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        MealPlanService.getMealPlans(),
        MealPlanService.getWeeklyIngredients(),
      ]);

      final newMealPlan = results[0] as Map<String, List<Recipe>>;
      final newSummary = results[1] as List<WeeklyIngredient>;

      final Map<String, List<Recipe>> orderedMealPlan = {};
      for (var day in days) {
        orderedMealPlan[day] = newMealPlan[day] ?? [];
      }

      if (mounted) {
        setState(() {
          _mealPlan = orderedMealPlan;
          _summaryItems = newSummary;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _mealPlan = {};
          _summaryItems = [];
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

  Future<void> _showDeleteConfirmation(String day, Recipe recipe) async {
    bool? isConfirmed = await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          // (PERBAIKAN) Typo: RoundedRectangleOrder -> RoundedRectangleBorder
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          backgroundColor: Colors.white,
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 10),
              Text("Konfirmasi Hapus"),
            ],
          ),
          content: Text(
              "Anda yakin ingin menghapus resep \"${recipe.namaResep}\" dari hari $day?"),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18))),
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18))),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text("Hapus", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (isConfirmed == true) {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });

      try {
        await MealPlanService.removeRecipeFromMealPlan(
            day: day, recipeId: recipe.id);
        await _loadData();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Resep berhasil dihapus.'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Gagal menghapus resep: ${e.toString().replaceFirst("Exception: ", "")}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
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
                onRefresh: _loadData,
                color: const Color(0xFFF46A06),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...days.map((day) => _buildDayTile(day)).toList(),
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
                          final String catatan =
                              item.detailBahan.catatan != null &&
                                      item.detailBahan.catatan!.isNotEmpty
                                  ? " (${item.detailBahan.catatan})"
                                  : "";
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
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "•  ",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    text,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
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
                // (MODIFIKASI) Hapus Row/Padding, kembalikan ke RecipeCard
                // dan tambahkan callback onDeleteTapped
                return RecipeCard(
                  recipe: recipe,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailMakanan(recipe: recipe),
                      ),
                    ).then((_) =>
                        _loadData());
                  },
                  onDeleteTapped: () {
                    _showDeleteConfirmation(day, recipe);
                  },
                );
              }).toList(),
      ),
    );
  }
}
