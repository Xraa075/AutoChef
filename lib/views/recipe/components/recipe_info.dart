import 'package:flutter/material.dart';

class RecipeInfo extends StatelessWidget {
  final String time;
  final String calories;
  final String protein;
  final String carbs;

  const RecipeInfo({
    required this.time,
    required this.calories,
    required this.protein,
    required this.carbs,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildInfoItem(Icons.restaurant, "$time", "menit"),
        _buildInfoItem(Icons.local_fire_department, "$calories", "kalori"),
        _buildInfoItem(Icons.fastfood, "$protein g", "protein"),
        _buildInfoItem(Icons.lunch_dining, "$carbs g", "karbohidrat"),
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
            color: const Color.fromARGB(255, 255, 221, 118),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.orange, size: 30),
              SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }
}
