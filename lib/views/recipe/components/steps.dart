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
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 6),
        ...List.generate(
          steps.length,
          (index) {
            final step = steps[index].trim();
            if (step.isEmpty) return SizedBox(); // skip langkah kosong
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${index + 1}.',
                    style: const TextStyle(
                      fontSize: 12, // Ukuran teks untuk nomor
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 10), // Margin antara nomor dan teks
                  Expanded(
                    child: Text(
                      step,
                      style: const TextStyle(
                        fontSize: 12, // Ukuran teks untuk langkah
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}