import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:autochef/views/input_ingredients/input_screen.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  NavbarState createState() => NavbarState();
}

class NavbarState extends State<Navbar> {
  int selectedIndex = 1; // Default ke halaman "InputRecipe"
  DateTime? lastPressed; // Waktu terakhir tombol back ditekan

  void onNavTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Future<bool> onWillPop() async {
    DateTime now = DateTime.now();
    if (lastPressed == null || now.difference(lastPressed!) > const Duration(seconds: 2)) {
      lastPressed = now;
      Fluttertoast.showToast(
        msg: "Tekan sekali lagi untuk keluar",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return Future.value(false);
    }
    return Future.value(true); // Keluar dari aplikasi
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop, // Menangani tombol back
      child: Scaffold(
        body: const InputRecipe(), // Hanya menampilkan InputRecipe
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: onNavTapped,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Bahan'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifikasi'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}



//Bagian ini akan digunakan untuk menampilkan halaman Home, Input Bahan, Notifikasi, dan Profil pada sprint selanjutnya

// import 'package:flutter/material.dart';
// import 'package:autochef/views/input_ingredients/input_screen.dart';
// import 'package:autochef/views/profile/profile_screen.dart';
// import 'package:autochef/views/notifications/notification_screen.dart';
// import 'package:autochef/views/home/home_screen.dart';

// class Navbar extends StatefulWidget {
//   const Navbar({super.key});

//   @override
//   NavbarState createState() => NavbarState();
// }

// class NavbarState extends State<Navbar> {
//   int selectedIndex = 0;

//   final List<Widget> pages = [
//     HomeScreen(),         // Halaman Home
//     InputRecipe(),        // Halaman Input Bahan
//     NotificationScreen(), // Halaman Notifikasi
//     ProfileScreen(),      // Halaman Profil
//   ];

//   void onNavTapped(int index) {
//     setState(() {
//       selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: pages[selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: selectedIndex,
//         onTap: onNavTapped,
//         backgroundColor: Colors.white,
//         selectedItemColor: Colors.orange,
//         unselectedItemColor: Colors.grey,
//         type: BottomNavigationBarType.fixed,
//         showSelectedLabels: false,
//         showUnselectedLabels: false,
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//           BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Bahan'),
//           BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifikasi'),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
//         ],
//       ),
//     );
//   }
// }
