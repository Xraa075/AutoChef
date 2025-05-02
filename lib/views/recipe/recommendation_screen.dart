import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:autochef/models/recipe.dart';
import 'package:autochef/widgets/header.dart';
import 'package:autochef/widgets/recipe_card.dart';
import 'package:autochef/services/api_service.dart';
import 'package:autochef/services/kategori_service.dart';
import 'package:autochef/views/recipe/recipe_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:autochef/services/search_service.dart';

/// Widget utama untuk menampilkan daftar rekomendasi resepF
/// berdasarkan bahan atau kategori yang dipilih pengguna
class RekomendationRecipe extends StatefulWidget {
  final List<String>? bahan;
 final List<Recipe>? results;
  final String? kategori;
  final String? namaResep;

  const RekomendationRecipe({super.key, this.bahan, this.kategori, this.namaResep, this.results});

  @override
  _RekomendationRecipeState createState() => _RekomendationRecipeState();
}

class _RekomendationRecipeState extends State<RekomendationRecipe> {
  late Future<List<Recipe>> _futureRecipes;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _futureRecipes = _fetchRecipes();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Mengambil data resep dari API berdasarkan bahan atau kategori
  Future<List<Recipe>> _fetchRecipes() async {
  try {
    List<dynamic> response = [];

    final apiService = ApiService();
    final kategoriService = KategoriService();
    final searchService = SearchService();

    if (widget.results != null && widget.results!.isNotEmpty) {
      // Jika sudah ada hasil (misalnya dari screen sebelumnya)
      return widget.results!;
    } else if (widget.bahan != null && widget.bahan!.isNotEmpty) {
      // Pencarian berdasarkan bahan
      response = await apiService.searchRecipes(widget.bahan!);
    } else if (widget.kategori != null && widget.kategori!.isNotEmpty) {
      // Pencarian berdasarkan kategori
      response = await kategoriService.getRecipesByKategori(widget.kategori!);
    } else if (widget.namaResep != null && widget.namaResep!.isNotEmpty) {
      // Tambahan pencarian berdasarkan nama resep jika diperlukan
      response = await SearchService.searchResep(widget.namaResep!);
    } else {
      throw Exception("Masukkan nama resep, bahan, atau kategori.");
    }

    if (response.isEmpty) {
      throw Exception("Data kosong.");
    }

    if (response.any((item) => item is! Map<String, dynamic>)) {
      throw Exception("Format data salah.");
    }

    return response.map<Recipe>((json) => Recipe.fromJson(json)).toList();
  } catch (e, stacktrace) {
    debugPrint("Error fetching recipes: $e");
    debugPrint("Stacktrace: $stacktrace");
    _showErrorDialog(
      "Tidak ada data resep yang ditemukan dari input yang kamu berikan.",
    );
    return Future.error(e.toString());
  }
}



  /// Menampilkan dialog error jika terjadi kesalahan saat mengambil data
  void _showErrorDialog(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                title: Row(
                  children: [
                    Icon(Icons.info, color: Color(0xFFF46A06)),
                    SizedBox(width: 10),
                    Text("Informasi"),
                  ],
                ),
                content: Text(message, style: TextStyle(fontSize: 15)),
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
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        "Oke",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBC72A),
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(120),
        child: CustomHeader(
          title: "Ini adalah rekomendasi resep sesuai dengan bahanmu",
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 30),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Text(
                        "Rekomendasi",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: FutureBuilder<List<Recipe>>(
                        future: _futureRecipes,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return _buildShimmerLoading();
                          } else if (snapshot.hasError ||
                              snapshot.data == null ||
                              snapshot.data!.isEmpty) {
                            return _buildErrorWidget();
                          }

                          final recipes = snapshot.data!;
                          return Scrollbar(
                            controller: _scrollController,
                            thumbVisibility: true,
                            radius: Radius.circular(8),
                            interactive: true,
                            thickness: 8,
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              itemCount: recipes.length,
                              itemBuilder: (context, index) {
                                final recipe = recipes[index];
                                return RecipeCard(
                                  recipe: recipe,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                DetailMakanan(recipe: recipe),
                                      ),
                                    );
                                  },
                                  image: recipe.gambar,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget gambar resep dengan validasi URL dan efek loading shimmer
  Widget _buildImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        color: Colors.grey[200],
        height: 150,
        child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
      );
    }

    return CachedNetworkImage(
      imageUrl: Uri.encodeFull(imageUrl),
      placeholder:
          (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: double.infinity,
              height: 150,
              color: Colors.white,
            ),
          ),
      errorWidget:
          (context, url, error) => Container(
            color: Colors.grey[200],
            height: 150,
            child: const Center(
              child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
            ),
          ),
      fit: BoxFit.cover,
    );
  }

  /// Widget loading shimmer sebagai placeholder saat data sedang dimuat
  Widget _buildShimmerLoading() {
    return ListView.builder( 
      itemCount: 5,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
    );
  }

  /// Widget fallback saat terjadi error atau data kosong
  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.error_outline, size: 60, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "Data tidak ditemukan.",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
