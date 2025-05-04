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
        ...ingredients.map((step) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("●   ", ),
                  Expanded(child: Text(step, style: TextStyle(fontSize: 16))),
                ],
              ),
            )),
      ],
    );
  }
}
