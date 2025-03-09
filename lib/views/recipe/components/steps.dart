import 'package:flutter/material.dart';

class Steps extends StatelessWidget {
  final List<String> steps;

  Steps({required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Langkah-langkah", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ...steps.map((step) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("• ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Expanded(child: Text(step, style: TextStyle(fontSize: 16))),
                ],
              ),
            )),
      ],
    );
  }
}
