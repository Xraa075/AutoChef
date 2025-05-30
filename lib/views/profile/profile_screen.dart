import 'package:shared_preferences/shared_preferences.dart';
import 'package:autochef/models/user.dart';
import 'package:autochef/models/recipe.dart';
import 'package:autochef/data/dummy_user.dart';
import 'package:autochef/views/profile/edit_profile.dart';
import 'package:autochef/views/recipe/recipe_detail_screen.dart';
import 'package:autochef/routes.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'favorite_recipe_item.dart';
import 'package:shimmer/shimmer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Recipe> _favoriteRecipes = [];
  bool _isLoadingFavorites = true;
  String? _favoritesError;
  User? _currentUser;
  SharedPreferences? _prefs;
  bool _favoritesFetchedOnce = false;
  bool _isUserActuallyLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _initializeAndLoadData();
  }

  Future<void> _initializeAndLoadData() async {
    _prefs = await SharedPreferences.getInstance();
    if (mounted) {
      _isUserActuallyLoggedIn = _prefs?.getBool('hasLoggedAsUser') ?? false;
      setState(() {});
    }
  }

  Future<void> _handleUserLoaded(User activeUserFromBuilder) async {
    if (!mounted) return;

    bool userActuallyChanged =
        (_currentUser == null ||
            _currentUser!.email != activeUserFromBuilder.email);
    _currentUser = activeUserFromBuilder;

    _isUserActuallyLoggedIn = _prefs?.getBool('hasLoggedAsUser') ?? false;

    if (_isUserActuallyLoggedIn) {
      if (!_favoritesFetchedOnce || userActuallyChanged) {
        await _fetchFavoriteRecipes();
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoadingFavorites = false;
          _favoriteRecipes = [];
          _favoritesFetchedOnce = true;
          _favoritesError = null;
        });
      }
    }
  }

  Future<String?> _getToken() async {
    return _prefs?.getString('token');
  }

  Future<void> _fetchFavoriteRecipes() async {
    if (!mounted) return;
    if (!_isUserActuallyLoggedIn) {
      if (mounted)
        setState(() {
          _isLoadingFavorites = false;
          _favoriteRecipes = [];
          _favoritesFetchedOnce = true;
        });
      return;
    }

    setState(() {
      _isLoadingFavorites = true;
      _favoritesError = null;
    });
    final token = await _getToken();

    if (token == null) {
      if (mounted)
        setState(() {
          _isLoadingFavorites = false;
          _favoritesError = "Sesi berakhir, silakan login lagi.";
          _favoritesFetchedOnce = true;
        });
      return;
    }

    try {
      final response = await http
          .get(
            Uri.parse('http://156.67.214.60/api/favorites'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 20));

      if (!mounted) return;
      _favoritesFetchedOnce = true;

      if (response.statusCode == 200) {
        List<dynamic> responseDataList;
        final decodedBody = jsonDecode(response.body);

        if (decodedBody is List) {
          responseDataList = decodedBody;
        } else if (decodedBody is Map<String, dynamic> &&
            decodedBody.containsKey('data') &&
            decodedBody['data'] is List) {
          responseDataList = decodedBody['data'];
        } else if (decodedBody is Map<String, dynamic> &&
            decodedBody.containsKey('favorites') &&
            decodedBody['favorites'] is List) {
          responseDataList = decodedBody['favorites'];
        } else {
          print("FETCH FAVORITES - Unknown JSON structure: $decodedBody");
          throw FormatException("Format data dari server tidak dikenali.");
        }

        setState(() {
          _favoriteRecipes =
              responseDataList
                  .whereType<Map<String, dynamic>>()
                  .map((data) => Recipe.fromJson(data))
                  .toList();
        });
      } else {
        String serverMessage = "Gagal memuat resep favorite.";
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map<String, dynamic> &&
              errorData.containsKey('message')) {
            serverMessage = errorData['message'];
          }
        } catch (_) {
          print("FETCH FAVORITES - Gagal parse error body: ${response.body}");
        }
        _favoritesError = "$serverMessage (Kode: ${response.statusCode})";
      }
    } on TimeoutException {
      print("FETCH FAVORITES - TimeoutException: $e");
      _favoritesError = "Waktu koneksi habis. Periksa jaringan Anda.";
    } on SocketException catch (e) {
      print("FETCH FAVORITES - SocketException: $e");
      _favoritesError =
          "Gagal terhubung ke server. Periksa koneksi internet Anda.";
    } on http.ClientException catch (e) {
      print("FETCH FAVORITES - ClientException: $e");
      _favoritesError = "Gagal memuat data. Masalah pada koneksi.";
    } on FormatException catch (e) {
      print("FETCH FAVORITES - FormatException: $e");
      _favoritesError = "Format data dari server tidak valid.";
    } catch (e) {
      print("FETCH FAVORITES - Unknown error: $e");
      _favoritesError =
          "Terjadi kesalahan yang tidak diketahui. Coba lagi nanti.";
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingFavorites = false;
        });
      }
    }
  }

  Future<void> _toggleFavoriteStatus(int recipeId) async {
    if (!mounted || !_isUserActuallyLoggedIn) return;
    final token = await _getToken();
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Silakan login untuk mengubah favorite."),
          ),
        );
      }
      return;
    }

    final url = Uri.parse('http://156.67.214.60/api/resep/$recipeId/favorite');

    try {
      final response = await http
          .delete(
            url,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) {
        String successMessage = "Resep berhasil dihapus dari favorite.";
        if (response.body.isNotEmpty && response.statusCode == 200) {
          try {
            final responseData = jsonDecode(response.body);
            if (responseData is Map<String, dynamic> &&
                responseData.containsKey('message')) {
              successMessage = responseData['message'];
            }
          } catch (e) {
            print("TOGGLE FAVORITE - Gagal parse JSON sukses unfavorite: $e");
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMessage),
              backgroundColor: Colors.green,
            ),
          );
        }
        await _fetchFavoriteRecipes();
      } else {
        String errorMessage = "Gagal menghapus dari favorite.";
        try {
          final responseData = jsonDecode(response.body);
          if (responseData is Map<String, dynamic> &&
              responseData.containsKey('message')) {
            errorMessage = responseData['message'];
          } else if (response.body.isNotEmpty) {
            errorMessage =
                response.body.length > 100
                    ? response.body.substring(0, 100) + "..."
                    : response.body;
          }
        } catch (_) {
          print("TOGGLE FAVORITE - Gagal parse error body: ${response.body}");
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("$errorMessage (Kode: ${response.statusCode})"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } on TimeoutException {
      print("TOGGLE FAVORITE - TimeoutException: $e");
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Waktu koneksi habis. Coba lagi."),
            backgroundColor: Colors.orange,
          ),
        );
    } on SocketException catch (e) {
      print("TOGGLE FAVORITE - SocketException: $e");
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Gagal terhubung ke server. Periksa koneksi internet Anda.",
            ),
            backgroundColor: Colors.orange,
          ),
        );
    } on http.ClientException catch (e) {
      print("TOGGLE FAVORITE - ClientException: $e");
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Gagal mengubah status favorite. Masalah pada koneksi.",
            ),
            backgroundColor: Colors.orange,
          ),
        );
    } on FormatException catch (e) {
      print("TOGGLE FAVORITE - FormatException: $e");
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Format data balasan dari server tidak valid."),
            backgroundColor: Colors.orange,
          ),
        );
    } catch (e) {
      print("TOGGLE FAVORITE - Unknown error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Terjadi kesalahan yang tidak diketahui: ${e.toString()}",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {}
  }

  Future<void> logout(BuildContext context) async {
    if (_prefs == null) _prefs = await SharedPreferences.getInstance();

    await _prefs!.setBool('hasLoggedAsUser', false);
    await _prefs!.remove('username');
    await _prefs!.remove('email');
    await _prefs!.remove('userImage');
    await _prefs!.remove('token');

    if (mounted) {
      setState(() {
        _currentUser = null;
        _favoriteRecipes = [];
        _isLoadingFavorites = true;
        _favoritesError = null;
        _favoritesFetchedOnce = false;
        _isUserActuallyLoggedIn = false;
      });
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.login,
        (route) => false,
      );
    }
  }

  Future<void> _navigateToEditProfile(User currentUserFromBuilder) async {
    if (!mounted || !_isUserActuallyLoggedIn) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => EditProfileScreen(currentUser: currentUserFromBuilder),
      ),
    );
    if (result == true && mounted) {
      setState(() {
        _currentUser = null;
        _favoritesFetchedOnce = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_prefs == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFF46A06)),
        ),
      );
    }

    return FutureBuilder<User>(
      future: getActiveUser(),
      builder: (context, userSnapshot) {
        User? processingUserDisplay = _currentUser;
        if (userSnapshot.connectionState == ConnectionState.waiting &&
            processingUserDisplay == null &&
            _isUserActuallyLoggedIn) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFF46A06)),
            ),
          );
        }

        if (userSnapshot.hasError &&
            processingUserDisplay == null &&
            _isUserActuallyLoggedIn) {
          return Scaffold(
            body: Center(
              child: Text(
                "Error memuat detail pengguna: ${userSnapshot.error}",
              ),
            ),
          );
        }

        User? activeUser =
            _isUserActuallyLoggedIn
                ? (userSnapshot.data ?? processingUserDisplay)
                : userSnapshot.data;

        if (activeUser == null && _isUserActuallyLoggedIn) {
          return const Scaffold(
            body: Center(child: Text("Gagal memuat data pengguna.")),
          );
        }
        if (activeUser == null &&
            !_isUserActuallyLoggedIn &&
            userSnapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFF46A06)),
            ),
          );
        }
        if (activeUser == null &&
            !_isUserActuallyLoggedIn &&
            userSnapshot.connectionState == ConnectionState.done) {
          return const Scaffold(
            body: Center(child: Text("Gagal memuat info tampilan.")),
          );
        }

        if (activeUser != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _handleUserLoaded(activeUser);
          });
        }

        String displayUsername =
            _isUserActuallyLoggedIn
                ? (activeUser?.username ?? "Pengguna")
                : "Pengguna";
        String displayUserImage =
            activeUser?.userImage ?? "lib/assets/images/avatar1.png";

        return Scaffold(
          backgroundColor: const Color(0xFFFBC72A),
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 30),
                    CircleAvatar(
                      backgroundImage: AssetImage(displayUserImage),
                      radius: 45,
                      backgroundColor: Colors.white,
                      onBackgroundImageError: (exception, stackTrace) {
                        print(
                          "Error loading profile image (path: $displayUserImage): $exception",
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Text(
                      displayUsername,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_isUserActuallyLoggedIn && activeUser != null)
                      ElevatedButton.icon(
                        onPressed: () => _navigateToEditProfile(activeUser),
                        icon: const Icon(Icons.edit, color: Colors.black),
                        label: const Text("Edit Profil"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(28),
                            topRight: Radius.circular(28),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(28),
                            topRight: Radius.circular(28),
                          ),
                          child: _buildFavoriteSection(_isUserActuallyLoggedIn),
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: _buildLoginLogoutButton(_isUserActuallyLoggedIn),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginLogoutButton(bool isUserLoggedIn) {
    if (!isUserLoggedIn) {
      return TextButton.icon(
        onPressed: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.login,
            (route) => false,
          );
        },
        icon: const Icon(Icons.login, color: Colors.black),
        label: const Text("Login", style: TextStyle(color: Colors.black)),
      );
    } else {
      return TextButton.icon(
        onPressed: () async {
          final shouldLogout = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                title: Row(
                  children: const [
                    Icon(Icons.help_outline_rounded, color: Color(0xFFF46A06)),
                    SizedBox(width: 10),
                    Text("Konfirmasi Logout"),
                  ],
                ),
                content: const Text(
                  "Apakah Anda yakin ingin logout dari akun ini?",
                  style: TextStyle(fontSize: 15),
                ),
                actionsAlignment: MainAxisAlignment.spaceAround,
                actions: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: 45,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        foregroundColor: Colors.black,
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Batal"),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        backgroundColor: const Color(0xFFF46A06),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Logout"),
                    ),
                  ),
                ],
              );
            },
          );
          if (shouldLogout == true) {
            logout(context);
          }
        },
        icon: const Icon(Icons.logout_rounded, color: Colors.black),
        label: const Text("Logout", style: TextStyle(color: Colors.black)),
      );
    }
  }

  Widget _buildFavoriteSection(bool isUserLoggedIn) {
    if (!isUserLoggedIn) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_border,
                size: 60,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              const Text(
                "Login untuk melihat resep favorite kamu.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16.0, top: 20.0, bottom: 10.0),
          child: Text(
            "Resep Favorite Kamu",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        Expanded(child: _buildFavoriteContent()),
      ],
    );
  }

  Widget _buildFavoriteContent() {
    if (_isLoadingFavorites) {
      return _buildShimmerGridFavorite();
    }

    if (_favoritesError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade300, size: 50),
              const SizedBox(height: 10),
              Text(
                _favoritesError!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red.shade700, fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchFavoriteRecipes,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  backgroundColor: const Color(0xFFF46A06),
                  foregroundColor: Colors.white,
                ),
                child: const Text("Coba Lagi"),
              ),
            ],
          ),
        ),
      );
    }

    if (_favoriteRecipes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bookmarks_outlined, size: 60, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "Kamu belum memiliki resep favorite.\nCari dan tambahkan resep kesukaanmu!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchFavoriteRecipes,
      color: const Color(0xFFF46A06),
      child: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _favoriteRecipes.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.65,
        ),
        itemBuilder: (context, index) {
          final recipe = _favoriteRecipes[index];
          return FavoriteRecipeItem(
            recipe: recipe,
            onItemTap: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailMakanan(recipe: recipe),
                ),
              );
              if (result == true && mounted) {
                _fetchFavoriteRecipes();
              }
            },
            onToggleFavorite: () => _toggleFavoriteStatus(recipe.id),
          );
        },
      ),
    );
  }

  Widget _buildShimmerGridFavorite() {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.65,
      ),
      itemBuilder:
          (context, index) => Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
    );
  }
}
