import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autochef/views/intro/intro_screen.dart';
import 'package:autochef/widgets/navbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool hasSeenIntro = prefs.getBool('hasSeenIntro') ?? false;

  runApp(MyApp(hasSeenIntro: hasSeenIntro));
}

class MyApp extends StatelessWidget {
  final bool hasSeenIntro;
  const MyApp({super.key, required this.hasSeenIntro});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AutoChef',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: hasSeenIntro ? const Navbar() : const IntroScreen(), // ✅ Langsung ke Navbar jika intro sudah dilihat
    );
  }
}
