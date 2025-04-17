import 'package:flutter/material.dart';

class CategoryItem extends StatelessWidget {
  final String title;
  final String imagePath;

  const CategoryItem({super.key, required this.title, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 5 - 24,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.asset(
              imagePath,
              width: 50,
              height: 65,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
