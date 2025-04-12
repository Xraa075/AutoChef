import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:autochef/views/input_ingredients/input_screen.dart';
import 'package:autochef/views/profile/profile_screen.dart';
import 'package:autochef/views/notifications/notification_screen.dart';
import 'package:autochef/views/home/home_screen.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  NavbarState createState() => NavbarState();
}

class NavbarState extends State<Navbar> {
  int selectedIndex = 0;
  final List<Widget> pages = [
    //Ini navigasi navbar ke halaman masing masing, jumlahnya sesuai dengan jumlah icon di navbar
    HomeScreen(),
    InputRecipe(),
    ProfileScreen(),
  ];

  void onNavTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  // Future<bool> _onWillPop() async { // Menampilkan konfirmasi keluar hanya di homescreen
  //   if (selectedIndex != 0) {
  //     setState(() {
  //       selectedIndex = 0; // Kembali ke HomeScreen jika bukan di halaman Home
  //     });
  //     return false; // Mencegah keluar dari aplikasi
  //   } else {
  //     return await _showExitConfirmation(); // Menampilkan konfirmasi keluar saat di halaman Home
  //   }
  // }
  Future<bool> _onWillPop() async {
    // Menampilkan konfirmasi keluar di setiap halaman
    return await _showExitConfirmation();
  }

  Future<bool> _showExitConfirmation() async {
    return await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: Colors.white,
                title: Center(
                  child: Text(
                    'Keluar Aplikasi',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                content: Text(
                  'Apakah Anda yakin ingin keluar?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                actionsAlignment: MainAxisAlignment.spaceEvenly,
                actions: [
                  SizedBox(
                    width: 100,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: BorderSide(color: Colors.black),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: () => SystemNavigator.pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Keluar'),
                    ),
                  ),
                ],
              ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Color.fromARGB(255, 0, 0, 0),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        extendBody: true,
        body: pages[selectedIndex],
        bottomNavigationBar: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(36),
            topRight: Radius.circular(36),
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              height: 65,
              backgroundColor: const Color(0xFFFBC72A),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
              indicatorColor: Colors.transparent,
            ),
            child: NavigationBar(
              onDestinationSelected: onNavTapped,
              selectedIndex: selectedIndex,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_filled, size: 30, color: Colors.white),
                  selectedIcon: Icon(
                    Icons.home_filled,
                    size: 30,
                    color: Colors.orange,
                  ),
                  label: '',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.search_rounded,
                    size: 30,
                    color: Colors.white,
                  ),
                  selectedIcon: Icon(
                    Icons.search_rounded,
                    size: 30,
                    color: Colors.orange,
                  ),
                  label: '',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person, size: 30, color: Colors.white),
                  selectedIcon: Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.orange,
                  ),
                  label: '',
                ),
              ],
            ),
          ),
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
