import 'package:shared_preferences/shared_preferences.dart';
import 'package:autochef/models/recipe.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
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
  bool _isFavorite = false;
  bool _isLoadingInitialStatus = true;
  bool _isTogglingFavorite = false;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _initializeAndCheckFavoriteStatus();
  }

  @override
  void didUpdateWidget(covariant HealthyFoodItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.recipe.id != oldWidget.recipe.id) {
      _initializeAndCheckFavoriteStatus();
    }
  }

  Future<void> _initializeAndCheckFavoriteStatus() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _prefs = await SharedPreferences.getInstance();
      if (mounted) {
        _checkInitialFavoriteStatus();
      }
    });
  }

  Future<String?> _getToken() async {
    if (_prefs == null) _prefs = await SharedPreferences.getInstance();
    return _prefs?.getString('token');
  }

  Future<bool> _isUserLoggedIn() async {
    if (_prefs == null) _prefs = await SharedPreferences.getInstance();
    return _prefs?.getBool('hasLoggedAsUser') ?? false;
  }

  Future<void> _checkInitialFavoriteStatus() async {
    if (!mounted) return;

    final bool userLoggedIn = await _isUserLoggedIn();
    if (!userLoggedIn) {
      if (mounted) {
        setState(() {
          _isFavorite = false;
          _isLoadingInitialStatus = false;
        });
      }
      return;
    }

    if (mounted && _isLoadingInitialStatus == false) {
      setState(() {
        _isLoadingInitialStatus = true;
      });
    } else if (!mounted && !_isLoadingInitialStatus) {
      _isLoadingInitialStatus = true;
    }

    final token = await _getToken();
    if (token == null) {
      if (mounted) {
        setState(() {
          _isFavorite = false;
          _isLoadingInitialStatus = false;
        });
      }
      return;
    }

    try {
      final bool status = await ApiFavorite.checkStatus(
        recipeId: widget.recipe.id,
        token: token,
      );

      if (mounted) {
        setState(() {
          _isFavorite = status;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFavorite = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingInitialStatus = false;
        });
      }
    }
  }

  Future<void> _handleToggleFavorite() async {
    if (!mounted || _isTogglingFavorite) return;

    final bool userLoggedIn = await _isUserLoggedIn();
    if (!userLoggedIn) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Silakan login untuk memfavoritkan resep."),
          ),
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
          const SnackBar(
            content: Text("Sesi tidak valid. Silakan login ulang."),
          ),
        );
        setState(() {
          _isTogglingFavorite = false;
        });
      }
      return;
    }

    try {
      final result = await ApiFavorite.toggle(
        recipeId: widget.recipe.id,
        token: token,
        isCurrentlyFavorite: _isFavorite,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          _isFavorite = !_isFavorite;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }

    } on TimeoutException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Waktu koneksi habis. Coba lagi."),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } on SocketException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Gagal terhubung ke server. Periksa koneksi internet Anda.",
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Terjadi kesalahan: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTogglingFavorite = false;
        });
      }
    }
  }

  Widget _buildImageShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0),
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: AspectRatio(
                  aspectRatio: 1.1,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_isLoadingInitialStatus ||
                          widget.recipe.gambar.isEmpty)
                        _buildImageShimmerPlaceholder(),
                      if (widget.recipe.gambar.isNotEmpty)
                        Image.network(
                          widget.recipe.gambar,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return _isLoadingInitialStatus
                                ? const SizedBox.shrink()
                                : _buildImageShimmerPlaceholder();
                          },
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: Icon(
                                    Icons.fastfood_outlined,
                                    size: 40,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ),
                        ),
                    ],
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
                            Icon(
                              Icons.access_time,
                              color: Colors.orange,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              "${widget.recipe.waktu} Menit",
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        _isLoadingInitialStatus || _isTogglingFavorite
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                color: Colors.red,
                              ),
                            )
                            : GestureDetector(
                              onTap: _handleToggleFavorite,
                              child: Icon(
                                _isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
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
      ),
    );
  }
}