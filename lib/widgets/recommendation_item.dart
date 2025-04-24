import 'package:flutter/material.dart';

class RecommendationItem extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback? onTap; // 1. Add the onTap parameter


  const RecommendationItem({
    super.key,
    required this.title,
    required this.imagePath,
    this.onTap, // Include onTap in the constructor
  });

  @override
  Widget build(BuildContext context) {
    final bool isNetworkImage = imagePath.startsWith("http");

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image(
                image: isNetworkImage
                    ? NetworkImage(imagePath)
                    : AssetImage(imagePath) as ImageProvider,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 80,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
