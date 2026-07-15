import 'package:flutter/material.dart';
import 'package:autochef/services/lupa_password_service.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final LupaPasswordService _apiService = LupaPasswordService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  String _resetToken = '';
  String _userEmail = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Mengambil argumen token dan email yang dipassing dari halaman OTP
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _resetToken = args['token'] ?? '';
      _userEmail = args['email'] ?? '';
      debugPrint('ResetPasswordPage menerima email: $_userEmail');
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_userEmail.isEmpty || _resetToken.isEmpty) {
      setState(() {
        _errorMessage = 'Data verifikasi kedaluwarsa. Silakan ulangi proses dari awal.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Hit API reset password membawa data sesuai dengan SS Postman Anda
    final result = await _apiService.resetPassword(
      email: _userEmail,
      token: _resetToken,
      password: passwordController.text,
      passwordConfirmation: confirmPasswordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: const Color(0xFFF46A06),
        ),
      );

      // Setelah sukses, arahkan user kembali ke halaman login dan hapus tumpukan halaman lama
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } else {
      setState(() {
        _errorMessage = result['message'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Reset Password",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Field Password Baru
                TextFormField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Password baru tidak boleh kosong";
                    }
                    if (value.length < 8) {
                      return "Password minimal 8 karakter";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Password Baru",
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
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
                  ),
                ),
                const SizedBox(height: 20),
                
                // Field Konfirmasi Password Baru
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Konfirmasi password tidak boleh kosong";
                    }
                    if (value != passwordController.text) {
                      return "Konfirmasi password tidak cocok";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Konfirmasi Password Baru",
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
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
                  ),
                ),
                
                const SizedBox(height: 8),
                const Text(
                  "Buat password baru untuk akunmu",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                
                const SizedBox(height: 30),
                
                // Tombol Simpan
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitResetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF46A06),
                      disabledBackgroundColor: const Color(0xFFF46A06).withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Simpan",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}