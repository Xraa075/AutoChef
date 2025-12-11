import 'package:shared_preferences/shared_preferences.dart';
import 'package:autochef/models/user.dart';
// import 'package:autochef/models/recipe.dart'; // Tidak dipakai lagi di tampilan ini
import 'package:autochef/data/user.dart';
import 'package:autochef/views/profile/edit_profile.dart';
import 'package:autochef/routes.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser;
  SharedPreferences? _prefs;
  bool _isUserActuallyLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _initializeAndLoadData();
  }

  Future<void> _initializeAndLoadData() async {
    _prefs = await SharedPreferences.getInstance();
    if (mounted) {
      _isUserActuallyLoggedIn = _prefs?.getBool('hasLoggedAsUser') ?? false;
      setState(() {});
    }
  }

  ImageProvider _getImageProvider(String path) {
    if (path.startsWith('http') || path.startsWith('https')) {
      return NetworkImage(path);
    } else {
      return AssetImage(path);
    }
  }

  Future<void> _handleUserLoaded(User activeUserFromBuilder) async {
    if (!mounted) return;
    // Cek jika ada perubahan data user untuk update state lokal
    if (_currentUser == null || _currentUser!.email != activeUserFromBuilder.email) {
       _currentUser = activeUserFromBuilder;
       _isUserActuallyLoggedIn = _prefs?.getBool('hasLoggedAsUser') ?? false;
    }
  }

  // Fungsi Logout
  Future<void> _confirmAndLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: Row(
            children: const [
              Icon(Icons.help_outline_rounded, color: Color(0xFFF46A06)),
              SizedBox(width: 10),
              Text("Konfirmasi Logout"),
            ],
          ),
          content: const Text(
            "Apakah Anda yakin ingin logout dari akun ini?",
            style: TextStyle(fontSize: 15),
          ),
          actionsAlignment: MainAxisAlignment.spaceAround,
          actions: [
            SizedBox(
              width: 100,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.grey),
                ),
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Batal"),
              ),
            ),
            SizedBox(
              width: 100,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  backgroundColor: const Color(0xFFF46A06),
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Logout"),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      if (_prefs == null) _prefs = await SharedPreferences.getInstance();
      await _prefs!.setBool('hasLoggedAsUser', false);
      await _prefs!.remove('username');
      await _prefs!.remove('email');
      await _prefs!.remove('userImage');
      await _prefs!.remove('token');

      if (mounted) {
        setState(() {
          _currentUser = null;
          _isUserActuallyLoggedIn = false;
        });
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.login,
          (route) => false,
        );
      }
    }
  }

  Future<void> _navigateToEditProfile(User currentUserFromBuilder) async {
    if (!mounted || !_isUserActuallyLoggedIn) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => EditProfileScreen(currentUser: currentUserFromBuilder),
      ),
    );
    // Jika kembali dari edit profile (result == true), refresh state
    if (result == true && mounted) {
      setState(() {
        _currentUser = null; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_prefs == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFFBC72A),
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return FutureBuilder<User>(
      future: getActiveUser(), // Mengambil data user dari data/user.dart
      builder: (context, userSnapshot) {
        
        User? activeUser = userSnapshot.data ?? _currentUser;

        // Update local logic jika data tersedia
        if (activeUser != null && _isUserActuallyLoggedIn) {
           WidgetsBinding.instance.addPostFrameCallback((_) {
             if (mounted) _handleUserLoaded(activeUser);
           });
        }

        // Fallback tampilan jika belum login / loading
        String displayUsername = activeUser?.name ?? "Pengguna";
        String displayEmail = activeUser?.email ?? "email@example.com";
        String displayUserImage = activeUser?.userImage ?? "lib/assets/images/avatar1.png";

        if (!_isUserActuallyLoggedIn) {
           displayUsername = "Tamu";
           displayEmail = "Silakan login";
        }

        return Scaffold(
          backgroundColor: const Color(0xFFFBC72A),
          body: SafeArea(
            bottom: false, 
            child: Column(
              children: [
                // --- BAGIAN ATAS (Kuning) ---
                // Sesuai screenshot: Row (Avatar di kiri, Teks di kanan)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        backgroundImage: _getImageProvider(displayUserImage),
                        onBackgroundImageError: (_, __) {},
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              displayUsername,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              displayEmail,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w400,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // --- BAGIAN BAWAH (Putih Lengkung) ---
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Lainnya",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Tombol 1: Ubah Data Diri
                          _buildMenuButton(
                            text: "Ubah Data Diri",
                            icon: Icons.edit_outlined,
                            onTap: () {
                              if (_isUserActuallyLoggedIn && activeUser != null) {
                                _navigateToEditProfile(activeUser);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Silakan login terlebih dahulu")),
                                );
                              }
                            },
                          ),

                          const SizedBox(height: 16),

                          // Tombol 2: Keluar Akun / Masuk Akun
                          _buildMenuButton(
                            text: _isUserActuallyLoggedIn ? "Keluar Akun" : "Masuk Akun",
                            icon: _isUserActuallyLoggedIn ? Icons.logout_outlined : Icons.login,
                            onTap: () {
                              if (_isUserActuallyLoggedIn) {
                                _confirmAndLogout();
                              } else {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  Routes.login,
                                  (route) => false,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget custom untuk tombol menu agar rapi
  Widget _buildMenuButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.grey), 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black, size: 22),
            const SizedBox(width: 16),
            Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}