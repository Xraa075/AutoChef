import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io'; // Untuk SocketException
import 'login.dart'; // Pastikan file login.dart ada dan benar path-nya

class RegisterPage extends StatefulWidget {
  RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? errorMessage;
  String? passwordErrorText;
  String? emailErrorText;

  // Tidak perlu isUsernameValid dan isPasswordValid di sini karena validasi dilakukan di dalam registerUser
  bool _obscurePassword = true;
   bool isPasswordValid = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  void hideLoadingDialog() {
    // Cek apakah dialog masih ada sebelum mencoba menutupnya
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  Future<void> registerUser(BuildContext context) async {
    // Reset pesan error sebelum validasi baru
    setState(() {
      errorMessage = null;
      passwordErrorText = null;
      emailErrorText = null;
    });

    // --- VALIDASI FRONTEND SEDERHANA ---
    if (nameController.text.isEmpty) {
      setState(() {
        errorMessage = 'Nama tidak boleh kosong';
      });
      return;
    }
    // Validasi tambahan untuk nama jika diperlukan (misal panjang, karakter)
    // if (nameController.text.contains(' ') || nameController.text.length > 10) {
    //   setState(() {
    //     errorMessage = 'Nama tidak valid (maks 10 karakter, tanpa spasi).';
    //   });
    //   return;
    // }

    if (emailController.text.isEmpty) {
      setState(() {
        errorMessage = 'Email tidak boleh kosong';
      });
      return;
    }
    if (!emailController.text.contains('@') ||
        !emailController.text.contains('.')) {
      setState(() {
        emailErrorText = 'Format email tidak valid';
      });
      return;
    }

    if (passwordController.text.isEmpty) {
      setState(() {
        errorMessage = 'Password tidak boleh kosong';
      });
      return;
    }
    if (passwordController.text.length < 5) {
      setState(() {
        passwordErrorText = 'Password minimal 5 karakter';
      });
      return;
    }
    // Anda bisa menambahkan validasi format password di sini jika API tidak terlalu ketat
    // final passwordRegex = RegExp(r'^[a-zA-Z0-9]+$');
    // if (!passwordRegex.hasMatch(passwordController.text)) {
    //   setState(() {
    //     passwordErrorText = 'Password hanya boleh huruf dan angka';
    //   });
    //   return;
    // }
    // --- AKHIR VALIDASI FRONTEND ---

    showLoadingDialog();
    try {
      final response = await http
          .post(
            Uri.parse('http://156.67.214.60/api/register'), // URL API Anda
            headers: {
              'Accept': 'application/json',
              // 'Content-Type': 'application/json', // Untuk http.post dengan body Map, ini di-set otomatis
              // menjadi application/x-www-form-urlencoded.
              // Jika API Anda *membutuhkan* application/json untuk body ini,
              // maka body harus di-encode seperti ini:
              // 'Content-Type': 'application/json',
              // body: jsonEncode({ ...data... }),
            },
            body: {
              'name': nameController.text,
              'email': emailController.text,
              'password': passwordController.text,
              'password_confirmation':
                  passwordController
                      .text, // Penting untuk validasi 'confirmed' di Laravel
            },
          )
          .timeout(const Duration(seconds: 15)); // Tambahkan timeout

      hideLoadingDialog();

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Berhasil dibuat
        final String token = responseData['token'] ?? 'Token tidak ditemukan';
        final String userName = responseData['user']?['name'] ?? 'Pengguna';

        // TODO: Simpan token dengan aman (misalnya menggunakan flutter_secure_storage)
        // print('Token Registrasi: $token');

        setState(() {
          nameController.clear();
          emailController.clear();
          passwordController.clear();
          // errorMessage sudah null dari reset di awal
        });

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Registrasi Berhasil'),
              content: Text(
                'Akun untuk $userName telah berhasil dibuat. Silakan login untuk melanjutkan.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Tutup dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginPage()),
                    );
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Color(0xFFF46A06)),
                  ),
                ),
              ],
            );
          },
        );
      } else if (response.statusCode == 422) {
        // Error validasi dari Laravel
        String errorMsg =
            responseData['message'] ?? 'Terjadi kesalahan validasi.';
        if (responseData['errors'] != null && responseData['errors'] is Map) {
          Map<String, dynamic> errors = responseData['errors'];
          // Ambil pesan error pertama dari setiap field yang error
          if (errors.containsKey('name') &&
              errors['name'] is List &&
              errors['name'].isNotEmpty) {
            // Tidak ada field error khusus untuk nama di UI Anda saat ini, jadi gabung ke errorMessage
            errorMessage = (errorMessage ?? '') + errors['name'].first + '\n';
          }
          if (errors.containsKey('email') &&
              errors['email'] is List &&
              errors['email'].isNotEmpty) {
            emailErrorText = errors['email'].first;
          }
          if (errors.containsKey('password') &&
              errors['password'] is List &&
              errors['password'].isNotEmpty) {
            passwordErrorText = errors['password'].first;
          }
          // Jika ada error lain yang tidak spesifik fieldnya, tambahkan ke errorMessage
          if (errorMessage == null &&
              emailErrorText == null &&
              passwordErrorText == null) {
            errorMessage = errorMsg; // fallback
          }
        }
        setState(() {}); // Update UI untuk menampilkan pesan error
      } else {
        // Error lain dari server (misal 500, 400, dll)
        setState(() {
          errorMessage =
              responseData['message'] ??
              'Gagal melakukan registrasi. Status: ${response.statusCode}';
        });
      }
    } on SocketException {
      hideLoadingDialog();
      setState(() {
        errorMessage = 'Tidak ada koneksi internet. Periksa jaringan Anda.';
      });
    } on http.ClientException {
      // Menangkap error client http seperti bad host
      hideLoadingDialog();
      setState(() {
        errorMessage =
            'Tidak dapat terhubung ke server. Pastikan URL API benar.';
      });
    } on FormatException {
      // Jika jsonDecode gagal
      hideLoadingDialog();
      setState(() {
        errorMessage = 'Format respons dari server tidak valid.';
      });
    } catch (e) {
      hideLoadingDialog();
      setState(() {
        errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Mengganti perilaku tombol back default untuk keluar dari aplikasi
        // Ini mungkin bukan UX terbaik, pertimbangkan navigasi normal jika ini bukan halaman root
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFBC72A),
        body: SafeArea(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center, // Hapus ini jika ingin logo di atas
            children: [
              // SizedBox(height: MediaQuery.of(context).size.height * 0.05), // Spacer atas
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20.0,
                ), // Padding untuk logo
                child: Image.asset(
                  'lib/assets/images/splashlogodark.png',
                  height: MediaQuery.of(context).size.height * 0.2,
                ), // Ukuran logo responsif
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
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Pusatkan konten form
                      children: [
                        const SizedBox(height: 30),
                        const Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15), // Kurangi sedikit jarak
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
                          'Nama Lengkap', // Ganti dari 'Username' agar lebih jelas
                          controller: nameController,
                          keyboardType: TextInputType.name,
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
                        // passwordErrorText sudah ditangani di dalam _buildTextField (jika mau)
                        // atau bisa ditampilkan terpisah seperti emailErrorText jika desainnya beda
                        if (passwordErrorText != null &&
                            !isPasswordValid) // Tampilkan hanya jika !isPasswordValid
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 0,
                                left: 12,
                                bottom: 5,
                              ),
                              child: Text(
                                passwordErrorText!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
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
                            onPressed: () => registerUser(context),
                            child: const Text(
                              'Register',
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
                            const Text("Already have an account? "),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LoginPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Login Now",
                                style: TextStyle(
                                  color: Color(0xFFF46A06),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
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
    TextInputType keyboardType = TextInputType.text,
  }) {
    // final isUsername = hint.toLowerCase() == 'username' || hint.toLowerCase() == 'nama lengkap';
    final isEmailField = hint.toLowerCase() == 'email';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(
            vertical: 8,
          ), // Kurangi margin vertikal sedikit
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
            keyboardType: keyboardType,
            // Hapus inputFormatters untuk username jika tidak ada batasan spesifik
            // inputFormatters: isUsername
            //     ? [
            //         FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')), // Izinkan spasi untuk nama
            //         LengthLimitingTextInputFormatter(50), // Sesuaikan panjang nama
            //       ]
            //     : null,
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
                borderSide: const BorderSide(
                  color: Color(0xFFF46A06),
                  width: 1,
                ),
              ),
              suffixIcon:
                  isPassword
                      ? IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
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
        ),
        if (isEmailField && emailErrorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 0, bottom: 5),
            child: Text(
              emailErrorText!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        // Tidak perlu menampilkan passwordErrorText di sini jika sudah ditampilkan di atas
        // atau jika Anda ingin menampilkannya di bawah field password secara spesifik
      ],
    );
  }
}
