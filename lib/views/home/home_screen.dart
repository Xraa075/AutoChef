import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:autochef/widgets/header.dart';
import 'package:autochef/widgets/category_item.dart';
import 'package:autochef/widgets/recommendation_item.dart';
import 'package:autochef/widgets/healthy_food_item.dart';

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
    const SizedBox(width: 8),
    GestureDetector(
      onTap: () {
        print("Ikon + ditekan");
        // Tambahkan aksi di sini kalau diperlukan
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[300],
        ),
        padding: const EdgeInsets.all(8),
        child: const Icon(Icons.add, color: Colors.black),
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
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            alignment: WrapAlignment.spaceBetween,
                            children: [
                              CategoryItem(
                                title: "Snacks",
                                imagePath: "lib/assets/images/snacks.jpg",
                              ),
                              CategoryItem(
                                title: "Meal",
                                imagePath: "lib/assets/images/meal.jpg",
                              ),
                              CategoryItem(
                                title: "Vegan",
                                imagePath: "lib/assets/images/vegan.jpg",
                              ),
                              CategoryItem(
                                title: "Dessert",
                                imagePath: "lib/assets/images/dessert.jpg",
                              ),
                              CategoryItem(
                                title: "Drinks",
                                imagePath: "lib/assets/images/drinks.jpg",
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          const Text(
                            "Rekomendasi",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 123,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                RecommendationItem(
                                  title: "Tempe Orek",
                                  imagePath: "lib/assets/images/meal.jpg",
                                ),
                                RecommendationItem(
                                  title: "Capcay",
                                  imagePath: "lib/assets/images/meal.jpg",
                                ),
                                RecommendationItem(
                                  title: "Telur Balado",
                                  imagePath: "lib/assets/images/meal.jpg",
                                ),
                                RecommendationItem(
                                  title: "Tempe Orek",
                                  imagePath: "lib/assets/images/meal.jpg",
                                ),
                                RecommendationItem(
                                  title: "Capcay",
                                  imagePath: "lib/assets/images/meal.jpg",
                                ),
                                RecommendationItem(
                                  title: "Telur Balado",
                                  imagePath: "lib/assets/images/meal.jpg",
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Masakan Sehat",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 170,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                HealthyFoodItem(
                                  title: "Tumis Kangkung",
                                  imagePath: "lib/assets/images/vegan.jpg",
                                ),
                                HealthyFoodItem(
                                  title: "Sop",
                                  imagePath: "lib/assets/images/vegan.jpg",
                                ),
                                HealthyFoodItem(
                                  title: "Tumis Jamur dan Brokoli",
                                  imagePath: "lib/assets/images/vegan.jpg",
                                ),
                                HealthyFoodItem(
                                  title: "Tumis Kangkung",
                                  imagePath: "lib/assets/images/vegan.jpg",
                                ),
                                HealthyFoodItem(
                                  title: "Sop",
                                  imagePath: "lib/assets/images/vegan.jpg",
                                ),
                                HealthyFoodItem(
                                  title: "Tumis Jamur dan Brokoli",
                                  imagePath: "lib/assets/images/vegan.jpg",
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
