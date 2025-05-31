import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> register(String name, String email, String password) async {
  var url = Uri.parse('http://156.67.214.60/api/register');

  var response = await http.post(url, body: {
    'name': name,
    'email': email,
    'password': password,
  });

  if (response.statusCode == 200) {
    json.decode(response.body);
  } else {
  }
}
