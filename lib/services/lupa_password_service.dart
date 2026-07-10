import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';

class LupaPasswordService {
  final String baseUrlForgot = 'http://100.120.18.38:8080/api/forgot-password';
  final String baseUrlVerify = 'http://100.120.18.38:8080/api/verify-otp';
  final String baseUrlReset = 'http://100.120.18.38:8080/api/reset-password';

  // Fungsi untuk Kirim Email (Forgot Password)
  Future<Map<String, dynamic>> sendForgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrlForgot),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          'email': email,
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {
          'success': true,
          'message': responseData['message'] ?? 'OTP berhasil dikirim',
        };
      } else {
        final errorData = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {
          'success': false,
          'message': errorData['message'] ?? 'Terjadi kesalahan sistem',
        };
      }
    } on SocketException {
      return {'success': false, 'message': 'Tidak ada koneksi internet.'};
    } on TimeoutException {
      return {'success': false, 'message': 'Koneksi ke server timeout.'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server'};
    }
  }

  // Fungsi untuk Verifikasi Kode OTP
  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrlVerify),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          'email': email,
          'otp': otp,
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {
          'success': true,
          'message': responseData['message'] ?? 'OTP berhasil diverifikasi.',
          'reset_token': responseData['reset_token'],
        };
      } else {
        final errorData = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {
          'success': false,
          'message': errorData['message'] ?? 'Kode OTP salah atau kedaluwarsa',
        };
      }
    } on SocketException {
      return {'success': false, 'message': 'Tidak ada koneksi internet.'};
    } on TimeoutException {
      return {'success': false, 'message': 'Koneksi ke server timeout.'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server'};
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrlReset),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          'email': email,
          'token': token,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {
          'success': true,
          'message': responseData['message'] ?? 'Password berhasil diperbarui!',
        };
      } else {
        final errorData = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {
          'success': false,
          'message': errorData['message'] ?? 'Gagal memperbarui password',
        };
      }
    } on SocketException {
      return {'success': false, 'message': 'Tidak ada koneksi internet.'};
    } on TimeoutException {
      return {'success': false, 'message': 'Koneksi ke server timeout.'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server'};
    }
  }
}