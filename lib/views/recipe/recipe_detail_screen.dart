// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:autochef/models/recipe.dart';
// import 'package:autochef/views/recipe/components/steps.dart';
// import 'package:autochef/views/recipe/components/recipe_info.dart';
// import 'package:autochef/views/recipe/components/ingredients.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:autochef/services/api_rekomendation.dart';
// import 'dart:convert';
// import 'dart:async';

// class DetailMakanan extends StatefulWidget {
//   final Recipe recipe;

//   const DetailMakanan({super.key, required this.recipe});

//   @override
//   State<DetailMakanan> createState() => _DetailMakananState();
// }

// class _DetailMakananState extends State<DetailMakanan> {
//   bool _isFavorite = false;
//   bool _isLoadingInitialStatus = true;
//   bool _isTogglingFavorite = false;
//   SharedPreferences? _prefs;
//   bool _didFavoriteStatusChangeThisSession = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeAndCheckFavoriteStatus();
//     _logRecipeView();
//   }

//   Future<void> _logRecipeView() async {
//   await Future.delayed(Duration(milliseconds: 300));
//   if (!mounted) return;
  
//   try {
//     final bool userLoggedIn = await _isUserLoggedIn();
//     if (userLoggedIn) {
//       await ApiRekomendasi.logRecipeView(widget.recipe.id);
//     }
//   } catch (e) {
//     debugPrint('Error when logging recipe view: $e');
//   }
// }

//   Future<void> _initializeAndCheckFavoriteStatus() async {
//     _prefs = await SharedPreferences.getInstance();
//     if (mounted) {
//       _checkInitialFavoriteStatus();
//     }
//   }

//   Future<String?> _getToken() async {
//     if (_prefs == null) _prefs = await SharedPreferences.getInstance();
//     return _prefs?.getString('token');
//   }

//   Future<bool> _isUserLoggedIn() async {
//     if (_prefs == null) _prefs = await SharedPreferences.getInstance();
//     return _prefs?.getBool('hasLoggedAsUser') ?? false;
//   }

//   Future<void> _checkInitialFavoriteStatus() async {
//     if (!mounted) return;
//     setState(() {
//       _isLoadingInitialStatus = true;
//     });

//     final bool userLoggedIn = await _isUserLoggedIn();
//     if (!userLoggedIn) {
//       if (mounted)
//         setState(() {
//           _isFavorite = false;
//           _isLoadingInitialStatus = false;
//         });
//       return;
//     }

//     final token = await _getToken();
//     if (token == null) {
//       if (mounted)
//         setState(() {
//           _isFavorite = false;
//           _isLoadingInitialStatus = false;
//         });
//       return;
//     }

//     try {
//       final url = Uri.parse(
//         'http://20.6.107.2:8002/api/resep/${widget.recipe.id}/is-favorited',
//       );
//       final response = await http
//           .get(
//             url,
//             headers: {
//               'Accept': 'application/json',
//               'Authorization': 'Bearer $token',
//             },
//           )
//           .timeout(const Duration(seconds: 15));

//       if (!mounted) return;

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         bool favorited = false;
//         if (responseData is Map<String, dynamic>) {
//           if (responseData.containsKey('is_favorited')) {
//             favorited =
//                 responseData['is_favorited'] == true ||
//                 responseData['is_favorited'] == 1;
//           } else if (responseData.containsKey('status')) {
//             favorited =
//                 responseData['status'] == true ||
//                 responseData['status'] == 'true' ||
//                 responseData['status'] == 1;
//           } else {
//             if (responseData.length == 1 && responseData.values.first is bool) {
//               favorited = responseData.values.first;
//             } else {
//             }
//           }
//         } else if (responseData is bool) {
//           favorited = responseData;
//         }
//         setState(() {
//           _isFavorite = favorited;
//         });
//       } else {
//         if (mounted)
//           setState(() {
//             _isFavorite = false;
//           });
//       }
//     } catch (e) {
//       if (mounted)
//         setState(() {
//           _isFavorite = false;
//         });
//     } finally {
//       if (mounted)
//         setState(() {
//           _isLoadingInitialStatus = false;
//         });
//     }
//   }

//   Future<void> _handleToggleFavorite() async {
//     if (!mounted || _isTogglingFavorite) return;

//     final bool userLoggedIn = await _isUserLoggedIn();
//     if (!userLoggedIn) {
//       if (mounted)
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Silakan login untuk menambahkan ke favorit."),
//           ),
//         );
//       return;
//     }

//     setState(() {
//       _isTogglingFavorite = true;
//     });
//     final token = await _getToken();

//     if (token == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Sesi tidak valid. Silakan login ulang."),
//           ),
//         );
//         setState(() {
//           _isTogglingFavorite = false;
//         });
//       }
//       return;
//     }

//     final url = Uri.parse(
//       'http://20.6.107.2:8002/api/resep/${widget.recipe.id}/favorite',
//     );
//     http.Response response;

