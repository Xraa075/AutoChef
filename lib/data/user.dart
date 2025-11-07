import 'package:shared_preferences/shared_preferences.dart';
import 'package:autochef/models/user.dart';

Future<User> getActiveUser() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();


  final String username = prefs.getString('username') ?? 'Pengguna';
  final String email = prefs.getString('email') ?? 'email@contoh.com';
  final String userImage =
      prefs.getString('userImage') ?? 'lib/assets/images/avatar1.png';

  return User(
    // id: '1',
    username: username,
    email: email,
    userImage: userImage,
  );
}