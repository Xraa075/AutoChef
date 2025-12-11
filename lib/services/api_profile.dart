import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class ApiProfile {
  static const String baseUrl = 'http://100.120.18.38:8080/api';

  // Mendapatkan token dari SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // --- BARU: Mengambil Data Profile (GET /profile) ---
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      // Endpoint sesuai request: /api/profile
      final url = Uri.parse('$baseUrl/profile');
      
      debugPrint('GET Profile URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      debugPrint('Response Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Parsing respons sesuai format JSON baru
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data, // data berisi {id, name, email, ...}
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal mengambil data profil',
        };
      }
    } catch (e) {
      debugPrint('Error getProfile');
      return {'success': false, 'message': 'Terjadi kesalahan'};
    }
  }

  // Update avatar - khusus untuk menyimpan avatar secara lokal
  static Future<Map<String, dynamic>> updateAvatar(String avatar) async {
    try {
      if (avatar.isEmpty) {
        return {'success': false, 'message': 'Avatar tidak boleh kosong'};
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userImage', avatar);

      return {'success': true, 'message': 'Avatar berhasil diperbarui'};
    } catch (e) {
      debugPrint('Error update avatar');
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat memperbarui avatar',
      };
    }
  }

  static Future<Map<String, dynamic>> uploadProfilePhoto(File imageFile) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      final url = Uri.parse('$baseUrl/profile/photo');
      debugPrint('Uploading photo to: $url');

      var request = http.MultipartRequest('POST', url);
      
      // Header Authorization
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Attach File (Asumsi key-nya adalah 'photo' atau 'image', biasanya 'photo' di Laravel Jetstream/Default)
      // Jika backend minta key lain (misal 'file'), ganti 'photo' di bawah ini.
      request.files.add(await http.MultipartFile.fromPath(
        'photo', 
        imageFile.path,
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Upload Response: ${response.statusCode}');
      debugPrint('Upload Body: ${response.body}');

      if (response.statusCode == 200) {
        // Biasanya return URL baru atau object user baru
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data, // Berharap ada field 'profile_photo_url' disini
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal upload foto. Status: ${response.statusCode}'
        };
      }
    } catch (e) {
      debugPrint('Error upload photo: $e');
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // Update profil pengguna
  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    String? avatar,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool isGuest = prefs.getBool('hasLoggedAsGuest') ?? false;
      bool isUser = prefs.getBool('hasLoggedAsUser') ?? false;

      if (isGuest && !isUser) {
        return {
          'success': false,
          'message': 'Silahkan login terlebih dahulu untuk menyimpan perubahan',
          'isGuest': true,
        };
      }

      final token = await getToken();

      if (token != null) {
        try {
          // Asumsi endpoint update masih menggunakan update-profile atau disesuaikan nanti
          final url = Uri.parse('$baseUrl/update-profile'); 

          final response = await http
              .post(
                url,
                headers: {
                  'Accept': 'application/json',
                  'Authorization': 'Bearer $token',
                  // Jika backend Laravel standar resource, biasanya perlu content-type json atau x-www-form
                  'Content-Type': 'application/x-www-form-urlencoded', 
                },
                body: {
                  'name': name,
                  'email': email,
                },
              )
              .timeout(const Duration(seconds: 15));

          if (response.statusCode == 200 || response.statusCode == 201) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('name', name);
            await prefs.setString('email', email);

            if (avatar != null && avatar.isNotEmpty) {
              await prefs.setString('userImage', avatar);
            }

            return {
              'success': true,
              'message': 'Profil berhasil diperbarui',
            };
          } else {
            return {
              'success': false,
              'message': 'Gagal memperbarui profil ke server.',
            };
          }
        } catch (e) {
          debugPrint('API update failed');
          // Fallback offline save
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('name', name); // <--- Kunci diubah ke 'name'
          await prefs.setString('email', email);
          if (avatar != null && avatar.isNotEmpty) {
            await prefs.setString('userImage', avatar);
          }
          return {
            'success': true,
            'message': 'Profil disimpan lokal (Offline).',
            'isOffline': true,
          };
        }
      } else {
        // Offline / No Token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('name', name);
        await prefs.setString('email', email);
        if (avatar != null && avatar.isNotEmpty) {
          await prefs.setString('userImage', avatar);
        }
        return {
          'success': false,
          'message': 'Token tidak ditemukan. Disimpan lokal.',
          'isOffline': true,
        };
      }
    } catch (e) {
      debugPrint('Error update profile');
      return {'success': false, 'message': 'Terjadi kesalahan'};
    }
  }

  // Mengubah password pengguna
  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    debugPrint('Fitur Change Password dipanggil tapi sedang dinonaktifkan.');

    await Future.delayed(const Duration(milliseconds: 500));

    return {
      'success': false,
      'message': 'Fitur ubah password sedang dalam pemeliharaan.',
    };
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
        final url = Uri.parse('$baseUrl/profile');
        
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
          final userData = jsonDecode(response.body);
          
          return {
            'loggedIn': true,
            'message': 'Token valid',
            'user': userData, 
          };
        } else {
          return {'loggedIn': false, 'message': 'Token tidak valid'};
        }
      } catch (e) {
        return {
          'loggedIn': true,
          'message': 'Tidak dapat memverifikasi login (Offline)',
          'error': e.toString(),
        };
      }
    } catch (e) {
      return {'loggedIn': false, 'message': 'Error checking login status'};
    }
  }

  static Future<bool> checkAndRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final isGuest = prefs.getBool('hasLoggedAsGuest') ?? false;
      final isUser = prefs.getBool('hasLoggedAsUser') ?? false;

      if (isGuest && !isUser) return true;

      if (token == null || token.isEmpty) return false;

      try {
        final url = Uri.parse('$baseUrl/profile');
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
          return true;
        } else if (response.statusCode == 401) {
          await prefs.remove('token');
          return false;
        }
        return true;
      } catch (e) {
        return true;
      }
    } catch (e) {
      return false;
    }
  }

  // Logout pengguna
  static Future<Map<String, dynamic>> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        try {
          http.post(
            Uri.parse('$baseUrl/logout'),
            headers: {'Authorization': 'Bearer $token'},
          );
        } catch (e) {
          debugPrint('API logout failed');
        }
      }
      await _clearLocalData();
      return {'success': true, 'message': 'Berhasil logout'};
    } catch (e) {
      try {
        await _clearLocalData();
        return {'success': true, 'message': 'Berhasil logout (offline)'};
      } catch (_) {
        return {'success': false, 'message': 'Gagal logout'};
      }
    }
  }

  static Future<void> _clearLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasLoggedAsGuest', false);
    await prefs.setBool('hasLoggedAsUser', false);
    await prefs.remove('name');
    await prefs.remove('email');
    await prefs.remove('userImage');
    await prefs.remove('token');
  }
}