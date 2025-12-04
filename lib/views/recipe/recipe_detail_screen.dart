import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:autochef/models/recipe.dart';
import 'package:autochef/views/recipe/components/steps.dart';
import 'package:autochef/views/recipe/components/recipe_info.dart';
import 'package:autochef/views/recipe/components/ingredients.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autochef/services/api_rekomendation.dart';
import 'package:autochef/widgets/popup_mealplan.dart';

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
                  child: FutureBuilder<DetailModel.RecipeDetail>(
                    future: _futureRecipeDetail,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ListView(
                          controller: scrollController,
                          children: [
                            _buildDragHandle(),
                            _buildHeader(
                              context,
                              widget.recipe.namaResep,
                              widget.recipe.negara,
                            ),
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
                      if (snapshot.hasError || !snapshot.hasData) {
                         return ListView(
                          controller: scrollController,
                          children: [
                            _buildDragHandle(),
                            _buildHeader(
                              context,
                              widget.recipe.namaResep,
                              widget.recipe.negara,
                            ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 40.0),
                                child: Text(
                                  'Gagal memuat detail resep',
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
                            context,
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


  Widget _buildHeader(BuildContext context, String namaResep, String negara) {
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
                Icons.calendar_month_outlined,
                color: Color(0xFFF46A06),
                size: 32,
              ),
              // MEMANGGIL CLASS BARU DISINI
              onPressed: () {
                MealPlanPopup.show(
                  context, 
                  recipeId: widget.recipe.id, 
                  recipeName: widget.recipe.namaResep
                );
              },
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