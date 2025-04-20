import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:autochef/routes.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool hasSeenIntro = prefs.getBool('hasSeenIntro') ?? false;
  bool hasLoggedAsGuest = prefs.getBool('hasLoggedAsGuest') ?? false;
  bool hasLoggedAsUser = prefs.getBool('hasLoggedAsUser') ?? false;

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MyApp(
      hasSeenIntro: hasSeenIntro,
      hasLoggedAsGuest: hasLoggedAsGuest,
      hasLoggedAsUser: hasLoggedAsUser,
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool hasSeenIntro;
  final bool hasLoggedAsGuest;
  final bool hasLoggedAsUser;

  const MyApp({
    super.key,
    required this.hasSeenIntro,
    required this.hasLoggedAsGuest,
    required this.hasLoggedAsUser,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AutoChef',
      initialRoute:
          hasSeenIntro
              ? ((hasLoggedAsGuest || hasLoggedAsUser)
                  ? Routes.home
                  : Routes.login)
              : Routes.introScreen,
      onGenerateRoute: Routes.onGenerateRoute,
    );
  }
}
