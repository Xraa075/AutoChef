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
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? apiErrorMessage;

  bool _obscurePassword = true;

  final emailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void showLoadingDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFFF46A06)),
        );
      },
    );
  }

  void hideLoadingDialog() {
    if (!mounted) return;
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  String? _validateEmailLogin(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? _validatePasswordLogin(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 5) {
      return 'Password minimal 5 karakter';
    }
    return null;
  }

  Future<void> loginUser() async {
    setState(() {
      apiErrorMessage = null;
    });

    if (_formKey.currentState!.validate()) {
      String email = emailController.text.trim();
      String password = passwordController.text;

      showLoadingDialog();
      try {
        final response = await http
            .post(
              Uri.parse('http://156.67.214.60/api/login'),
              headers: {'Accept': 'application/json'},
              body: {'email': email, 'password': password},
            )
            .timeout(const Duration(seconds: 20));

        Map<String, dynamic>? responseData;
        try {
          if (response.body.isNotEmpty) {
            responseData = jsonDecode(response.body);
          }
        } catch (e) {
          hideLoadingDialog();
          if (mounted) {
            setState(() {
              apiErrorMessage = 'Format respons dari server tidak valid.';
            });
          }
          return;
        }

        hideLoadingDialog();

        if (!mounted) return;

        if (response.statusCode == 200 && responseData != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String? token = responseData['token'];
          Map<String, dynamic>? userData = responseData['user'];

          if (token != null && userData != null) {
            await prefs.setBool('hasLoggedAsUser', true);
            await prefs.setBool('hasLoggedAsGuest', false);
            await prefs.setString('username', userData['name'] ?? 'Pengguna');
            await prefs.setString('email', userData['email'] ?? '');
            await prefs.setString('token', token);
            await prefs.setString('userImage', 'lib/assets/images/avatar1.png');

            emailController.clear();
            passwordController.clear();
            _formKey.currentState?.reset();

            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const Navbar()),
                (route) => false,
              );
            }
          } else {
            setState(() {
              apiErrorMessage = 'Respons login tidak lengkap dari server.';
            });
          }
        } else if (response.statusCode == 401 && responseData != null) {
          setState(() {
            apiErrorMessage =
                responseData?['message'] ?? 'Email atau password salah.';
          });
        } else {
          String messageFromServer = "Gagal login.";
          if (responseData != null && responseData.containsKey('message')) {
            messageFromServer = responseData['message'];
          } else if (response.body.isNotEmpty) {
            // Jika tidak ada 'message' tapi body tidak kosong, tampilkan body (mungkin error HTML atau teks)
            // Ini kurang ideal, tapi lebih baik daripada tidak ada info.
            // Batasi panjangnya agar tidak terlalu besar.
            messageFromServer =
                response.body.length > 100
                    ? response.body.substring(0, 100) + "..."
                    : response.body;
          }
          setState(() {
            apiErrorMessage =
                '$messageFromServer (Status: ${response.statusCode})';
          });
        }
      } on SocketException {
        hideLoadingDialog();
        if (mounted)
          setState(() {
            apiErrorMessage = 'Tidak ada koneksi internet.';
          });
      } on TimeoutException {
        hideLoadingDialog();
        if (mounted)
          setState(() {
            apiErrorMessage = 'Koneksi ke server terputus atau terlalu lama.';
          });
      } on http.ClientException {
        hideLoadingDialog();
        if (mounted)
          setState(() {
            apiErrorMessage = 'Tidak dapat terhubung ke server.';
          });
      } on FormatException {
        hideLoadingDialog();
        if (mounted)
          setState(() {
            apiErrorMessage = 'Format respons server tidak valid.';
          });
      } catch (e) {
        hideLoadingDialog();
        if (mounted)
          setState(() {
            apiErrorMessage = 'Terjadi kesalahan: ${e.toString()}';
          });
        debugPrint('Error saat login: $e');
      }
    } else {
      setState(() {
        apiErrorMessage = "Harap perbaiki semua kesalahan pada form.";
      });
    }
  }

  Future<void> loginAsGuest(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasLoggedAsGuest', true);
    await prefs.setBool('hasLoggedAsUser', false);
    await prefs.remove('username');
    await prefs.remove('email');
    await prefs.remove('token');
    await prefs.remove('userImage');

    if (mounted) {
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
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Image.asset(
                  'lib/assets/images/splashlogodark.png',
                  height: MediaQuery.of(context).size.height * 0.22,
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
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
                          if (apiErrorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: 10.0,
                                left: 8.0,
                                right: 8.0,
                              ),
                              child: Text(
                                apiErrorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                                softWrap: true,
                              ),
                            ),
                          _buildTextFormField(
                            hint: 'Email',
                            controller: emailController,
                            validator: _validateEmailLogin,
                            keyboardType: TextInputType.emailAddress,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(20),
                            ],
                          ),
                          _buildTextFormField(
                            hint: 'Password',
                            controller: passwordController,
                            validator: _validatePasswordLogin,
                            isPassword: true,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z0-9]'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF46A06),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
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
                                      builder: (_) => RegisterPage(),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required String hint,
    required TextEditingController controller,
    required String? Function(String?) validator,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        obscureText: isPassword ? _obscurePassword : false,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Colors.grey, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Colors.grey, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFF46A06), width: 1),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          errorStyle: const TextStyle(fontSize: 12, height: 1),
          errorMaxLines: 2,
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
    );
  }
}
