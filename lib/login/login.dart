import 'package:shared_preferences/shared_preferences.dart';
import 'package:autochef/widgets/navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'regis.dart';
import '../services/api_login.dart';

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
    if (value.length > 30) {
      return 'Email maksimal 30 karakter';
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
    if (value.length < 8) {
      return 'Password minimal 8 karakter';
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

      debugPrint('Mencoba login dengan email: $email');

      showLoadingDialog();
      
      final response = await login(email, password);

      hideLoadingDialog();
      if (!mounted) return;

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
            userDataFromApi?['userImage'] ??
                userDataFromApi?['profile_photo_path'] ??
                'lib/assets/images/avatar1.png',
          );

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
      } else {
        String errorMessage =
            response['message'] ?? 'Terjadi kesalahan tidak diketahui.';
        if (errorMessage.toLowerCase().contains('verifikasi') || 
            errorMessage.toLowerCase().contains('unverified')) {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
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
                          'Email Belum Diverifikasi',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          (errorMessage.length > 10 && errorMessage.length < 100) 
                            ? errorMessage 
                            : 'Silakan cek email Anda untuk melakukan verifikasi akun.',
                          style: const TextStyle(fontSize: 16),
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
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2)
                          ),
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
              );
            },
          );
        } else {
          setState(() {
            apiErrorMessage = errorMessage;
          });
        }
      }
    } else {
      setState(() {
        apiErrorMessage = "Harap perbaiki semua kesalahan pada form.";
      });
    }
  }

@override
void didChangeDependencies() {
  super.didChangeDependencies();

  // Tangkap argumen dari deep link (jika ada)
  final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

  if (args?['verified'] == true) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '✅ Email kamu berhasil diverifikasi! Silakan login untuk melanjutkan.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFFF46A06),
          duration: Duration(seconds: 4),
        ),
      );
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
                              LengthLimitingTextInputFormatter(30),
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
                          const SizedBox(height: 60),
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