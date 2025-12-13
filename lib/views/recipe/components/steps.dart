// (MODIFIKASI) steps.dart
import 'package:flutter/material.dart';
// Import model baru
import 'package:autochef/models/recipe_detail_model.dart';

class Steps extends StatelessWidget {
  // Ubah tipe data dari List<String> menjadi List<Langkah>
  final List<Langkah> steps;

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
        // Ubah logic List.generate
        ...List.generate(
          steps.length,
          (index) {
            // 'step' sekarang adalah objek Langkah
            final step = steps[index];
            if (step.instruksi.trim().isEmpty)
              return SizedBox(); // skip langkah kosong
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${step.urutan}.', // Ambil dari step.urutan
                    style: const TextStyle(
                      fontSize: 16, // Ukuran teks untuk nomor
                      color: Colors.black,
                      fontWeight: FontWeight.w600, // Sedikit tebalkan nomor
                    ),
                  ),
                  const SizedBox(width: 10), // Margin antara nomor dan teks
                  Expanded(
                    child: Text(
                      step.instruksi, // Ambil dari step.instruksi
                      style: const TextStyle(
                        fontSize: 16, // Ukuran teks untuk langkah
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