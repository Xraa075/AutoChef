//Berisi UI tampilan aplikasi

import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notification Screen"),
        backgroundColor: Colors.orange, // Warna bisa disesuaikan
      ),
      body: Center(
        child: Text(
          "Notifikasi",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}