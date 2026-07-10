import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:autochef/services/lupa_password_service.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final LupaPasswordService _apiService = LupaPasswordService();

  bool _isLoading = false;
  bool _isResending = false; 
  String? _errorMessage;
  String _userEmail = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Mengambil data email dari arguments rute yang dikirim lupa_password.dart
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args.isNotEmpty) {
      _userEmail = args;
      debugPrint('Email berhasil diterima di OtpPage: $_userEmail');
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _verifyOtp() async {
    String otpCode = _controllers.map((controller) => controller.text).join();
    
    if (otpCode.length < 6) {
      setState(() {
        _errorMessage = 'Silakan masukkan 6 digit kode OTP dengan lengkap';
      });
      return;
    }

    // Proteksi validasi email kosong
    if (_userEmail.isEmpty) {
      setState(() {
        _errorMessage = 'Email tidak ditemukan, silakan kembali ke halaman sebelumnya';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _apiService.verifyOtp(_userEmail, otpCode);

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

      String resetToken = result['reset_token'] ?? '';
      debugPrint('Reset Token didapatkan: $resetToken');

      Navigator.pushNamed(
        context, 
        '/reset-password', 
        arguments: {
          'token': resetToken,
          'email': _userEmail,
        },
      );
    } else {
      setState(() {
        _errorMessage = result['message'];
      });
    }
  }

  void _resendOtpCode() async {
    if (_userEmail.isEmpty) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mengirim ulang kode OTP...'),
        backgroundColor: Color(0xFFF46A06),
        duration: Duration(seconds: 1),
      ),
    );

    final result = await _apiService.sendForgotPassword(_userEmail);

    setState(() {
      _isResending = false;
    });

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Kode OTP baru berhasil dikirim ke email Anda!'),
          backgroundColor: const Color(0xFFF46A06),
        ),
      );
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Verifikasi OTP",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Masukkan 6 digit kode yang telah dikirimkan ke alamat email Anda.",
                style: TextStyle(
                  fontSize: 14, 
                  color: Colors.grey, 
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),
              
              // OTP Input Fields (6 Digit)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 43,
                    height: 55,
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.text,
                      textAlign: TextAlign.center,
                      enabled: !_isLoading && !_isResending,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                      ],
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          if (index < 5) {
                            FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                          } else {
                            _focusNodes[index].unfocus();
                          }
                        } else {
                          if (index > 0) {
                            FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
                          }
                        }
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFF46A06), width: 2),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1.5),
                        ),
                      ),
                    ),
                  );
                }),
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
              
              const SizedBox(height: 40),
              
              // Tombol Verifikasi
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: (_isLoading || _isResending) ? null : _verifyOtp,
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
                          "Verifikasi",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Teks Kirim Ulang
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Tidak menerima kode? ",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: (_isLoading || _isResending) ? null : _resendOtpCode,
                    child: Text(
                      _isResending ? "Mengirim..." : "Kirim Ulang",
                      style: TextStyle(
                        color: (_isLoading || _isResending) ? Colors.grey : const Color(0xFFF46A06),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}