import 'package:shared_preferences/shared_preferences.dart';
import 'package:autochef/models/user.dart';

Future<User> getActiveUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? username = prefs.getString('username');
  String? email = prefs.getString('email');
  String? userImage = prefs.getString('userImage');

  if (username == null || email == null || userImage == null) {
    return User(
      username: 'Guest',
      email: 'guest@autochef.com',
      userImage: 'lib/assets/images/avatar1.png',
    );
  }

  return User(username: username, email: email, userImage: userImage);
}
