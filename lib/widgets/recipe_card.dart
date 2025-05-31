import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:autochef/models/recipe.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onTap;

  const RecipeCard({
    super.key,
    required this.recipe,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 0.1,
              blurRadius: 6,
              offset: const Offset(1.5, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(right: 15),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
                child: Stack(
                  children: [
                    buildShimmerPlaceholder(width: 120, height: 120),
                    Image.network(
                      recipe.gambar,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return Opacity(opacity: 0, child: child);
                        }
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 120,
                          height: 120,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.fastfood,
                            size: 50,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.namaResep,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Bahan: ${recipe.bahan.split(',').join(', ')}",
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    // Added calorie information
                    Text(
                      "Kalori : ${recipe.kalori} kalori",
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 5),
                    // Added cooking time and difficulty level
                    Row(
                      children: [
                        Icon(Icons.access_time, color: Colors.orange, size: 16),
                        const SizedBox(width: 2),
                        Text(
                          "${recipe.waktu} Menit",
                          style: TextStyle(fontSize: 12, color: Colors.orange),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.restaurant_menu, color: Colors.red[300], size: 16),
                        const SizedBox(width: 2),
                        Text(
                          "Mudah", // You can replace this with actual difficulty if available
                          style: TextStyle(fontSize: 12, color: Colors.red[300]),
                        ),
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

  Widget buildShimmerPlaceholder({double width = double.infinity, double height = 100}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        color: Colors.white,
      ),
    );
  }
}