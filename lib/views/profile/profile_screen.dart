// //Ini versi tanpa tombol logout
// import 'package:flutter/material.dart';
// import 'package:autochef/models/user.dart';
// import 'package:autochef/data/dummy_user.dart';

// class ProfileScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     User currentUser = getActiveUser();
//     return Scaffold(
//       backgroundColor: Color(0xFFFBC72A),
//       body: SafeArea(
//         child: Column(
//           children: [
//             const SizedBox(height: 30),
//             // Foto profil
//             CircleAvatar(
//               backgroundImage: AssetImage(currentUser.userImage),
//               radius: 45,
//               backgroundColor: Colors.white,
//             ),
//             const SizedBox(height: 10),
//             // Nama user
//             Text(
//               "${currentUser.username}",
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),
//             const SizedBox(height: 30),
//             // Section putih di bawah (kosong)
//             Expanded(
//               child: Container(
//                 width: double.infinity,
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(30),
//                     topRight: Radius.circular(30),
//                   ),
//                 ),
//                 child: Center(
//                   child: Text(
//                     "Belum ada data",
//                     style: TextStyle(color: Colors.grey[400]),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// //ini versi dengan favorite
// import 'package:flutter/material.dart';
// import 'package:autochef/models/user.dart';
// import 'package:autochef/data/dummy_user.dart';

// class ProfileScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     User currentUser = getActiveUser();
//     return Scaffold(
//       backgroundColor: const Color(0xFFFBC72A),
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Column(
//               children: [
//                 const SizedBox(height: 30),
//                 CircleAvatar(
//                   backgroundImage: AssetImage(currentUser.userImage),
//                   radius: 45,
//                   backgroundColor: Colors.white,
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   "${currentUser.username}",
//                   style: const TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//                 Expanded(
//                   child: Container(
//                     width: double.infinity,
//                     decoration: const BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(30),
//                         topRight: Radius.circular(30),
//                       ),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 24,
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Center(
//                             child: Text(
//                               "Favorite",
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 20),
//                           Center(
//                             child: Text(
//                               "Anda harus login untuk menggunakan fitur favorite.",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 color: Colors.grey[400],
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             Positioned(
//               top: 10,
//               right: 10,
//               child: IconButton(
//                 icon: const Icon(Icons.logout, color: Colors.white),
//                 onPressed: () {
//                   // TODO: Hubungkan ke backend logout kamu di sini
//                   print("Logout ditekan");
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//ini versi tanpa favorite
import 'package:flutter/material.dart';
import 'package:autochef/models/user.dart';
import 'package:autochef/data/dummy_user.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User currentUser = getActiveUser();
    return Scaffold(
      backgroundColor: const Color(0xFFFBC72A),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 30),
                CircleAvatar(
                  backgroundImage: AssetImage(currentUser.userImage),
                  radius: 45,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 10),
                Text(
                  "${currentUser.username}",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Belum ada data",
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () {
                  // Koneksi ke Backend untuk logout
                  print("Logout ditekan");
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
