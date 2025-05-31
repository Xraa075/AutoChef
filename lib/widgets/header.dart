// import 'package:flutter/material.dart';
// import 'package:autochef/models/user.dart';
// import 'package:autochef/data/dummy_user.dart';

// class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
//   final String title;
//   final Widget? child; // ✅ Tambahin child di sini

//   const CustomHeader({
//     super.key,
//     required this.title,
//     this.child, // ✅ Masukin ke constructor
//   });

//   @override
//   Widget build(BuildContext context) {
//     User currentUser = getActiveUser(); // Ambil user aktif dari data dummy

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//       decoration: const BoxDecoration(
//         color: Color(0xFFFBC72A),
//       ),
//       child: SafeArea(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min, // Supaya tinggi header menyesuaikan konten
//           children: [
//             Row(
//               children: [
//                 CircleAvatar(
//                   backgroundImage: AssetImage(currentUser.userImage),
//                   radius: 24,
//                   backgroundColor: Colors.white,
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Halo, ${currentUser.username}',
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       Text(
//                         title,
//                         style: const TextStyle(
//                           fontSize: 14,
//                           color: Colors.white,
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             if (child != null) ...[
//               const SizedBox(height: 12), // Tambahin jarak dari row ke child
//               child!, // ✅ Tampilkan child kalau ada
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Size get preferredSize {
//     return child != null ? const Size.fromHeight(140) : const Size.fromHeight(80);
//   }

// }

import 'package:flutter/material.dart';
import 'package:autochef/models/user.dart';
import 'package:autochef/data/dummy_user.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? child;

  const CustomHeader({super.key, required this.title, this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: getActiveUser(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final currentUser = snapshot.data!;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: const BoxDecoration(color: Color(0xFFFBC72A)),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (child != null) ...[const SizedBox(height: 12), child!],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize {
    return child != null
        ? const Size.fromHeight(140)
        : const Size.fromHeight(80);
  }
}
