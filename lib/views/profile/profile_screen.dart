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
// import 'package:flutter/material.dart';
// import 'package:autochef/models/user.dart';
// import 'package:autochef/data/dummy_user.dart';
// import 'package:autochef/routes.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ProfileScreen extends StatelessWidget {
//   Future<void> logout(BuildContext context) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('hasLoggedAsGuest', false);
//     await prefs.setBool('hasLoggedAsUser', false);

//     Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     Future<User> currentUser = getActiveUser();
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
//                     child: Center(
//                       child: Text(
//                         "Belum ada data",
//                         style: TextStyle(color: Colors.grey[400]),
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
//                 icon: const Icon(Icons.logout_rounded, color: Colors.white),
//                 onPressed: () {
//                   // Koneksi ke Backend untuk logout
//                   logout(context);
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

import 'package:flutter/material.dart';
import 'package:autochef/models/user.dart';
import 'package:autochef/data/dummy_user.dart';
import 'package:autochef/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasLoggedAsGuest', false);
    await prefs.setBool('hasLoggedAsUser', false);

    Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
  }

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
                      currentUser.username,
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
                    icon: const Icon(Icons.logout_rounded, color: Colors.white),
                    onPressed: () async {
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            title: Row(
                              children: [
                                Icon(Icons.info, color: Colors.orange),
                                SizedBox(width: 10),
                                Text("Logout"),
                              ],
                            ),
                            content: Text(
                              "Apakah anda yakin ingin logout?",
                              style: TextStyle(fontSize: 15),
                            ),
                            actionsAlignment: MainAxisAlignment.spaceAround,
                            actions: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.25,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.black,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context, false);
                                  },
                                  child: Text("Batal"),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.25,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                  },
                                  child: Text(
                                    "Logout",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );

                      if (shouldLogout == true) {
                        logout(context);
                        print("Logout ditekan");
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