//     try {
//       if (_isFavorite) {
//         response = await http
//             .delete(
//               url,
//               headers: {
//                 'Accept': 'application/json',
//                 'Authorization': 'Bearer $token',
//               },
//             )
//             .timeout(const Duration(seconds: 15));
//       } else {
//         response = await http
//             .post(
//               url,
//               headers: {
//                 'Accept': 'application/json',
//                 'Authorization': 'Bearer $token',
//                 'Content-Type': 'application/json',
//               },
//             )
//             .timeout(const Duration(seconds: 15));
//       }

//       if (!mounted) return;

//       if (response.statusCode == 200 ||
//           response.statusCode == 201 ||
//           (_isFavorite && response.statusCode == 204)) {
//         final bool newFavoriteState = !_isFavorite;
//         _didFavoriteStatusChangeThisSession = true;
//         String message =
//             newFavoriteState
//                 ? "Berhasil ditambahkan ke favorit!"
//                 : "Berhasil dihapus dari favorit.";

//         if (response.body.isNotEmpty &&
//             (response.statusCode == 200 || response.statusCode == 201)) {
//           try {
//             final responseData = jsonDecode(response.body);
//             if (responseData is Map<String, dynamic> &&
//                 responseData.containsKey('message')) {
//               message = responseData['message'];
//             }
//           } catch (e) {
//           }
//         }
//         setState(() {
//           _isFavorite = newFavoriteState;
//         });
//         if (mounted)
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(message), backgroundColor: Colors.green),
//           );
//       } else {
//         String errorMessage = "Gagal mengubah status favorit.";
//         try {
//           final responseData = jsonDecode(response.body);
//           if (responseData is Map<String, dynamic> &&
//               responseData.containsKey('message')) {
//             errorMessage = responseData['message'];
//           } else if (response.statusCode == 409 && !_isFavorite) {
//             errorMessage = "Resep ini sudah ada di favorit Anda.";
//           } else if (response.body.isNotEmpty) {
//             errorMessage =
//                 response.body.length > 100
//                     ? "${response.body.substring(0, 100)}..."
//                     : response.body;
//           }
//         } catch (_) {
//         }
//         if (mounted)
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text("$errorMessage (Kode: ${response.statusCode})"),
//               backgroundColor: Colors.red,
//             ),
//           );
//       }
//     } on TimeoutException {
//       if (mounted)
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Waktu koneksi habis. Coba lagi."),
//             backgroundColor: Colors.orange,
//           ),
//         );
//     } on SocketException {
//       if (mounted)
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text(
//               "Gagal terhubung ke server. Periksa koneksi internet Anda.",
//             ),
//             backgroundColor: Colors.orange,
//           ),
//         );
//     } catch (e) {
//       if (mounted)
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Terjadi kesalahan: ${e.toString()}"),
//             backgroundColor: Colors.red,
//           ),
//         );
//     } finally {
//       if (mounted)
//         setState(() {
//           _isTogglingFavorite = false;
//         });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         Navigator.pop(context, _didFavoriteStatusChangeThisSession);
//         return false;
//       },
//       child: Scaffold(
//         body: Stack(
//           children: [
//             Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               child: Image.network(
//                 widget.recipe.gambar,
//                 width: double.infinity,
//                 height: 292,
//                 fit: BoxFit.cover,
//                 filterQuality: FilterQuality.high,
//                 errorBuilder: (context, error, stackTrace) {
//                   return Container(
//                     width: double.infinity,
//                     height: 292,
//                     color: Colors.grey[300],
//                     child: const Center(
//                       child: Icon(Icons.fastfood, size: 80, color: Colors.grey),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             Positioned(
//               top: 40,
//               left: 10,
//               child: Container(
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: Colors.grey.withOpacity(0.5),
//                 ),
//                 child: IconButton(
//                   onPressed: () {
//                     Navigator.pop(
//                       context,
//                       _didFavoriteStatusChangeThisSession,
//                     );
//                   },
//                   icon: const Icon(
//                     Icons.arrow_back_ios_new_rounded,
//                     color: Colors.black,
//                     size: 25,
//                   ),
//                 ),
//               ),
//             ),
//             DraggableScrollableSheet(
//               initialChildSize: 0.71,
//               minChildSize: 0.71,
//               maxChildSize: 0.9,
//               builder: (context, scrollController) {
//                 return ClipRRect(
//                   borderRadius: const BorderRadius.vertical(
//                     top: Radius.circular(30),
//                   ),
//                   child: Container(
//                     padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
//                     decoration: const BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.vertical(
//                         top: Radius.circular(30),
//                       ),
//                     ),
//                     child: ListView(
//                       controller: scrollController,
//                       children: [
//                         Container(
//                           alignment: Alignment.center,
//                           margin: const EdgeInsets.only(bottom: 10, top: 10),
//                           child: Container(
//                             width: 50,
//                             height: 5,
//                             decoration: BoxDecoration(
//                               color: Colors.grey,
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 widget.recipe.namaResep,
//                                 style: const TextStyle(
//                                   fontSize: 24,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                             _isLoadingInitialStatus || _isTogglingFavorite
//                                 ? const Padding(
//                                   padding: EdgeInsets.all(8.0),
//                                   child: SizedBox(
//                                     width: 30,
//                                     height: 30,
//                                     child: CircularProgressIndicator(
//                                       strokeWidth: 2.5,
//                                       color: Colors.red,
//                                     ),
//                                   ),
//                                 )
//                                 : IconButton(
//                                   icon: Icon(
//                                     _isFavorite
//                                         ? Icons.favorite
//                                         : Icons.favorite_border,
//                                     color:
//                                         _isFavorite ? Colors.red : Colors.grey,
//                                     size: 30,
//                                   ),
//                                   onPressed: _handleToggleFavorite,
//                                 ),
//                           ],
//                         ),
//                         const SizedBox(height: 6),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               widget.recipe.negara,
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 color: const Color.fromARGB(121, 0, 0, 0),
//                                 fontWeight: FontWeight.w500,
//                                 letterSpacing: 0.5,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         RecipeInfo(
//                           waktu: widget.recipe.waktu,
//                           kalori: widget.recipe.kalori,
//                           protein: widget.recipe.protein,
//                           karbohidrat: widget.recipe.karbohidrat,
//                         ),
//                         const SizedBox(height: 20),
//                         Ingredients(
//                           ingredients:
//                               widget.recipe.bahan
//                                   .split(",")
//                                   .map((e) => e.trim())
//                                   .where((e) => e.isNotEmpty)
//                                   .toList(),
//                         ),
//                         const SizedBox(height: 20),
//                         Steps(
//                           steps:
//                               widget.recipe.steps
//                                   .split(".")
//                                   .map((e) => e.trim())
//                                   .where((e) => e.isNotEmpty)
//                                   .toList(),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }\

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:autochef/models/recipe.dart';
import 'package:autochef/views/recipe/components/steps.dart';
import 'package:autochef/views/recipe/components/recipe_info.dart';
import 'package:autochef/views/recipe/components/ingredients.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autochef/services/api_rekomendation.dart';

class DetailMakanan extends StatefulWidget {
  final Recipe recipe;

  const DetailMakanan({super.key, required this.recipe});

  @override
  State<DetailMakanan> createState() => _DetailMakananState();
}

class _DetailMakananState extends State<DetailMakanan> {
  @override
  void initState() {
    super.initState();
    _logRecipeView();
  }

  Future<void> _addRecipeToMealPlanner(String day, Recipe recipe) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'meal_planner_$day';
    List<String> recipesJson = prefs.getStringList(key) ?? [];
    String newRecipeJson = jsonEncode(recipe.toJson());
    if (!recipesJson.contains(newRecipeJson)) {
      recipesJson.add(newRecipeJson);
      await prefs.setStringList(key, recipesJson);
      debugPrint('Berhasil menyimpan resep JSON untuk hari $day');
    } else {
      debugPrint('Resep ini sudah ada untuk hari $day');
    }
  }

  Future<void> _logRecipeView() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userLoggedIn = prefs.getBool('hasLoggedAsUser') ?? false;
      if (userLoggedIn) {
        await ApiRekomendasi.logRecipeView(widget.recipe.id);
      }
    } catch (e) {
      debugPrint('Error when logging recipe view: $e');
    }
  }

  void _showAddToMealPlannerDialog() {
    final List<String> days = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          backgroundColor: Colors.white,
          title: const Text(
            'Simpan resep untuk hari apa?',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, fontFamily: 'Poppins'),
          ),
          content: Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: days.map((day) {
              return ElevatedButton(
                onPressed: () {
                  // Logika penyimpanan diabaikan untuk saat ini
                  debugPrint('Menambahkan resep "${widget.recipe.namaResep}" ke hari $day');
                  _addRecipeToMealPlanner(day, widget.recipe);
                  Navigator.pop(dialogContext); // Tutup dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Resep berhasil ditambahkan ke hari $day!'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF46A06), // Warna oranye
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                ),
                child: Text(day),
              );
            }).toList(),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.only(bottom: 20, top: 10),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
              ),
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // WillPopScope dihapus karena tidak ada lagi status favorit yang perlu dikirim kembali
    return Scaffold(
      body: Stack(
        children: [
          // Gambar Latar Belakang
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.network(
              widget.recipe.gambar,
              width: double.infinity,
              height: 292,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 292,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.fastfood, size: 80, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          // Tombol Kembali
          Positioned(
            top: 40,
            left: 10,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withOpacity(0.5),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.black,
                  size: 25,
                ),
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.71,
            minChildSize: 0.71,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(bottom: 10, top: 10),
                        child: Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.recipe.namaResep,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: Color(0xFFF46A06),
                              size: 32,
                            ),
                            onPressed: _showAddToMealPlannerDialog,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.recipe.negara,
                        style: TextStyle(
                          fontSize: 18,
                          color: const Color.fromARGB(121, 0, 0, 0),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      RecipeInfo(
                        waktu: widget.recipe.waktu,
                        kalori: widget.recipe.kalori,
                        protein: widget.recipe.protein,
                        karbohidrat: widget.recipe.karbohidrat,
                      ),
                      const SizedBox(height: 20),
                      Ingredients(
                        ingredients: widget.recipe.bahan.split(",").map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                      ),
                      const SizedBox(height: 20),
                      Steps(
                        steps: widget.recipe.steps.split(".").map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}