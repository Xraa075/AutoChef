import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiProfile {
  static const String baseUrl = 'http://156.67.214.60/api';

  // Mendapatkan token dari SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Update avatar - khusus untuk menyimpan avatar secara lokal
  static Future<Map<String, dynamic>> updateAvatar(String avatar) async {
    try {
      if (avatar.isEmpty) {
        return {'success': false, 'message': 'Avatar tidak boleh kosong'};
      }

      // Simpan avatar hanya secara lokal karena tidak ada di database
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userImage', avatar);

      return {'success': true, 'message': 'Avatar berhasil diperbarui'};
    } catch (e) {
      debugPrint('Error update avatar: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat memperbarui avatar: $e',
      };
    }
  }

  // Update profil pengguna
  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    String? avatar,
  }) async {
    try {
      // Cek dulu apakah user adalah guest
      final prefs = await SharedPreferences.getInstance();
      bool isGuest = prefs.getBool('hasLoggedAsGuest') ?? false;
      bool isUser = prefs.getBool('hasLoggedAsUser') ?? false;

      // Jika user adalah guest, kembalikan pesan untuk login
      if (isGuest && !isUser) {
        return {
          'success': false,
          'message': 'Silahkan login terlebih dahulu untuk menyimpan perubahan',
          'isGuest': true,
        };
      }

      final token = await getToken();

      // Debug info
      debugPrint('Token: ${token != null ? "Valid" : "Null"}');
      debugPrint('Updating profile: name=$name, email=$email');

      // Jika ada token, coba update ke API
      if (token != null) {
        try {
          final url = Uri.parse('$baseUrl/update-profile');

          // PERBAIKAN: Format request body dan headers
          final response = await http
              .post(
                url,
                headers: {
                  'Accept': 'application/json',
                  'Authorization': 'Bearer $token',
                  'Content-Type':
                      'application/x-www-form-urlencoded', // Menggunakan format Laravel standar
                },
                body: {
                  // Tidak menggunakan jsonEncode untuk x-www-form-urlencoded
                  'name': name,
                  'email': email,
                },
              )
              .timeout(const Duration(seconds: 15));

          // Debug response
          debugPrint('Response status: ${response.statusCode}');
          debugPrint('Response body: ${response.body}');

          if (response.statusCode == 200 || response.statusCode == 201) {
            // Jika API berhasil, simpan data ke SharedPreferences
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('username', name);
            await prefs.setString('email', email);

            // Jika avatar disediakan, simpan secara lokal
            if (avatar != null && avatar.isNotEmpty) {
              await prefs.setString('userImage', avatar);
            }

            // Decode response body
            Map<String, dynamic> responseData = {};
            if (response.body.isNotEmpty) {
              try {
                responseData = jsonDecode(response.body);
              } catch (e) {
                debugPrint('Error parsing response: $e');
              }
            }

            return {
              'success': true,
              'message':
                  responseData['message'] ?? 'Profil berhasil diperbarui',
            };
          } else {
            // Coba parse response error
            String errorMessage =
                'Gagal memperbarui profil (${response.statusCode})';
            Map<String, dynamic> responseData = {};
            try {
              responseData = jsonDecode(response.body);
              if (responseData.containsKey('message')) {
                errorMessage = responseData['message'];
              } else if (responseData.containsKey('errors')) {
                final errors = responseData['errors'];
                if (errors is Map && errors.isNotEmpty) {
                  errorMessage = errors.values.first[0] ?? errorMessage;
                }
              }
            } catch (e) {
              debugPrint('Error parsing error response: $e');
            }

            return {
              'success': false,
              'message': errorMessage,
              'statusCode': response.statusCode,
              'responseBody': response.body,
            };
          }
        } catch (e) {
          // Error koneksi API
          debugPrint('API update failed: $e');

          // Dalam kasus error koneksi, simpan secara lokal
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('username', name);
          await prefs.setString('email', email);

          if (avatar != null && avatar.isNotEmpty) {
            await prefs.setString('userImage', avatar);
          }

          return {
            'success': true,
            'message':
                'Profil berhasil disimpan secara lokal, tetapi tidak tersimpan ke server. Cek koneksi internet Anda.',
            'isOffline': true,
          };
        }
      } else {
        // Mode offline (tidak ada token)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', name);
        await prefs.setString('email', email);

        if (avatar != null && avatar.isNotEmpty) {
          await prefs.setString('userImage', avatar);
        }

        return {
          'success': false,
          'message':
              'Token tidak ditemukan. Silakan login kembali untuk menyimpan ke server.',
          'isOffline': true,
        };
      }
    } catch (e) {
      debugPrint('Error update profile: $e');
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // Mengubah password pengguna
  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // Validasi password
      if (newPassword.isEmpty || newPassword.length < 5) {
        return {
          'success': false,
          'message': 'Password baru minimal 5 karakter',
        };
      }

      final token = await getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak tersedia, silakan login kembali',
        };
      }

      final url = Uri.parse('$baseUrl/change-password');

      final response = await http
          .post(
            url,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'current_password': currentPassword,
              'password': newPassword,
              'password_confirmation': newPassword,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Password berhasil diubah',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Gagal mengubah password',
          'errors': responseData['errors'],
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  // Verifikasi apakah user login dan token valid
  static Future<Map<String, dynamic>> verifyLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        return {'loggedIn': false, 'message': 'User tidak login'};
      }

      try {
        final url = Uri.parse('$baseUrl/user');
        final response = await http
            .get(
              url,
              headers: {
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
              },
            )
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          return {
            'loggedIn': true,
            'message': 'Token valid',
            'user': jsonDecode(response.body),
          };
        } else {
          return {'loggedIn': false, 'message': 'Token tidak valid'};
        }
      } catch (e) {
        return {
          'loggedIn': true, // Assume logged in if network error
          'message': 'Tidak dapat memverifikasi login: $e',
          'error': e.toString(),
        };
      }
    } catch (e) {
      return {'loggedIn': false, 'message': 'Error checking login status: $e'};
    }
  }

  // Tambahkan fungsi baru
  static Future<bool> checkAndRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // Tambahkan cek guest
      final isGuest = prefs.getBool('hasLoggedAsGuest') ?? false;
      final isUser = prefs.getBool('hasLoggedAsUser') ?? false;

      // Jika guest, langsung return false
      if (isGuest && !isUser) {
        debugPrint('User is guest, no token needed');
        return true; // Return true karena kita akan handle di updateProfile
      }

      debugPrint(
        'Checking token: ${token != null ? token.substring(0, 10) + "..." : "null"}',
      );

      if (token == null || token.isEmpty) {
        debugPrint('Token is null or empty');
        return false;
      }

      // Rest of the code...

      // Coba validasi token dengan hit endpoint sederhana
      try {
        final url = Uri.parse('$baseUrl/user');
        final response = await http
            .get(
              url,
              headers: {
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
              },
            )
            .timeout(const Duration(seconds: 5));

        debugPrint('Token validation response: ${response.statusCode}');

        if (response.statusCode == 200) {
          return true;
        } else if (response.statusCode == 401) {
          // Token tidak valid, hapus
          await prefs.remove('token');
          debugPrint('Token invalid, removing from storage');
          return false;
        }

        // Default fallback - asumsikan token valid jika tidak 401
        return true;
      } catch (e) {
        // Jika terjadi kesalahan koneksi, anggap token valid (benefit of doubt)
        debugPrint('Connection error when validating token: $e');
        return true;
      }
    } catch (e) {
      debugPrint('Error checking token: $e');
      return false;
    }
  }

  // Logout pengguna
  static Future<Map<String, dynamic>> logout() async {
    try {
      final token = await getToken();

      if (token != null) {
        try {
          final url = Uri.parse('$baseUrl/logout');
          final response = await http
              .post(
                url,
                headers: {
                  'Accept': 'application/json',
                  'Authorization': 'Bearer $token',
                },
              )
              .timeout(const Duration(seconds: 10));

          // Analisis response jika perlu
        } catch (e) {
          // Abaikan error API, tetap lanjut ke logout lokal
          debugPrint('API logout failed: $e');
        }
      }

      // Hapus data lokal
      await _clearLocalData();

      return {'success': true, 'message': 'Berhasil logout'};
    } catch (e) {
      // Tetap coba hapus data lokal
      try {
        await _clearLocalData();
        return {'success': true, 'message': 'Berhasil logout (offline)'};
      } catch (_) {
        return {'success': false, 'message': 'Gagal logout: $e'};
      }
    }
  }

  // Helper method untuk menghapus data lokal
  static Future<void> _clearLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasLoggedAsGuest', false);
    await prefs.setBool('hasLoggedAsUser', false);
    await prefs.remove('username');
    await prefs.remove('email');
    await prefs.remove('userImage');
    await prefs.remove('token');
  }
}
