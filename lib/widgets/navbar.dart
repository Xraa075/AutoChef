import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:autochef/views/home/home_screen.dart';
import 'package:autochef/views/profile/profile_screen.dart';
import 'package:autochef/views/input_ingredients/input_screen.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  NavbarState createState() => NavbarState();
}

class NavbarState extends State<Navbar> {
  int selectedIndex = 0;
  final List<Widget> pages = [HomeScreen(), InputRecipe(), ProfileScreen()];

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
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                title: Row(
                  children: [
                    Icon(Icons.info, color: Color(0xFFF46A06)),
                    SizedBox(width: 10),
                    Text("Konfirmasi Keluar"),
                  ],
                ),
                content: Text(
                  "Apakah anda yakin ingin keluar dari aplikasi?",
                  style: TextStyle(fontSize: 15),
                ),
                actionsAlignment: MainAxisAlignment.spaceAround,
                actions: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: 45,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      child: Text("Batal"),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        backgroundColor: Color(0xFFF46A06),
                      ),
                      onPressed: () {
                        SystemNavigator.pop();
                      },
                      child: Text(
                        "Keluar",
                        style: TextStyle(color: Colors.white),
                      ),
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
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
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
                  icon: Icon(Icons.home_rounded, size: 30, color: Colors.white),
                  selectedIcon: Icon(
                    Icons.home_rounded,
                    size: 30,
                    color: Color(0xFFF46A06),
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
                    color: Color(0xFFF46A06),
                  ),
                  label: '',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person, size: 30, color: Colors.white),
                  selectedIcon: Icon(
                    Icons.person,
                    size: 30,
                    color: Color(0xFFF46A06),
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
