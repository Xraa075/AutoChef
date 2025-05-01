import 'package:flutter/material.dart';
import 'package:autochef/models/recipe.dart';
import 'package:autochef/views/recipe/components/recipe_info.dart';
import 'package:autochef/views/recipe/components/ingredients.dart';
import 'package:autochef/views/recipe/components/steps.dart';

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
            ),
          ),

          /// **Tombol Kembali**
          Positioned(
            top: 40, // Jarak dari atas
            left: 10, // Jarak dari kiri
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.pop(context); // Kembali ke halaman sebelumnya
              },
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
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Text(
                        recipe.namaResep,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 15),


 /// **Kategori dan Negara**
                        Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                          "${recipe.negara}",
                          style: TextStyle(
                            fontSize: 18,
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