import 'package:flutter/material.dart';

class Steps extends StatelessWidget {
  final List<String> steps;

  const Steps({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Langkah-langkah',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        ...List.generate(
          steps.length,
          (index) {
            final step = steps[index].trim();
            if (step.isEmpty) return SizedBox(); // skip langkah kosong
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Text('${index + 1}. $step'),
            );
          },
        ),
      ],
    );
  }
}
