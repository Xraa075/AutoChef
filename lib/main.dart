import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:autochef/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  bool hasSeenIntro = prefs.getBool('hasSeenIntro') ?? false;
  bool hasLoggedAsUser = prefs.getBool('hasLoggedAsUser') ?? false;

  if (prefs.containsKey('hasLoggedAsGuest')) {
    await prefs.remove('hasLoggedAsGuest');
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp(hasSeenIntro: hasSeenIntro, hasLoggedAsUser: hasLoggedAsUser));
}

class MyApp extends StatelessWidget {
  final bool hasSeenIntro;
  final bool hasLoggedAsUser;

  const MyApp({
    super.key,
    required this.hasSeenIntro,
    required this.hasLoggedAsUser,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AutoChef',
      initialRoute:
          hasSeenIntro
              ? (hasLoggedAsUser ? Routes.home : Routes.login)
              : Routes.introScreen,
      onGenerateRoute: Routes.onGenerateRoute,
    );
  }
}
