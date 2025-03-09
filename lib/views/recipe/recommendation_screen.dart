//Berisi UI tampilan aplikasi

import 'package:flutter/material.dart';

class RecommendationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rekomendasi Resep"),
        backgroundColor: Colors.orange, // Warna bisa disesuaikan
      ),
      body: Center(
        child: Text(
          "Halaman Rekomendasi Resep",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
