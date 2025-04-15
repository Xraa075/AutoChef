import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autochef/routes.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool hasSeenIntro = prefs.getBool('hasSeenIntro') ?? false;
  bool hasLoggedAsGuest = prefs.getBool('hasLoggedAsGuest') ?? false;

  runApp(MyApp(hasSeenIntro: hasSeenIntro, hasLoggedAsGuest: hasLoggedAsGuest));
}

class MyApp extends StatelessWidget {
  final bool hasSeenIntro;
  final bool hasLoggedAsGuest;

  const MyApp({
    super.key,
    required this.hasSeenIntro,
    required this.hasLoggedAsGuest,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AutoChef',
      initialRoute:
          hasSeenIntro
              ? (hasLoggedAsGuest ? Routes.home : Routes.login)
              : Routes.introScreen,
      onGenerateRoute: Routes.onGenerateRoute,
    );
  }
}
