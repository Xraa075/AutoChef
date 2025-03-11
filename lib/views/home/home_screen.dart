//Berisi UI tampilan aplikasi

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Screen"),
        backgroundColor: Colors.orange, // Warna bisa disesuaikan
      ),
      body: Center(
        child: Text(
          "Halaman Utama",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
