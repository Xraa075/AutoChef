import 'package:flutter/material.dart';
import 'package:autochef/models/recipe.dart';
import 'package:autochef/widgets/header.dart';
import 'package:autochef/widgets/category_item.dart';
import 'package:autochef/services/search_service.dart';
import 'package:autochef/widgets/small_card.dart';
import 'package:autochef/services/api_profile.dart';
import 'package:autochef/services/api_rekomendation.dart';
import 'package:autochef/views/recipe/recipe_detail_screen.dart';
import 'package:autochef/views/recipe/recommendation_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autochef/views/filter_screen/filter_screen.dart';

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
  late FocusNode _searchFocusNode;

  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  late TextEditingController _searchController;
  
  // OPTIMASI 1: Cache SharedPreferences agar tidak getInstance berulang kali
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _searchFocusNode.addListener(() {
      setState(() {});
    });
    
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });

    _fetchInitialData();
    _initSpeech();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _initSpeech() async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      _speechEnabled = await _speechToText.initialize();
      setState(() {});
    } else {
       debugPrint("Izin mikrofon ditolak");
    }
  }

  void _startListening() async {
    if (!_speechEnabled) return;
    await _speechToText.listen(onResult: (result) {
      setState(() {
        _searchController.text = result.recognizedWords;
        _searchController.selection = TextSelection.fromPosition(
          TextPosition(offset: _searchController.text.length),
        );
      });
    }, localeId: 'id_ID');
    setState(() {
      _isListening = true;
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  Future<void> refreshData() async {
    await _fetchInitialData();
  }

  // OPTIMASI 2: Menjalankan pemanggilan data secara paralel dengan Future.wait
  Future<void> _fetchInitialData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none && mounted) {
      _showPopup("Tidak ada koneksi internet. Gagal memuat data.");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    _prefs ??= await SharedPreferences.getInstance();

    // Berjalan bersamaan di background, untuk mengurangi durasi penundaan UI Thread
    await Future.wait([
      _updateUserProfile(),
      getRekomendasi(),
    ]);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserProfile() async {
    try {
      final result = await ApiProfile.getProfile();
      if (result['success'] == true && result['data'] != null) {
        final data = result['data'];
        _prefs ??= await SharedPreferences.getInstance();
        await _prefs!.setString('name', data['name'] ?? 'Pengguna'); 
        await _prefs!.setString('email', data['email'] ?? '');
      }
    } catch (e) {
      debugPrint("Gagal update user profile di home: $e");
    }
  }

  Future<void> getRekomendasi() async {
    try {
      debugPrint('Starting to fetch recommendations');
      final data = await ApiRekomendasi.fetchRekomendasi();
      debugPrint('Received ${data.length} recommendations');

      if (mounted) {
        _rekomendasi = data;
      }
    } catch (e) {
      debugPrint('Error getting recommendations: $e');
      if (mounted) {
        _showPopup("Gagal memuat rekomendasi");
      }
    }
  }

  void _showPopup(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  backgroundColor: const Color(0xFFF46A06),
                ),
                onPressed: () => Navigator.pop(context),
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
    debugPrint('MEMULAI PENCARIAN UNTUK: "${_searchController.text.trim()}"');
    if (_isSearching) return;
    if (_searchController.text.trim().isEmpty) {
      _showPopup("Masukkan kata kunci pencarian");
      return;
    }
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _showPopup("Periksa koneksi internet Anda dan coba lagi.");
      return;
    }
    if (!mounted) return;
    setState(() {
      _isSearching = true;
    });
    try {
      final results = await SearchService.searchResep(_searchController.text);
      if (!mounted) return;

      final hasChanges = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => RekomendationRecipe(results: results),
        ),
      );

      if (hasChanges == true && mounted) {
        await _fetchInitialData();
      }
    } catch (e) {
      _showPopup("Gagal mencari resep");
    } finally {
      if (mounted)
        setState(() {
          _isSearching = false;
        });
    }
  }

  Widget buildShimmerItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }

  // OPTIMASI 3: Memberikan parameter Sliver agar serasi dengan CustomScrollView
  Widget buildShimmerGridSliver() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.65,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => buildShimmerItem(),
          childCount: 6,
        ),
      ),
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
          titleStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            color: Colors.black,
          ),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    textInputAction: TextInputAction.search,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20.0,
                      ),
                      hintText: _searchFocusNode.hasFocus ? '' : 'Cari Resep Makanan',
                      hintStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        color: Colors.black,
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.black),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isListening ? Icons.mic_off : Icons.mic,
                          color: _isListening ? Colors.red : Colors.black,
                        ),
                        onPressed: _speechToText.isListening ? _stopListening : _startListening,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (value) {
                      handleSearch(context);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                //  _isSearching
                //   ? const Padding(
                //       padding: EdgeInsets.symmetric(horizontal: 12.0),
                //       child: SizedBox(
                //         height: 24,
                //         width: 24,
                //         child: CircularProgressIndicator(
                //           color: Colors.black,
                //           strokeWidth: 2.5,
                //         ),
                //       ),
                //     )
                //   : IconButton(
                //       icon: const Icon(Icons.search, color: Colors.black),
                //       onPressed: () {
                //         // Panggil handleSearch saat tombol ditekan
                //         handleSearch(context);
                //       },
                //       style: IconButton.styleFrom(
                //         backgroundColor: Colors.white,
                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(18),
                //         ),
                //       ),
                //     ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(top: 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          // OPTIMASI 4: Migrasi total dari ListView mandiri ke CustomScrollView (Slivers)
          child: RefreshIndicator(
            onRefresh: _fetchInitialData,
            color: const Color(0xFFF46A06),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Kategori",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 15),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (var category in [
                                "Olahan Daging",
                                "Olahan Ayam",
                                "Makanan Laut",
                                "Menu Harian",
                                "Cemilan",
                              ])
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RekomendationRecipe(kategori: category),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade400),
                                      borderRadius: BorderRadius.circular(15),
                                      color: Colors.transparent,
                                    ),
                                    child: Text(
                                      category,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Text(
                            "Rekomendasi",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Kondisi Grid Rekomendasi diubah menjadi bagian dari struktur Slivers
                _isLoading
                    ? buildShimmerGridSliver()
                    : _rekomendasi.isEmpty
                        ? SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 50.0, horizontal: 20.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.ramen_dining_outlined, size: 60, color: Colors.grey.shade400),
                                    const SizedBox(height: 10),
                                    const Text(
                                      "Belum ada rekomendasi saat ini.",
                                      style: TextStyle(fontSize: 16, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            sliver: SliverGrid(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 0.65,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final resep = _rekomendasi[index];
                                  return HealthyFoodItem(
                                    recipe: resep,
                                    onTap: () async {
                                      final result = await Navigator.push<bool>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetailMakanan(recipe: resep),
                                        ),
                                      );
                                      if (result == true && mounted) {
                                        await _fetchInitialData();
                                      }
                                    },
                                  );
                                },
                                childCount: _rekomendasi.length,
                              ),
                            ),
                          ),
                const SliverToBoxAdapter(child: SizedBox(height: 30)),
              ],
            ),
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
      onTap: () async {
        final hasChanges = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => RekomendationRecipe(kategori: kategori),
          ),
        );

        if (hasChanges == true && context.mounted) {
          final homeScreenState = context.findAncestorStateOfType<_HomeScreenState>();
          if (homeScreenState != null) {
            await homeScreenState.refreshData();
          }
        }
      },
      child: CategoryItem(title: title, imagePath: imagePath, onTap: null),
    );
  }
}