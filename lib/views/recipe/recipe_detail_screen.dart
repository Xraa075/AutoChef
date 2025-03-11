import 'package:flutter/material.dart';
import 'package:autochef/models/recipe.dart';
import 'components/recipe_info.dart';
import 'components/ingredients.dart';
import 'components/steps.dart';
import 'package:autochef/views/recipe/recommendation_screen.dart';

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
            child: Image.asset(
              recipe.image,
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => RekomendationRecipe()),
                );
              },
            ),
          ),
          /// **Bottom Sheet Bisa Ditarik**
          DraggableScrollableSheet(
            initialChildSize: 0.69,
            minChildSize: 0.69,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  decoration: BoxDecoration(
                    color: Colors.white, // Hilangkan efek transparan agar lebih ringan
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: ListView(
                    controller: scrollController, // Gunakan ListView agar lebih optimal
                    children: [
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(bottom: 10,),
                        child: Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Text(recipe.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      Text(recipe.category, style: TextStyle(fontSize: 16, color: Colors.grey)),
                      SizedBox(height: 15),
                      RecipeInfo(
                        time: recipe.time.toString(),
                        calories: recipe.calories.toString(),
                        protein: recipe.protein.toString(),
                        carbs: recipe.carbs.toString(),
                      ),
                      SizedBox(height: 20),
                      Ingredients(ingredients: recipe.ingredients),
                      SizedBox(height: 20),
                      Steps(steps: recipe.steps),
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
