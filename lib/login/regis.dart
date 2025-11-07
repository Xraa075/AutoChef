import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // FUNGSI INI DIPERBARUI
  Future<void> registerUser(BuildContext context) async {
    setState(() {
      apiErrorMessage = null;
    });

    if (_formKey.currentState!.validate()) {
      showLoadingDialog();
      
      // Memanggil fungsi register dari api_login.dart
      final response = await register(
        nameController.text,
        emailController.text,
        passwordController.text,
        confirmPasswordController.text,
      );

      hideLoadingDialog();

      if (response['status'] == 'success') {
        // Logika sukses, mengambil data dari respons
        Map<String, dynamic>? responseData = response['data'];
        final String userName =
            responseData?['user']?['name'] ?? nameController.text;
        
        setState(() {
          nameController.clear();
          emailController.clear();
          passwordController.clear();
          confirmPasswordController.clear();
          _formKey.currentState?.reset();
        });

        // Tampilkan dialog sukses (logika ini sama seperti sebelumnya)
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              title: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFFF46A06),
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Registrasi Berhasil',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Text(
                'Akun untuk $userName telah berhasil dibuat. Silakan login.',
                style: const TextStyle(fontSize: 16),
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      backgroundColor: const Color(0xFFF46A06),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => LoginPage()),
                      );
                    },
                    child: const Text(
                      'Oke',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      } else {
        // Jika gagal, tampilkan pesan error dari api_login.dart
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
    // ... Sisa build method tidak berubah ...
    // (Kode UI tetap sama)
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
    // ... Sisa buildTextFormField method tidak berubah ...
    // (Kode UI tetap sama)
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        obscureText:
            isPassword
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
          suffixIcon:
              isPassword
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