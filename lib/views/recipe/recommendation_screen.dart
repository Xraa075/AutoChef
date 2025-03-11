import 'package:autochef/views/recipe/recipe_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:autochef/data/dummy_recipes.dart';
import 'components/card_rekomendation.dart';



class RekomendationRecipe extends StatelessWidget {
    const RekomendationRecipe ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[600],
      // appBar: AppBar(
      //   title: const Text(
      //     "Hallo User",
      //     style: TextStyle(
      //       color: Colors.white,
      //     ),
      //   ),
      //   backgroundColor: Colors.yellow[600],
      //   elevation: 0,
      // ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              alignment: Alignment.centerLeft,
              color: Colors.yellow[600],
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                    },
                    icon: const Icon(Icons.account_circle, color: Colors.white, size: 60,),
                  ), 
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            
                            const Text(
                              "Hallo Sobat",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Ini adalah rekomendasi resep sesuai dengan bahanmu",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                          textAlign: TextAlign.left,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // list rekomendasi
            Expanded(  
              child: Container(
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
                                  builder: (context) => DetailMakanan(recipe: dummyRecipes[index]),
                                ),
                              );
                            },
                          );
                        }
                      ),
                    ),
                  ],
                ),
                // child: ListView.builder(
                //   padding: const EdgeInsets.all(10),
                //   itemCount: dummyRecipes.length,
                //   itemBuilder: (context, index) {
                //     return RecipeCard(
                //       recipe: dummyRecipes[index],
                //       onTap: () {
                //         Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //             builder: (context) => DetailMakanan(recipe: dummyRecipes[index])));
                //       },
                //     );
                //   },
                // ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
