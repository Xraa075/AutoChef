import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:autochef/widgets/header.dart';
import 'package:autochef/widgets/category_item.dart';
import 'package:autochef/widgets/recommendation_item.dart';
import 'package:autochef/widgets/healthy_food_item.dart';
import 'package:autochef/services/api_rekomendation.dart';
import 'package:autochef/models/recipe.dart';
import 'package:autochef/views/recipe/recipe_detail_screen.dart';
import 'package:autochef/views/recipe/recommendation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Recipe> _rekomendasi = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getRekomendasi();
  }

  Future<void> getRekomendasi() async {
    try {
      final data = await ApiRekomendasi.fetchRekomendasi();
      setState(() {
        _rekomendasi = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Terjadi error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

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
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20.0,
                      ),
                      hintText: 'Cari resep...',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      //prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    ),
                    onChanged: (value) {
                      print("User ngetik: $value");
                    },
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => const InputRecipe(),
                    //   ),
                    // );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.search, color: Colors.black54),
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(top: 1),
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Text(
                  "Kategori",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  RekomendationRecipe(kategori: "snack"),
                        ),
                      );
                    },
                    child: const CategoryItem(
                      title: "Snacks",
                      imagePath: "lib/assets/images/snacks.jpg",
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  RekomendationRecipe(kategori: "meal"),
                        ),
                      );
                    },
                    child: const CategoryItem(
                      title: "Meal",
                      imagePath: "lib/assets/images/meal.jpg",
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  RekomendationRecipe(kategori: "vegan"),
                        ),
                      );
                    },
                    child: const CategoryItem(
                      title: "Vegan",
                      imagePath: "lib/assets/images/vegan.jpg",
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  RekomendationRecipe(kategori: "dessert"),
                        ),
                      );
                    },
                    child: const CategoryItem(
                      title: "Dessert",
                      imagePath: "lib/assets/images/dessert.jpg",
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  RekomendationRecipe(kategori: "drink"),
                        ),
                      );
                    },
                    child: const CategoryItem(
                      title: "Drinks",
                      imagePath: "lib/assets/images/drinks.jpg",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: const Text(
                  "Rekomendasi",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                ),
              ),
              // const SizedBox(height: 10),
              SizedBox(
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _rekomendasi.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio:
                                    0.65, // atur ini biar tinggi & lebar card seimbang
                              ),
                          itemBuilder: (context, index) {
                            final resep = _rekomendasi[index];
                            return HealthyFoodItem(
                              title: resep.namaResep,
                              imagePath: resep.gambar,
                              onTap: () {
                                print("Tapped on recipe: ${resep.namaResep}");
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            DetailMakanan(recipe: resep),
                                  ),
                                );
                              },
                            );
                          },
                        ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
