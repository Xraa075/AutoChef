import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autochef/models/intro.dart';

import 'package:autochef/widgets/navbar.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  IntroScreenState createState() => IntroScreenState();
}

class IntroScreenState extends State<IntroScreen> {
  final PageController pageController = PageController();
  int currentPage = 0;

 Future<void> completeIntro() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('hasSeenIntro', true);

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const Navbar()), // ✅ Langsung ke Navbar
  );
}

  void nextPage() {
    if (currentPage < introData.length - 1) {
      pageController.animateToPage(
        currentPage + 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    } else {
      completeIntro(); // ✅ Jika di halaman terakhir, tandai sudah melihat intro
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[600],
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: pageController,
                itemCount: introData.length,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return buildPage(introData[index]);
                },
              ),
            ),

            // 🔹 Indikator Halaman (Dot Navigation)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                introData.length,
                (index) => buildDot(index),
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Tombol Lanjut / Mulai
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: ElevatedButton(
                onPressed: nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(234, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  currentPage < introData.length - 1 ? 'Lanjut' : 'Mulai',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Widget Halaman Intro
  Widget buildPage(Intro intro) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(intro.image, height: 250),
        const SizedBox(height: 20),
        Text(
          intro.title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            intro.description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
          ),
        ),
      ],
    );
  }

  // 🔹 Widget Dot Navigation
  Widget buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: currentPage == index ? 12 : 8,
      height: currentPage == index ? 12 : 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: currentPage == index ? Colors.orange : Colors.grey[400],
      ),
    );
  }
}
