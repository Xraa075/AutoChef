import 'package:shared_preferences/shared_preferences.dart';
import 'package:autochef/models/recipe.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';

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
      if (mounted)
        setState(() {
          _isFavorite = false;
          _isLoadingInitialStatus = false;
        });
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
      if (mounted)
        setState(() {
          _isFavorite = false;
          _isLoadingInitialStatus = false;
        });
      return;
    }

    try {
      final url = Uri.parse(
        'http://156.67.214.60/api/resep/${widget.recipe.id}/is-favorited',
      );
      final response = await http
          .get(
            url,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        bool favorited = false;
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('is_favorited')) {
            favorited =
                responseData['is_favorited'] == true ||
                responseData['is_favorited'] == 1;
          } else if (responseData.containsKey('status')) {
            favorited =
                responseData['status'] == true ||
                responseData['status'] == 'true' ||
                responseData['status'] == 1;
          } else {
            if (responseData.length == 1 && responseData.values.first is bool) {
              favorited = responseData.values.first;
            } else {
              print(
                "HealthyFoodItem (${widget.recipe.namaResep}): Format /is-favorited tidak dikenal: $responseData",
              );
            }
          }
        } else if (responseData is bool) {
          favorited = responseData;
        }

        if (mounted)
          setState(() {
            _isFavorite = favorited;
          });
      } else {
        if (mounted)
          setState(() {
            _isFavorite = false;
          });
        print(
          "HealthyFoodItem (${widget.recipe.namaResep}): Gagal cek status favorit awal: ${response.statusCode}",
        );
      }
    } catch (e) {
      print(
        "HealthyFoodItem (${widget.recipe.namaResep}): Error cek status favorit awal: $e",
      );
      if (mounted)
        setState(() {
          _isFavorite = false;
        });
    } finally {
      if (mounted)
        setState(() {
          _isLoadingInitialStatus = false;
        });
    }
  }

  Future<void> _handleToggleFavorite() async {
    if (!mounted || _isTogglingFavorite) return;

    final bool userLoggedIn = await _isUserLoggedIn();
    if (!userLoggedIn) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Silakan login untuk memfavoritkan resep."),
          ),
        );
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

    final url = Uri.parse(
      'http://156.67.214.60/api/resep/${widget.recipe.id}/favorite',
    );
    http.Response response;

    try {
      if (_isFavorite) {
        response = await http
            .delete(
              url,
              headers: {
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
              },
            )
            .timeout(const Duration(seconds: 15));
      } else {
        response = await http
            .post(
              url,
              headers: {
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
            )
            .timeout(const Duration(seconds: 15));
      }

      if (!mounted) return;

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          (_isFavorite && response.statusCode == 204)) {
        final bool newFavoriteState = !_isFavorite;
        String message =
            newFavoriteState
                ? "Resep ditambahkan ke favorit!"
                : "Resep dihapus dari favorit.";
        if (response.body.isNotEmpty &&
            (response.statusCode == 200 || response.statusCode == 201)) {
          try {
            final responseData = jsonDecode(response.body);
            if (responseData is Map<String, dynamic> &&
                responseData.containsKey('message')) {
              message = responseData['message'];
            }
          } catch (e) {
            print(
              "HealthyFoodItem (${widget.recipe.namaResep}): Gagal parse JSON pesan toggle: $e",
            );
          }
        }
        if (mounted)
          setState(() {
            _isFavorite = newFavoriteState;
          });
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.green),
          );
      } else {
        String errorMessage = "Gagal mengubah status favorit.";
        try {
          final responseData = jsonDecode(response.body);
          if (responseData is Map<String, dynamic> &&
              responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          } else if (response.statusCode == 409 && !_isFavorite) {
            errorMessage = "Resep ini sudah ada di favorit Anda.";
          } else if (response.body.isNotEmpty) {
            errorMessage =
                response.body.length > 100
                    ? "${response.body.substring(0, 100)}..."
                    : response.body;
          }
        } catch (_) {
          print(
            "HealthyFoodItem (${widget.recipe.namaResep}): Gagal parse error body toggle: ${response.body}",
          );
        }
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("$errorMessage (Kode: ${response.statusCode})"),
              backgroundColor: Colors.red,
            ),
          );
      }
    } on TimeoutException {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Waktu koneksi habis. Coba lagi."),
            backgroundColor: Colors.orange,
          ),
        );
    } on SocketException {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Gagal terhubung ke server. Periksa koneksi internet Anda.",
            ),
            backgroundColor: Colors.orange,
          ),
        );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Terjadi kesalahan: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
    } finally {
      if (mounted)
        setState(() {
          _isTogglingFavorite = false;
        });
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
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child:
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
