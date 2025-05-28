import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autochef/widgets/navbar.dart';
import 'package:http/http.dart' as http;
import 'regis.dart'; 
import 'dart:io';
import 'dart:convert'; 
import 'dart:async'; 

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? errorMessage;

  bool _obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void showLoadingDialog() {
    if (!mounted) return; // Pastikan widget masih ter-mount
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  void hideLoadingDialog() {
    if (!mounted) return;
    // Cek apakah dialog masih ada sebelum mencoba menutupnya
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  Future<void> loginUser() async {
    // Reset pesan error sebelum validasi/request baru
    setState(() {
      errorMessage = null;
    });

    String email = emailController.text.trim();
    String password = passwordController.text;

    // --- VALIDASI FRONTEND SEDERHANA ---
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Email dan password harus diisi';
      });
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      // Cek sederhana untuk format email
      setState(() {
        errorMessage = 'Format email tidak valid';
      });
      return;
    }
    if (password.length < 5) {
      // Sesuai dengan min:5 di validasi register
      setState(() {
        errorMessage = 'Password minimal 5 karakter';
      });
      return;
    }
    // --- AKHIR VALIDASI FRONTEND ---

    showLoadingDialog();
    try {
      final response = await http
          .post(
            Uri.parse('http://156.67.214.60/api/login'), // URL API Login Anda
            headers: {
              'Accept': 'application/json',
              // 'Content-Type': 'application/json', // Tidak perlu jika body adalah Map, http akan set default
            },
            body: {'email': email, 'password': password},
          )
          .timeout(const Duration(seconds: 20)); // Tambahkan timeout

      // hideLoadingDialog() dipanggil setelah parsing JSON atau di catch
      // agar jika parsing gagal, dialog tetap tertutup.

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      hideLoadingDialog(); // Pindahkan ke sini setelah jsonDecode atau di awal blok if/else

      if (response.statusCode == 200) {
        // Login berhasil
        SharedPreferences prefs = await SharedPreferences.getInstance();

        String? token = responseData['token'];
        Map<String, dynamic>? userData = responseData['user'];

        if (token != null && userData != null) {
          await prefs.setBool('hasLoggedAsUser', true);
          await prefs.setBool('hasLoggedAsGuest', false);
          await prefs.setString('username', userData['name'] ?? 'Pengguna');
          await prefs.setString('email', userData['email'] ?? '');
          await prefs.setString('token', token);
          // Pertimbangkan untuk menyimpan user ID juga jika diperlukan:
          // await prefs.setInt('user_id', userData['id'] ?? 0);
          await prefs.setString(
            'userImage',
            'lib/assets/images/avatar1.png',
          ); // Default avatar

          // Bersihkan field setelah login berhasil
          emailController.clear();
          passwordController.clear();
          // errorMessage sudah null dari reset di awal

          if (mounted) {
            // Pastikan widget masih ter-mount sebelum navigasi
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const Navbar()),
              (route) => false,
            );
          }
        } else {
          // Jika token atau user tidak ada di respons sukses
          if (mounted) {
            setState(() {
              errorMessage = 'Respons login tidak lengkap dari server.';
            });
          }
        }
      } else if (response.statusCode == 401) {
        // Kredensial salah
        if (mounted) {
          setState(() {
            errorMessage =
                responseData['message'] ?? 'Email atau password salah.';
          });
        }
      } else {
        // Error server lainnya
        if (mounted) {
          setState(() {
            errorMessage =
                responseData['message'] ??
                'Gagal login. Status: ${response.statusCode}';
          });
        }
      }
    } on SocketException {
      hideLoadingDialog();
      if (mounted) {
        setState(() {
          errorMessage = 'Tidak ada koneksi internet. Periksa jaringan Anda.';
        });
      }
    } on TimeoutException {
      hideLoadingDialog();
      if (mounted) {
        setState(() {
          errorMessage = 'Koneksi ke server time out. Coba lagi nanti.';
        });
      }
    } on http.ClientException {
      hideLoadingDialog();
      if (mounted) {
        setState(() {
          errorMessage =
              'Tidak dapat terhubung ke server. Pastikan URL API benar.';
        });
      }
    } on FormatException {
      // Jika jsonDecode gagal
      hideLoadingDialog();
      if (mounted) {
        setState(() {
          errorMessage = 'Format respons dari server tidak valid.';
        });
      }
    } catch (e) {
      hideLoadingDialog();
      if (mounted) {
        setState(() {
          errorMessage = 'Terjadi kesalahan: ${e.toString()}';
        });
      }
      debugPrint('Error saat login: $e');
    }
  }

  Future<void> loginAsGuest(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasLoggedAsGuest', true);
    await prefs.setBool('hasLoggedAsUser', false);
    // Hapus data user sebelumnya jika ada
    await prefs.remove('username');
    await prefs.remove('email');
    await prefs.remove('token');
    await prefs.remove('userImage');

    if (mounted) {
      // Pastikan widget masih ter-mount sebelum navigasi
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Navbar()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFBC72A),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                // Memberi padding pada logo agar tidak terlalu ke atas
                padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.05,
                ),
                child: Image.asset(
                  'lib/assets/images/splashlogodark.png',
                  height: MediaQuery.of(context).size.height * 0.2,
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        if (errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 10.0,
                              left: 8.0,
                              right: 8.0,
                            ),
                            child: Text(
                              errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        _buildTextField(
                          'Email',
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        _buildTextField(
                          'Password',
                          controller: passwordController,
                          isPassword: true,
                        ),
                        const SizedBox(height: 25),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: 45,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF46A06),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed: loginUser,
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don’t have an account? "),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) =>
                                            RegisterPage(), // Navigasi ke RegisterPage
                                  ),
                                );
                              },
                              child: const Text(
                                "Register Now",
                                style: TextStyle(
                                  color: Color(0xFFF46A06),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        GestureDetector(
                          onTap: () => loginAsGuest(context),
                          child: const Text(
                            "Login sebagai Guest",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              decoration: TextDecoration.underline,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint, {
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text, // Tambahkan keyboardType
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8), // Margin antar textfield
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        keyboardType: keyboardType, // Gunakan keyboardType
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.grey, width: 0.7),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFF46A06), width: 1),
          ),
          suffixIcon:
              isPassword
                  ? IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey, // Warna ikon
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  )
                  : null,
        ),
      ),
    );
  }
}
