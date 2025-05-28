import 'package:flutter/material.dart';
import 'package:autochef/models/recipe.dart';
import 'package:autochef/views/recipe/components/steps.dart';
import 'package:autochef/views/recipe/components/recipe_info.dart';
import 'package:autochef/views/recipe/components/ingredients.dart';

class DetailMakanan extends StatelessWidget {
  final Recipe recipe;

  const DetailMakanan({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// **Gambar Latar Belakang**
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.network(
              recipe.gambar,
              width: double.infinity,
              height: 292,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 292,
                  color: Colors.grey[300], // Warna latar belakang abu-abu
                  child: const Center(
                    child: Icon(
                      Icons.fastfood, // Ikon makanan
                      size: 80, // Ukuran ikon
                      color: Colors.grey, // Warna abu-abu
                    ),
                  ),
                );
              },
            ),
          ),

          /// **Tombol Kembali**
          Positioned(
            top: 40, // Jarak dari atas
            left: 10, // Jarak dari kiri
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withOpacity(0.5),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.black,
                  size: 25,
                ),
              ),
            ),
          ),

          /// **Bottom Sheet Bisa Ditarik**
          DraggableScrollableSheet(
            initialChildSize: 0.71,
            minChildSize: 0.71,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(bottom: 10),
                        child: Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Text(
                        recipe.namaResep,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),

                      /// **Kategori dan Negara**
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${recipe.negara}",
                            style: TextStyle(
                              fontSize: 13,
                              color: const Color.fromARGB(121, 0, 0, 0),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      /// **Informasi Resep**
                      RecipeInfo(
                        waktu: recipe.waktu,
                        kalori: recipe.kalori,
                        protein: recipe.protein,
                        karbohidrat: recipe.karbohidrat,
                      ),
                      SizedBox(height: 20),

                      /// **Bahan-bahan**
                      Ingredients(ingredients: recipe.bahan.split(",") ?? []),
                      SizedBox(height: 20),

                      /// **Langkah-langkah**
                      Steps(steps: recipe.steps.split(".") ?? []),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
