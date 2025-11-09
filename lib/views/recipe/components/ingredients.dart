// (MODIFIKASI) ingredients.dart
import 'package:flutter/material.dart';
// Import model baru
import 'package:autochef/models/recipe_detail_model.dart';

class Ingredients extends StatelessWidget {
  // Ubah tipe data dari List<String> menjadi List<Bahan>
  final List<Bahan> ingredients;

  Ingredients({required this.ingredients});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Bahan-bahan",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        // Ubah logic map
        ...ingredients.map((bahan) {
          // Format string bahan berdasarkan data terstruktur
          final String catatan =
              bahan.detailBahan.catatan != null &&
                      bahan.detailBahan.catatan!.isNotEmpty
                  ? " (${bahan.detailBahan.catatan})"
                  : "";
          
          // Cek jika jumlah 0 atau 0.00, jangan tampilkan
          final String jumlah =
              (double.tryParse(bahan.detailBahan.jumlah) ?? 0) > 0
                  // Hapus .00 jika ada di akhir
                  ? "${bahan.detailBahan.jumlah.replaceAll(RegExp(r'\.00$'), '')} ${bahan.detailBahan.satuan} "
                  : "";

          final String text = "$jumlah${bahan.namaBahan}$catatan";

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "●   ",
                ),
                Expanded(child: Text(text, style: TextStyle(fontSize: 16))),
              ],
            ),
          );
        }),
      ],
    );
  }
}