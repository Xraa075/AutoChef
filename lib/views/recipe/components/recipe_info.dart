import 'package:flutter/material.dart';

class RecipeInfo extends StatelessWidget {
  final int waktu;
  final int kalori;
  final int protein;
  final int karbohidrat;

  const RecipeInfo({
    super.key,
    required this.waktu,
    required this.kalori,
    required this.protein,
    required this.karbohidrat,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildInfoItem(Icons.restaurant, "$waktu", "menit"),
        _buildInfoItem(Icons.local_fire_department, "$kalori", "kalori"),
        _buildInfoItem(Icons.fastfood, "$protein g", "protein"),
        _buildInfoItem(Icons.lunch_dining, "$karbohidrat g", "karbohidrat"),
      ],
    );
  }

  /// Widget untuk setiap item informasi
  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 90,
          decoration: BoxDecoration(
            color: const Color(0xFFFBC72A),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Color(0xFFF46A06), size: 30),
              SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.black87)),
      ],
    );
  }
}
