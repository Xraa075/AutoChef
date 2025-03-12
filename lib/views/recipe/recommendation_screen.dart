import 'package:flutter/material.dart';
import 'package:autochef/views/recipe/recipe_detail_screen.dart';
import 'package:autochef/data/dummy_recipes.dart';
import 'package:autochef/widgets/recipe_card.dart';
import 'package:autochef/widgets/header.dart';

class RekomendationRecipe extends StatelessWidget {
  const RekomendationRecipe({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[600],
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(120), // Menyesuaikan tinggi header
        child: CustomHeader(
          title: "Ini adalah rekomendasi resep sesuai dengan bahanmu",
        ),
      ),
      
      body: SafeArea(
        child: Column(
          children: [
            
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 30), // Sedikit jarak agar lebih lega
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 0.0),
                      child: Text(
                        "Rekomendasi",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: dummyRecipes.length,
                        itemBuilder: (context, index) {
                          return RecipeCard(
                            recipe: dummyRecipes[index],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetailMakanan(recipe: dummyRecipes[index]),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
