import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

// const String _baseUrl = 'http://100.120.18.38:8080/api';
const String _baseUrl = 'https://backend.autochef.site/api';

Future<Map<String, dynamic>> register(
    String name, String email, String password, String confirmPassword) async {
  var url = Uri.parse('$_baseUrl/register');

  debugPrint('Fungsi login di api_login.dart terpanggil.');
  debugPrint('Mengeksekusi HTTP POST ke: $url');

  try {
    var response = await http.post(
      url,
      headers: {'Accept': 'application/json'},
      body: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': confirmPassword,
      },
    ).timeout(const Duration(seconds: 20));

    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204) {

      if (response.statusCode == 204) {
        return {'status': 'success', 'data': null};
      }

      Map<String, dynamic>? responseData;
      if (response.body.isNotEmpty) {
        try {
          responseData = jsonDecode(response.body);
          return {'status': 'success', 'data': responseData};
        } catch (e) {
          return {
            'status': 'error',
            'message': 'Server memberikan respons sukses tapi format data tidak valid.'
          };
        }
      }
      return {'status': 'success', 'data': null};
    }
    Map<String, dynamic>? responseData;
    if (response.body.isNotEmpty) {
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        return {
          'status': 'error',
          'message': 'Server error dengan respons tidak valid.'
        };
      }
    }

    if (response.statusCode == 422) {
      String errorMsg =
          responseData?['message'] ?? 'Terjadi kesalahan validasi.';
      Map<String, dynamic>? errors = responseData?['errors'];
      String specificFieldErrors = "";
      if (errors != null) {
        errors.forEach((key, value) {
          if (value is List && value.isNotEmpty) {
            String fieldName = key;
            if (key == "name") fieldName = "Username";
            if (key == "password") fieldName = "Password";
            if (key == "email") fieldName = "Email";
            specificFieldErrors += "$fieldName: ${value.first}\n";
          }
        });
        errorMsg =
            specificFieldErrors.isNotEmpty ? specificFieldErrors.trim() : errorMsg;
      }
      return {'status': 'error', 'message': errorMsg};
    } 
    
    else {
      return {
        'status': 'error',
        'message': responseData?['message'] ??
            'Gagal registrasi'
      };
    }
  } on SocketException {
    return {'status': 'error', 'message': 'Tidak ada koneksi internet.'};
  } on http.ClientException {
    return {'status': 'error', 'message': 'Tidak dapat terhubung ke server.'};
  } on FormatException {
    return {'status': 'error', 'message': 'Format respons server tidak valid.'};
  } on TimeoutException {
    return {'status': 'error', 'message': 'Koneksi ke server timeout.'};
  } catch (e) {
    return {'status': 'error', 'message': 'Terjadi kesalahan: ${e.toString()}'};
  }
}

Future<Map<String, dynamic>> login(String email, String password) async {
  var url = Uri.parse('$_baseUrl/login');

  debugPrint('Fungsi login di api_login.dart terpanggil.');
  debugPrint('Mengeksekusi HTTP POST ke: $url');

  try {
    var response = await http.post(
      url,
      headers: {'Accept': 'application/json'},
      body: {
        'email': email,
        'password': password,
      },
    ).timeout(const Duration(seconds: 20));

    Map<String, dynamic>? responseData;
    if (response.body.isNotEmpty) {
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        return {
          'status': 'error',
          'message': 'Format respons dari server tidak valid.'
        };
      }
    } else {
      if (response.statusCode == 200) {
        return {
          'status': 'error',
          'message': 'Server memberikan respons kosong.'
        };
      }
    }

    if (response.statusCode == 200) {
      return {'status': 'success', 'data': responseData};
    }
    else if (response.statusCode == 401 || response.statusCode == 422) {
      return {
        'status': 'error',
        'message': 'Email atau password yang kamu masukkan salah'
      };
    }
    else {
      String messageFromServer = "Gagal login.";
      if (responseData != null && responseData.containsKey('message')) {
        messageFromServer = responseData['message'];
      } else if (response.body.isNotEmpty) {
        messageFromServer = response.body.length > 100
            ? "${response.body.substring(0, 100)}..."
            : response.body;
      }
      return {
        'status': 'error',
        'message': '$messageFromServer'
      };
    }
  } on SocketException {
    return {'status': 'error', 'message': 'Tidak ada koneksi internet.'};
  } on TimeoutException {
    return {
      'status': 'error',
      'message': 'Koneksi ke server terputus atau terlalu lama.'
    };
  } on http.ClientException {
    return {'status': 'error', 'message': 'Tidak dapat terhubung ke server.'};
  } on FormatException {
    return {'status': 'error', 'message': 'Format respons server tidak valid.'};
  } catch (e) {
    return {'status': 'error', 'message': 'Terjadi kesalahan: ${e.toString()}'};
  }
}

Future<Map<String, dynamic>> getUserProfile(String token) async {
  var url = Uri.parse('$_baseUrl/user');
  
  debugPrint('Mengambil profil pengguna dengan token...');

  try {
    var response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      return {'status': 'success', 'data': jsonDecode(response.body)};
    } else {
      return {
        'status': 'error',
        'message': 'Gagal mengambil data pengguna'
      };
    }
  } on SocketException {
    return {'status': 'error', 'message': 'Tidak ada koneksi internet.'};
  } on TimeoutException {
    return {'status': 'error', 'message': 'Koneksi ke server timeout.'};
  } catch (e) {
    return {'status': 'error', 'message': 'Terjadi kesalahan: ${e.toString()}'};
  }
}