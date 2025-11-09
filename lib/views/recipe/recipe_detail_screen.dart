// (MODIFIKASI) recipe_detail_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:autochef/models/recipe.dart';
import 'package:autochef/views/recipe/components/steps.dart';
import 'package:autochef/views/recipe/components/recipe_info.dart';
import 'package:autochef/views/recipe/components/ingredients.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autochef/services/api_rekomendation.dart';

// (BARU) Import service meal plan yang baru dibuat
import 'package:autochef/services/meal_plan.dart';

import 'package:autochef/models/recipe_detail_model.dart' as DetailModel;

class DetailMakanan extends StatefulWidget {
  final Recipe recipe;

  const DetailMakanan({super.key, required this.recipe});

  @override
  State<DetailMakanan> createState() => _DetailMakananState();
}

class _DetailMakananState extends State<DetailMakanan> {
  late Future<DetailModel.RecipeDetail> _futureRecipeDetail;

  @override
  void initState() {
    super.initState();
    _logRecipeView();
    _futureRecipeDetail = ApiRekomendasi.fetchRecipeDetail(widget.recipe.id);
  }

  // (DIHAPUS/KOMENTARI) Fungsi ini tidak lagi digunakan, diganti API call
  // Future<void> _addRecipeToMealPlanner(String day, Recipe recipe) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final key = 'meal_planner_$day';
  //   List<String> recipesJson = prefs.getStringList(key) ?? [];
  //   String newRecipeJson = jsonEncode(recipe.toJson());
  //   if (!recipesJson.contains(newRecipeJson)) {
  //     recipesJson.add(newRecipeJson);
  //     await prefs.setStringList(key, recipesJson);
  //     debugPrint('Berhasil menyimpan resep JSON untuk hari $day');
  //   } else {
  //     debugPrint('Resep ini sudah ada untuk hari $day');
  //   }
  // }

  Future<void> _logRecipeView() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userLoggedIn = prefs.getBool('hasLoggedAsUser') ?? false;
      if (userLoggedIn) {
        await ApiRekomendasi.logRecipeView(widget.recipe.id);
      }
    } catch (e) {
      debugPrint('Error when logging recipe view: $e');
    }
  }

  // (MODIFIKASI) Fungsi ini diubah untuk memanggil API
  void _showAddToMealPlannerDialog() {
    final List<String> days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu'
    ];
    
    // Variabel untuk melacak loading state di dalam dialog
    bool _isLoading = false;

    showDialog(
      context: context,
      // Jangan biarkan dialog ditutup saat sedang loading
      barrierDismissible: false, 
      builder: (BuildContext dialogContext) {
        // Gunakan StatefulBuilder agar dialog bisa update state-nya sendiri (untuk loading)
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              backgroundColor: Colors.white,
              title: const Text(
                'Simpan resep untuk hari apa?',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    fontFamily: 'Poppins'),
              ),
              content: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: days.map((day) {
                  return ElevatedButton(
                    // (MODIFIKASI) onPressed menjadi async
                    // Nonaktifkan tombol jika sedang loading
                    onPressed: _isLoading ? null : () async {
                      // 1. Tampilkan loading
                      setDialogState(() {
                        _isLoading = true;
                      });

                      try {
                        debugPrint(
                            'Menambahkan resep "${widget.recipe.namaResep}" ke hari $day');
                        
                        // 2. (BARU) Panggil API Service
                        await MealPlanService.addRecipeToMealPlan(
                          day: day, // Service akan mengubah ke lowercase
                          recipeId: widget.recipe.id,
                        );

                        // 3. Jika sukses
                        if (!mounted) return;
                        Navigator.pop(dialogContext); // Tutup dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Resep berhasil ditambahkan ke hari $day!'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } catch (e) {
                        // 4. Jika gagal
                        // Berhenti loading
                        setDialogState(() {
                          _isLoading = false;
                        });

                        if (!mounted) return;
                        // Tampilkan SnackBar error
                        // Tutup dialog terlebih dahulu
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Gagal: ${e.toString().replaceFirst("Exception: ", "")}'),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF46A06),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 12),
                    ),
                    child: Text(day),
                  );
                }).toList(),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actionsPadding: const EdgeInsets.only(bottom: 20, top: 10),
              actions: [
                // (MODIFIKASI) Tampilkan loading atau tombol Batal
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12.0),
                    child: CircularProgressIndicator(color: Color(0xFFF46A06)),
                  )
                else
                  OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 12),
                    ),
                    child: const Text('Batal'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.network(
              widget.recipe.gambar,
              width: double.infinity,
              height: 292,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 292,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.fastfood, size: 80, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          // Tombol Kembali
          Positioned(
            top: 40,
            left: 10,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withOpacity(0.5),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.black,
                  size: 25,
                ),
              ),
            ),
          ),
          // (MODIFIKASI INTI)
          // Gunakan FutureBuilder untuk menunggu data detail
          DraggableScrollableSheet(
            initialChildSize: 0.71,
            minChildSize: 0.71,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30)),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  // Ganti ListView dengan FutureBuilder
                  child: FutureBuilder<DetailModel.RecipeDetail>(
                    future: _futureRecipeDetail,
                    builder: (context, snapshot) {
                      // Saat loading
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ListView(
                          controller: scrollController,
                          children: [
                            _buildDragHandle(),
                            _buildHeader(
                              widget.recipe
                                  .namaResep, // Tampilkan nama resep awal
                              widget.recipe.negara, // Tampilkan negara awal
                            ),
                            // Tampilkan Info Awal (opsional, bisa diganti shimmer)
                            RecipeInfo(
                              waktu: widget.recipe.waktu,
                              kalori: widget.recipe.kalori,
                              protein: widget.recipe.protein,
                              karbohidrat: widget.recipe.karbohidrat,
                            ),
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 40.0),
                                child: CircularProgressIndicator(
                                  color: Color(0xFFF46A06),
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      // Jika error
                      if (snapshot.hasError || !snapshot.hasData) {
                        return ListView(
                          controller: scrollController,
                          children: [
                            _buildDragHandle(),
                            _buildHeader(
                              widget.recipe
                                  .namaResep,
                              widget.recipe.negara,
                            ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 40.0),
                                child: Text(
                                  'Gagal memuat detail resep:\n${snapshot.error}',
                                  textAlign: TextAlign.center,
                                  style:
                                      TextStyle(color: Colors.red.shade700),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      final detail = snapshot.data!;
                      return ListView(
                        controller: scrollController,
                        children: [
                          _buildDragHandle(),
                          _buildHeader(
                            detail.namaResep,
                            detail.negara,
                          ),
                          const SizedBox(height: 20),
                          RecipeInfo(
                            waktu: detail.waktuMasak,
                            kalori: 0, 
                            protein: 0, 
                            karbohidrat: 0, 
                          ),
                          const SizedBox(height: 20),
                          Ingredients(
                            ingredients: detail.bahan,
                          ),
                          const SizedBox(height: 20),
                          Steps(
                            steps: detail.langkahLangkah,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(bottom: 10, top: 10),
      child: Container(
        width: 50,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildHeader(String namaResep, String negara) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                namaResep,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.add_circle_outline,
                color: Color(0xFFF46A06),
                size: 32,
              ),
              onPressed: _showAddToMealPlannerDialog,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          negara,
          style: TextStyle(
            fontSize: 18,
            color: const Color.fromARGB(121, 0, 0, 0),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}