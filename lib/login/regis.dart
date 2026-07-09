// (MODIFIKASI) regis.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autochef/widgets/navbar.dart';
import 'login.dart';
import '../services/api_login.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String? apiErrorMessage;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isGoogleLoading = false;

  final emailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  @override
  void initState() {
    super.initState();
    passwordController.addListener(_validateConfirmPasswordOnPasswordChange);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.removeListener(_validateConfirmPasswordOnPasswordChange);
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateConfirmPasswordOnPasswordChange() {
    if (confirmPasswordController.text.isNotEmpty) {
      _formKey.currentState?.validate();
    }
  }

  void showLoadingDialog() {
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
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username tidak boleh kosong';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }

    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value.length < 8) {
      return 'Konfirmasi password minimal 8 karakter';
    }
    if (value != passwordController.text) {
      return 'Password dan Konfirmasi Password tidak cocok';
    }
    return null;
  }

  Future<void> loginWithGoogleUser() async {
    setState(() {
      apiErrorMessage = null;
      _isGoogleLoading = true;
    });

    final response = await loginWithGoogle();

    if (!mounted) return;
    setState(() {
      _isGoogleLoading = false;
    });

    if (response['status'] == 'cancelled') {
      return;
    }

    if (response['status'] == 'success') {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Map<String, dynamic>? responseData = response['data'];
      String? token = responseData?['access_token'];
      Map<String, dynamic>? userDataFromApi = responseData?['user'];

      if (token != null) {
        await prefs.setBool('hasLoggedAsUser', true);
        await prefs.setString('token', token);
        await prefs.setString(
          'username',
          userDataFromApi?['name'] ?? 'Pengguna',
        );
        await prefs.setString('email', userDataFromApi?['email'] ?? '');
        await prefs.setString(
          'userImage',
          userDataFromApi?['profile_photo_url'] ??
              userDataFromApi?['profile_photo_path'] ??
              'lib/assets/images/avatar1.png',
        );

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
    } else {
      setState(() {
        apiErrorMessage = response['message'] ?? 'Gagal daftar dengan Google.';
      });
    }
  }

  Future<void> registerUser(BuildContext context) async {
    setState(() {
      apiErrorMessage = null;
    });

    if (_formKey.currentState!.validate()) {
      showLoadingDialog();
      final response = await register(
        nameController.text,
        emailController.text,
        passwordController.text,
        confirmPasswordController.text,
      );

      hideLoadingDialog();

      if (response['status'] == 'success') {
        setState(() {
          nameController.clear();
          emailController.clear();
          passwordController.clear();
          confirmPasswordController.clear();
          _formKey.currentState?.reset();
        });

        showDialog(
          context: context,
          barrierDismissible: false,
          // (MODIFIKASI 1) Ganti nama 'context' di sini menjadi 'dialogContext'
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: const EdgeInsets.all(20),
              content: Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 15),
                      const Icon(
                        Icons.mark_email_read_outlined,
                        color: Color(0xFFF46A06),
                        size: 48,
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Verifikasi Email Anda',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'silahkan cek gmail anda untuk verifikasi',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                  Positioned(
                    top: -18.0,
                    right: -18.0,
                    child: GestureDetector(
                      onTap: () {
                        // (MODIFIKASI 2) Gunakan 'dialogContext' untuk menutup dialog
                        Navigator.of(dialogContext).pop();
                        // (MODIFIKASI 3) Gunakan 'context' (milik halaman) untuk navigasi
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => LoginPage()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2)),
                        child: const Icon(
                          Icons.close,
                          color: Colors.black54,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              actions: null,
            );
          },
        );
      } else {
        setState(() {
          apiErrorMessage =
              response['message'] ?? 'Terjadi kesalahan tidak diketahui.';
        });
      }
    } else {
      setState(() {
        apiErrorMessage = "Harap perbaiki semua kesalahan pada form.";
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
                          const SizedBox(height: 25),
                          const Text(
                            'Register',
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
                            hint: 'Username',
                            controller: nameController,
                            validator: _validateUsername,
                            keyboardType: TextInputType.text,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z0-9]'),
                              ),
                              FilteringTextInputFormatter.deny(RegExp(r'[ ]')),
                              LengthLimitingTextInputFormatter(10),
                            ],
                          ),
                          _buildTextFormField(
                            hint: 'Email',
                            controller: emailController,
                            validator: _validateEmail,
                            keyboardType: TextInputType.emailAddress,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(30),
                            ],
                          ),
                          _buildTextFormField(
                            hint: 'Password',
                            controller: passwordController,
                            validator: _validatePassword,
                            isPassword: true,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z0-9]'),
                              ),
                            ],
                          ),
                          _buildTextFormField(
                            hint: 'Confirm Password',
                            controller: confirmPasswordController,
                            validator: _validateConfirmPassword,
                            isPassword: true,
                            isConfirmField: true,
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
                          const SizedBox(height: 16),
                          // --- Divider "atau" ---
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.grey[300],
                                  thickness: 1,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'atau',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.grey[300],
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // --- Tombol Google Sign-In ---
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.grey),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                backgroundColor: Colors.white,
                              ),
                              onPressed: _isGoogleLoading ? null : loginWithGoogleUser,
                              icon: _isGoogleLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFFF46A06),
                                      ),
                                    )
                                  : Image.network(
                                      'https://www.google.com/favicon.ico',
                                      height: 20,
                                      width: 20,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.g_mobiledata, size: 24, color: Colors.red),
                                    ),
                              label: Text(
                                _isGoogleLoading ? 'Menghubungkan...' : 'Daftar dengan Google',
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
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
    bool isConfirmField = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        obscureText: isPassword
            ? (isConfirmField ? _obscureConfirmPassword : _obscurePassword)
            : false,
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
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    (isConfirmField
                            ? _obscureConfirmPassword
                            : _obscurePassword)
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isConfirmField) {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      } else {
                        _obscurePassword = !_obscurePassword;
                      }
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}