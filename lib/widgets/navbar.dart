// import 'package:flutter/material.dart';
// import 'package:autochef/widgets/circle_nav_bar.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: const HomeScreen(),
//     );
//   }
// }

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _currentIndex = 1;

//   final List<Widget> _pages = [
//     const Center(child: Text("Profile Page", style: TextStyle(fontSize: 24))),
//     const Center(child: Text("Home Page", style: TextStyle(fontSize: 24))),
//     const Center(child: Text("Favorites Page", style: TextStyle(fontSize: 24))),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _pages[_currentIndex],
//       bottomNavigationBar: CircleNavBar(
//         activeIcons: const [
//           Icon(Icons.person, color: Colors.deepPurple),
//           Icon(Icons.home, color: Colors.deepPurple),
//           Icon(Icons.favorite, color: Colors.deepPurple),
//         ],
//         inactiveIcons: const [
//           Text("My"),
//           Text("Home"),
//           Text("Like"),
//         ],
//         color: Colors.white,
//         circleColor: Colors.white,
//         height: 60,
//         circleWidth: 60,
//         // initIndex: _currentIndex,
//         // onChanged: (index) {
//         //   setState(() {
//         //     _currentIndex = index;
//         //   });
//         // },
//         padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
//         cornerRadius: const BorderRadius.only(
//           topLeft: Radius.circular(8),
//           topRight: Radius.circular(8),
//           bottomRight: Radius.circular(24),
//           bottomLeft: Radius.circular(24),
//         ),
//         shadowColor: Colors.deepPurple,
//         circleShadowColor: Colors.deepPurple,
//         elevation: 10,
//         gradient: const LinearGradient(
//           begin: Alignment.topRight,
//           end: Alignment.bottomLeft,
//           colors: [Colors.blue, Colors.red],
//         ),
//         circleGradient: const LinearGradient(
//           begin: Alignment.topRight,
//           end: Alignment.bottomLeft,
//           colors: [Colors.blue, Colors.red],
//         ),
//       ),
//     );
//   }
// }
