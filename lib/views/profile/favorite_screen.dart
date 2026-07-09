import 'package:autochef/routes.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autochef/models/recipe.dart';
import 'package:autochef/widgets/small_card.dart';
// Pastikan path import ini sesuai dengan struktur folder project Kami-sama
import 'package:autochef/services/api_favorite.dart'; 

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Recipe> _favoriteRecipes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchFavoriteRecipes();
  }

  Future<void> _fetchFavoriteRecipes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Silakan login untuk melihat resep favorit.";
      });
      return;
    }

    try {
      final List<dynamic> data = await ApiFavorite.getAllFavorites(token);
      
      final List<Recipe> loadedRecipes = [];
      for (var item in data) {
        try {
          loadedRecipes.add(Recipe.fromJson(item));
        } catch (e) {
          debugPrint("Error parsing recipe: $e");
        }
      }

      if (mounted) {
        setState(() {
          _favoriteRecipes = loadedRecipes;
          _isLoading = false;
        });
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll("Exception: ", "");
          _errorMessage = "Gagal memuat data favorite.";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Resep Yang Kamu Sukai",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchFavoriteRecipes,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text("Coba Lagi"),
            )
          ],
        ),
      );
    }

    if (_favoriteRecipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "Belum ada resep favorit",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchFavoriteRecipes,
      color: Colors.orange,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 16, bottom: 80),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.65,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _favoriteRecipes.length,
          itemBuilder: (context, index) {
            final recipe = _favoriteRecipes[index];
            return HealthyFoodItem(
              recipe: recipe,
              onTap: () {
                Navigator.pushNamed(
                  context, 
                  Routes.detailMakanan, 
                  arguments: recipe
                ).then((_) {
                  _fetchFavoriteRecipes();
                });
              },
            );
          },
        ),
      ),
    );
  }
}