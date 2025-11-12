import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autochef/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SharedPreferences prefs = await SharedPreferences.getInstance();

  bool hasSeenIntro = prefs.getBool('hasSeenIntro') ?? false;
  bool hasLoggedAsUser = prefs.getBool('hasLoggedAsUser') ?? false;
  bool hasSeenPolicyAnnouncement =
      prefs.getBool('hasSeenPolicyAnnouncement') ?? false;

  runApp(MyApp(
    hasSeenIntro: hasSeenIntro,
    hasLoggedAsUser: hasLoggedAsUser,
    hasSeenPolicyAnnouncement: hasSeenPolicyAnnouncement,
  ));
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
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
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppLinks _appLinks = AppLinks();
  String? _initialRoute;

  @override
  void initState() {
    super.initState();

    // 🔹 Jalankan listener deep link
    _listenDeepLinks();

    // 🔹 Tentukan route awal default
    if (!widget.hasSeenIntro) {
      _initialRoute = Routes.introScreen;
    } else if (!widget.hasSeenPolicyAnnouncement) {
      _initialRoute = Routes.policyAnnouncement;
    } else if (!widget.hasLoggedAsUser) {
      _initialRoute = Routes.login;
    } else {
      _initialRoute = Routes.home;
    }
  }

  void _listenDeepLinks() {
    // 🔹 Jalankan saat app dibuka pertama kali dari link
    _appLinks.getInitialAppLink().then(_handleLink);

    // 🔹 Jalankan juga kalau app sudah aktif lalu dibuka lewat link lagi
    _appLinks.uriLinkStream.listen(_handleLink, onError: (err) {
      debugPrint('Deep link error: $err');
    });
  }

  void _handleLink(Uri? uri) async {
  if (uri == null) return;

  if (uri.scheme == 'autochef' &&
      uri.host == 'email' &&
      uri.path.contains('/verified')) {
    debugPrint('✅ Email verified link detected');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasLoggedAsUser', false);

    // 🔹 Tunggu sampai navigator siap
    Future.delayed(const Duration(milliseconds: 500), () {
      final nav = navigatorKey.currentState;
      if (nav != null) {
        nav.pushNamedAndRemoveUntil(
          Routes.login,
          (route) => false,
        );

        // Snackbar opsional
        Future.delayed(const Duration(milliseconds: 300), () {
          ScaffoldMessenger.of(nav.context).showSnackBar(
            const SnackBar(
              content: Text('Email kamu berhasil diverifikasi! Silakan login.'),
              backgroundColor: Colors.green,
            ),
          );
        });
      } else {
        debugPrint('⚠️ Navigator belum siap, tidak bisa redirect');
      }
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AutoChef',
      navigatorKey: navigatorKey,
      initialRoute: _initialRoute ?? Routes.login,
      onGenerateRoute: Routes.onGenerateRoute,
    );
  }
}
