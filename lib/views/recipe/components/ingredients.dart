import 'package:flutter/material.dart';

class Ingredients extends StatelessWidget {
  final List<String> ingredients;

  Ingredients({required this.ingredients});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Bahan-bahan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ...ingredients.map((item) => ListTile(
              leading: Icon(Icons.check_circle, color: Colors.orange),
              title: Text(item, style: TextStyle(fontSize: 16)),
            )),
      ],
    );
  }
}
