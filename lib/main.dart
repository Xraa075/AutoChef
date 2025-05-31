import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:autochef/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  bool hasSeenIntro = prefs.getBool('hasSeenIntro') ?? false;
  bool hasLoggedAsUser = prefs.getBool('hasLoggedAsUser') ?? false;
  bool hasSeenPolicyAnnouncement =
      prefs.getBool('hasSeenPolicyAnnouncement') ?? false;

  if (prefs.containsKey('hasLoggedAsGuest')) {
    await prefs.remove('hasLoggedAsGuest');
  }
  if (prefs.containsKey('guestSession')) {
    await prefs.remove('guestSession');
  }
  if (prefs.containsKey('isGuest')) {
    await prefs.remove('isGuest');
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MyApp(
      hasSeenIntro: hasSeenIntro,
      hasLoggedAsUser: hasLoggedAsUser,
      hasSeenPolicyAnnouncement: hasSeenPolicyAnnouncement,
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool hasSeenIntro;
  final bool hasLoggedAsUser;
  final bool hasSeenPolicyAnnouncement;

  const MyApp({
    super.key,
    required this.hasSeenIntro,
    required this.hasLoggedAsUser,
    required this.hasSeenPolicyAnnouncement,
  });

  @override
  Widget build(BuildContext context) {
    String initialRoute;

    if (!hasSeenIntro) {
      initialRoute = Routes.introScreen;
    } else if (!hasSeenPolicyAnnouncement) {
      initialRoute = Routes.policyAnnouncement;
    } else if (!hasLoggedAsUser) {
      initialRoute = Routes.login;
    } else {
      initialRoute = Routes.home;
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AutoChef',
      initialRoute: initialRoute,
      onGenerateRoute: Routes.onGenerateRoute,
    );
  }
}