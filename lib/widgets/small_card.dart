import 'package:shared_preferences/shared_preferences.dart';
import 'package:autochef/models/recipe.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:autochef/services/api_favorite.dart';

class HealthyFoodItem extends StatefulWidget {
  final Recipe recipe;
  final VoidCallback? onTap;

  const HealthyFoodItem({super.key, required this.recipe, this.onTap});

  @override
  State<HealthyFoodItem> createState() => _HealthyFoodItemState();
}

class _HealthyFoodItemState extends State<HealthyFoodItem> {
  // OPTIMASI: State lokal hanya untuk animasi toggle klik secara instan
  late bool _isFavorite;
  bool _isTogglingFavorite = false;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.recipe.is_favorited; 
  }

  @override
  void didUpdateWidget(covariant HealthyFoodItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.recipe.id != oldWidget.recipe.id || widget.recipe.is_favorited != oldWidget.recipe.is_favorited) {
      _isFavorite = widget.recipe.is_favorited;
    }
  }

  Future<String?> _getToken() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs?.getString('token');
  }

  Future<bool> _isUserLoggedIn() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs?.getBool('hasLoggedAsUser') ?? false;
  }

  Future<void> _handleToggleFavorite() async {
    if (!mounted || _isTogglingFavorite) return;

    final bool userLoggedIn = await _isUserLoggedIn();
    if (!userLoggedIn) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Silakan login untuk memfavoritkan resep.")),
        );
      }
      return;
    }

    setState(() {
      _isTogglingFavorite = true;
    });
    
    final token = await _getToken();
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sesi tidak valid. Silakan login ulang.")),
        );
        setState(() {
          _isTogglingFavorite = false;
        });
      }
      return;
    }

    try {
      setState(() {
        _isFavorite = !_isFavorite;
        widget.recipe.is_favorited = _isFavorite; // simpan di lokal hp dulu
      });

      final result = await ApiFavorite.toggle(
        recipeId: widget.recipe.id,
        token: token,
        isCurrentlyFavorite: !_isFavorite,
      );

      if (!mounted) return;

      if (result['success'] != true) {
        // Jika gagal di server, kembalikan ke status semula
        setState(() {
          _isFavorite = !_isFavorite;
          widget.recipe.is_favorited = _isFavorite;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
        );
      }
    } on TimeoutException {
      _rollbackFavoriteStatus("Waktu koneksi habis. Coba lagi.");
    } on SocketException {
      _rollbackFavoriteStatus("Gagal terhubung ke server. Periksa koneksi internet Anda.");
    } catch (e) {
      _rollbackFavoriteStatus("Terjadi kesalahan: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          _isTogglingFavorite = false;
        });
      }
    }
  }

  void _rollbackFavoriteStatus(String errorMessage) {
    if (!mounted) return;
    setState(() {
      _isFavorite = !_isFavorite;
      widget.recipe.is_favorited = _isFavorite;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage), backgroundColor: Colors.orange),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: AspectRatio(
                aspectRatio: 1.1,
                child: widget.recipe.gambar.isEmpty
                    ? Container(color: Colors.grey[200], child: const Icon(Icons.fastfood_outlined))
                    : Image.network(
                        widget.recipe.gambar,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: Center(child: Icon(Icons.fastfood_outlined, size: 40, color: Colors.grey[400])),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.recipe.namaResep,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.orange, size: 12),
                          const SizedBox(width: 2),
                          Text(
                            "${widget.recipe.waktu} Menit",
                            style: const TextStyle(fontSize: 10, color: Colors.orange),
                          ),
                        ],
                      ),
                      _isTogglingFavorite
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2.0, color: Colors.red),
                            )
                          : GestureDetector(
                              onTap: _handleToggleFavorite,
                              child: Icon(
                                _isFavorite ? Icons.favorite : Icons.favorite_border,
                                size: 18,
                                color: Colors.red,
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}