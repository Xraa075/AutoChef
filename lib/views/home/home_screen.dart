import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:autochef/widgets/header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBC72A),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140),
        child: CustomHeader(
          title: "Mau masak apa hari ini",
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    style: const TextStyle(fontSize: 18),
                    decoration: const InputDecoration(
                      hintText: 'Cari resep...',
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      print("User ngetik: $value");
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 1),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // const Column(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     Text(
                        //       "Bahan apa yang kamu miliki?",
                        //       style: TextStyle(
                        //         fontSize: 16,
                        //         fontWeight: FontWeight.bold,
                        //         color: Colors.black,
                        //       ),
                        //     ),
                        //     SizedBox(height: 4),
                        //     Text(
                        //       "Tuliskan bahan-bahanmu",
                        //       style: TextStyle(
                        //         fontSize: 14,
                        //         color: Colors.black54,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // GestureDetector(
                        //   child: Container(
                        //     decoration: BoxDecoration(
                        //       shape: BoxShape.circle,
                        //       color: Colors.grey[300],
                        //     ),
                        //     padding: const EdgeInsets.all(8),
                        //     child: const Icon(Icons.add, color: Colors.black),
                        //   ),
                        // ),
                      ],
                    ),
                    // const SizedBox(height: 30),

                    // list rekomendasi resep
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.only(bottom: 20),
                        children: [
                          const Text(
                            "Categories",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            alignment: WrapAlignment.spaceBetween,
                            children: [
                              _buildCategory("Snacks", "lib/assets/images/snacks.jpg"),
                              _buildCategory("Meal", "lib/assets/images/meal.jpg"),
                              _buildCategory("Vegan", "lib/assets/images/vegan.jpg"),
                              _buildCategory("Dessert", "lib/assets/images/dessert.jpg"),
                              _buildCategory("Drinks", "lib/assets/images/drinks.jpg"),
                            ],
                          ),

                          const SizedBox(height: 20),
                          const Text(
                            "Rekomendasi",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 121,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _buildRekomendasi(
                                  "Tempe Orek",
                                  "assets/tempe_orek.png",
                                ),
                                _buildRekomendasi(
                                  "Capcay",
                                  "assets/capcay.png",
                                ),
                                _buildRekomendasi(
                                  "Telur Balado",
                                  "assets/telur_balado.png",
                                ),
                                _buildRekomendasi(
                                  "Tempe Orek",
                                  "assets/tempe_orek.png",
                                ),
                                _buildRekomendasi(
                                  "Capcay",
                                  "assets/capcay.png",
                                ),
                                _buildRekomendasi(
                                  "Telur Balado",
                                  "assets/telur_balado.png",
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Masakan Sehat",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 170,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _buildHealthyFood(
                                  "Tumis Kangkung",
                                  "assets/tumis_kangkung.png",
                                ),
                                _buildHealthyFood("Sop", "assets/sop.png"),
                                _buildHealthyFood(
                                  "Tumis Jamur dan Brokoli",
                                  "assets/jamur_brokoli.png",
                                ),
                                _buildHealthyFood(
                                  "Tumis Kangkung",
                                  "assets/tumis_kangkung.png",
                                ),
                                _buildHealthyFood("Sop", "assets/sop.png"),
                                _buildHealthyFood(
                                  "Tumis Jamur dan Brokoli",
                                  "assets/jamur_brokoli.png",
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                    // const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildCategory(String title, String imagePath) {
  return SizedBox(
    width:
        MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width /
            5 -
        24, // 5 items per row, padding 20px
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Image.asset(
            imagePath,
            width: 50,
            height: 65,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 12)),
      ],
    ),
  );
}

Widget _buildRekomendasi(String title, String imagePath) {
  return Container(
    child: Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Image.asset(
            'lib/assets/images/image2.png',
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 10),
      ],
    ),
  );
}

Widget _buildHealthyFood(String title, String imagePath) {
  return Container(
    width: 120,
    margin: const EdgeInsets.only(right: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 5,
          offset: Offset(0, 3),
        ),
      ],
    ),
    clipBehavior: Clip.antiAlias, // <- ini penting untuk potong overflow
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          child: Image.asset(
            'lib/assets/images/image2.png',
            width: 120,
            height: 90,
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(title, style: const TextStyle(fontSize: 14)),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.favorite_border, size: 16, color: Colors.orange),
        ),
      ],
    ),
  );
}
