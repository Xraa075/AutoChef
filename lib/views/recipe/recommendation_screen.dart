import 'package:flutter/material.dart';
import 'package:autochef/data/dummy_recipes.dart';
import 'components/card_rekomendation.dart';



class RekomendationRecipe extends StatelessWidget {
    const RekomendationRecipe ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[100],
      appBar: AppBar(
        title: const Text("Hallo User"),
        backgroundColor: Colors.yellow[600],
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            alignment: Alignment.centerLeft,
            color: Colors.yellow[600],
            child: const Text(
              "Ini adalah rekomendasi resep sesuai dengan bahanmu",
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: dummyRecipes.length,
                itemBuilder: (context, index) {
                  return RecipeCard(recipe: dummyRecipes[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
