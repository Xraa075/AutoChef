import 'package:shared_preferences/shared_preferences.dart';
import 'package:autochef/models/user.dart';

Future<User> getActiveUser() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final String name = prefs.getString('name') ?? 'Pengguna';
  
  final String email = prefs.getString('email') ?? 'email@contoh.com';
  final String userImage =
      prefs.getString('userImage') ?? 'lib/assets/images/avatar1.png';

  return User(
    name: name, 
    email: email,
    userImage: userImage,
  );
}