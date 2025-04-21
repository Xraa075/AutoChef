import 'package:autochef/views/input_ingredients/input_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:autochef/widgets/header.dart';
import 'package:autochef/widgets/category_item.dart';
import 'package:autochef/widgets/recommendation_item.dart';
import 'package:autochef/widgets/healthy_food_item.dart';
import 'package:autochef/services/api_rekomendation.dart';
import 'package:autochef/models/recipe.dart';

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
                        borderRadius: BorderRadius.circular(20),
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
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.search, color: Colors.black54),
                  ),
                ),
                SizedBox(height: 10,)
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(top: 1),
          padding: const EdgeInsets.fromLTRB(0, 20, 20, 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: const Text(
                  "Categories",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.spaceBetween,
                children: const [
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
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: const Text(
                  "Rekomendasi",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 150,
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(right: 10),
                          itemCount: _rekomendasi.length,
                          itemBuilder: (context, index) {
                            final resep = _rekomendasi[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: RecommendationItem(
                                title: resep.namaResep,
                                imagePath: resep.gambar,
                              ),
                            );
                          },
                        ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: const Text(
                  "Masakan Sehat",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 140,
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(right: 10),
                          itemCount: _rekomendasi.length,
                          itemBuilder: (context, index) {
                            final resep = _rekomendasi[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 10, bottom: 10,),
                              child: HealthyFoodItem(
                                title: resep.namaResep,
                                imagePath: resep.gambar,
                              ),
                            );
                          },
                        ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
