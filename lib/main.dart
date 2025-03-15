import 'package:flutter/material.dart';
import 'package:autochef/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

  runApp(MyApp(isFirstTime: isFirstTime));
}

class MyApp extends StatelessWidget {
  final bool isFirstTime;
  const MyApp({super.key, required this.isFirstTime});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AutoChef',
      initialRoute: isFirstTime ? Routes.introScreen : Routes.inputRecipe, // **🔹 Cek apakah user baru**
      onGenerateRoute: Routes.onGenerateRoute,
    );
  }
}
