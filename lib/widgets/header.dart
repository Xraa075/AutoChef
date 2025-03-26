import 'package:flutter/material.dart';
import 'package:autochef/models/user.dart';
import 'package:autochef/data/dummy_user.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    User currentUser = getActiveUser(); // Ambil user aktif dari data dummy

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFBC72A),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Supaya tinggi header menyesuaikan konten
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(currentUser.userImage),
                  radius: 24,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, ${currentUser.username}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80); // Ukuran header lebih besar
}
