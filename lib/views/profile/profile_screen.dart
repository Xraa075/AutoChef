//Berisi UI tampilan aplikasi

import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile Screen"),
        backgroundColor: Colors.orange, // Warna bisa disesuaikan
      ),
      body: Center(
        child: Text(
          "Profile",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
