import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'login.dart';

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

  bool isUsernameValid = true;
  bool isPasswordValid = true;
  bool _obscurePassword = true; // Tambahan: kontrol visibilitas password

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
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Future<void> registerUser(BuildContext context) async {
    if (nameController.text.isEmpty) {
      setState(() {
        errorMessage = 'Username tidak boleh kosong';
      });
      return;
    }
    if (emailController.text.isEmpty) {
      setState(() {
        errorMessage = 'Email tidak boleh kosong';
      });
      return;
    }
    if (passwordController.text.isEmpty) {
      setState(() {
        errorMessage = 'Password tidak boleh kosong';
      });
      return;
    }

    setState(() {
      isUsernameValid =
          nameController.text.isNotEmpty &&
          !nameController.text.contains(' ') &&
          nameController.text.length <= 10;

      isPasswordValid = passwordController.text.length >= 5;
      passwordErrorText =
          isPasswordValid ? null : 'Password minimal 5 karakter';
    });

    if (!isUsernameValid || !isPasswordValid) return;

    showLoadingDialog();
    try {
      final response = await http.post(
        Uri.parse('http://156.67.214.60/api/register'),
        headers: {'Accept': 'application/json'},
        body: {
          'name': nameController.text,
          'email': emailController.text,
          'password': passwordController.text,
        },
      );
      hideLoadingDialog();
      if (response.statusCode == 200) {
        setState(() {
          errorMessage = 'Registrasi berhasil, silahkan login dengan akun anda';
          nameController.clear();
          emailController.clear();
          passwordController.clear();
          passwordErrorText = null;
        });
      } else if (response.statusCode == 422) {
        final responseData = jsonDecode(response.body);
        final errorMessage =
            responseData['errors']['email']?.first ?? 'Gagal registrasi';
        setState(() {
          this.errorMessage = errorMessage;
        });
      } else {
        setState(() {
          errorMessage = 'Gagal: ${response.body}';
        });
      }
    } on SocketException {
      hideLoadingDialog();
      setState(() {
        errorMessage = 'Tidak ada koneksi internet. Periksa jaringan Anda.';
      });
    } catch (e) {
      hideLoadingDialog();
      setState(() {
        errorMessage = 'Terjadi kesalahan tak terduga: $e';
      });
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
              Image.asset('lib/assets/images/splashlogodark.png', height: 200),
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
                      children: [
                        const SizedBox(height: 30),
                        const Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              errorMessage!,
                              style: TextStyle(
                                color: errorMessage ==
                                        'Registrasi berhasil, silahkan login dengan akun anda'
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          'Username',
                          controller: nameController,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9]'),
                            ),
                            LengthLimitingTextInputFormatter(10),
                          ],
                        ),
                        _buildTextField('Email', controller: emailController),
                        _buildTextField(
                          'Password',
                          controller: passwordController,
                          isPassword: true,
                        ),
                        if (passwordErrorText != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 12),
                            child: Text(
                              passwordErrorText!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
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
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
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
        inputFormatters: inputFormatters,
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
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
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
