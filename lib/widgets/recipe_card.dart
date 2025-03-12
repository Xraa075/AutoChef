//Reusable UI components

import 'package:flutter/material.dart';
import 'package:autochef/models/recipe.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onTap;

  const RecipeCard({super.key, required this.recipe, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(top: 15),
        //color: Colors.white,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 0.1,
              blurRadius: 6,
              offset: Offset(1.5, 1)
            ),
          ]
        ),
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        // elevation: 3,
        child: Padding(
          padding: const EdgeInsets.only(right: 15),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
                child: Image.asset(
                  recipe.image,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Bahan: ${recipe.ingredients.join(', ')}",
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      maxLines: 1, //biasany untuk menampilkan judul artikel
                      overflow: TextOverflow.ellipsis, 
                    ),
                    Text(
                      "Kalori: ${recipe.calories} kalori",
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Colors.red),
                        Text(" ${recipe.time} Menit", style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 10),
                        const Icon(Icons.star, size: 14, color: Colors.orange),
                        Text(" ${recipe.difficulity}", style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
