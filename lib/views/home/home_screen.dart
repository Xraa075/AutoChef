import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:autochef/models/recipe.dart';
import 'package:autochef/widgets/header.dart';
import 'package:autochef/widgets/category_item.dart';
import 'package:autochef/services/search_service.dart';
import 'package:autochef/widgets/healthy_food_item.dart';
import 'package:autochef/services/api_rekomendation.dart';
import 'package:autochef/views/recipe/recipe_detail_screen.dart';
import 'package:autochef/views/recipe/recommendation_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Recipe> _rekomendasi = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String _searchQuery = '';

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

  void _showPopup(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          title: Row(
            children: const [
              Icon(Icons.info, color: Color(0xFFF46A06)),
              SizedBox(width: 10),
              Text("Informasi"),
            ],
          ),
          content: Text(message, style: const TextStyle(fontSize: 16)),
          actions: [
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF46A06),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Oke",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> handleSearch(BuildContext context) async {
    if (_isSearching) return;

    if (_searchQuery.trim().isEmpty) {
      _showPopup("Masukkan kata kunci pencarian");
      return;
    }

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _showPopup("Periksa koneksi internet Anda dan coba lagi.");
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await SearchService.searchResep(_searchQuery);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RekomendationRecipe(results: results),
        ),
      );
    } catch (e) {
      print('Search error: $e');
      _showPopup("Gagal mencari resep. Silakan coba lagi nanti.");
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  Widget buildShimmerItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        height: 150,
        width: 100,
      ),
    );
  }

  Widget buildShimmerGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.65,
      ),
      itemBuilder: (context, index) => buildShimmerItem(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBC72A),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          MediaQuery.of(context).size.height * 0.2,
        ),
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
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    onSubmitted: (_) => handleSearch(context),
                  ),
                ),
                const SizedBox(width: 8),
                _isSearching
                    ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      ),
                    )
                    : GestureDetector(
                      onTap: () => handleSearch(context),
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
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(top: 10),
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Kategori",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CategoryItemTap(
                    title: "Snacks",
                    kategori: "snack",
                    imagePath: "lib/assets/images/snacks.jpg",
                  ),
                  CategoryItemTap(
                    title: "Meal",
                    kategori: "meal",
                    imagePath: "lib/assets/images/meal.jpg",
                  ),
                  CategoryItemTap(
                    title: "Vegan",
                    kategori: "vegan",
                    imagePath: "lib/assets/images/vegan.jpg",
                  ),
                  CategoryItemTap(
                    title: "Dessert",
                    kategori: "dessert",
                    imagePath: "lib/assets/images/dessert.jpg",
                  ),
                  CategoryItemTap(
                    title: "Drinks",
                    kategori: "drink",
                    imagePath: "lib/assets/images/drinks.jpg",
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "Rekomendasi",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                ),
              ),
              _isLoading
                  ? buildShimmerGrid()
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
                          childAspectRatio: 0.65,
                        ),
                    itemBuilder: (context, index) {
                      final resep = _rekomendasi[index];
                      return HealthyFoodItem(
                        title: resep.namaResep,
                        imagePath: resep.gambar,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => DetailMakanan(recipe: resep),
                            ),
                          );
                        },
                      );
                    },
                  ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryItemTap extends StatelessWidget {
  final String title;
  final String kategori;
  final String imagePath;

  const CategoryItemTap({
    super.key,
    required this.title,
    required this.kategori,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RekomendationRecipe(kategori: kategori),
          ),
        );
      },
      child: CategoryItem(title: title, imagePath: imagePath),
    );
  }
}
