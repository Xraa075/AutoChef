import 'package:autochef/models/user.dart';

List<User> dummyUsers = [
  User(
    username: "Guest",
    email: "guest@autochef.com",
    userImage: "lib/assets/images/default_user.png",
  ),
];

// Variabel global untuk menyimpan user aktif
User? activeUser;

// Fungsi untuk mendapatkan user aktif atau default jika belum login
User getActiveUser() {
  return activeUser ?? dummyUsers.first; // Gunakan user default jika belum login
}

// Fungsi untuk mengubah user setelah login
void loginUser(User user) {
  activeUser = user;
}

// Fungsi untuk logout
void logoutUser() {
  activeUser = null;
}
