import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
        _buildInfoItem(PhosphorIcons.timer(), "$waktu", "menit"),
        _buildInfoItem(PhosphorIcons.fire(), "$kalori", "kalori"),
        _buildInfoItem(PhosphorIcons.fishSimple(), "$protein g", "protein"),
        _buildInfoItem(PhosphorIcons.bread(), "$karbohidrat g", "karbo"),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.topCenter,
          children: [
            // Kapsul kuning
            Container(
              width: 70,
              height: 120,
              decoration: BoxDecoration(
                color: Color(0xFFFBC72A),
                borderRadius: BorderRadius.circular(40),
              ),
              padding: const EdgeInsets.only(top: 55),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            // Lingkaran putih ikon
            Positioned(
              top: 3,
              child: Container(
                width: 65,
                height: 65,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Color(0xFFF46A06),
                  size: 26,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
