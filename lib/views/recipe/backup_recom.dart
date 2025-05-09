// import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:autochef/views/recipe/recipe_detail_screen.dart';
// import 'package:autochef/widgets/recipe_card.dart';
// import 'package:autochef/widgets/header.dart';
// import 'package:autochef/services/api_service.dart';
// import 'package:autochef/models/recipe.dart';

// class RekomendationRecipe extends StatefulWidget {
//   final List<String> bahan;

//   const RekomendationRecipe({super.key, required this.bahan});

//   @override
//   _RekomendationRecipeState createState() => _RekomendationRecipeState();
// }

// class _RekomendationRecipeState extends State<RekomendationRecipe> {
//   late Future<List<Recipe>> _futureRecipes;

//   @override
//   void initState() {
//     super.initState();
//     _futureRecipes = _fetchRecipes();
//   }

//   // 🔍 Fetch data dari API dengan validasi
//   Future<List<Recipe>> _fetchRecipes() async {
//     try {
//       final response = await ApiService().searchRecipes(widget.bahan);

//       debugPrint("Fetching recipes for: ${widget.bahan}");
//       debugPrint("Response: $response");

//       if (response == null || response.isEmpty) {
//         throw Exception("Tidak ada data resep yang ditemukan.");
//       }
//       return response.map<Recipe>((json) => Recipe.fromJson(json)).toList();
//     } catch (e) {
//       debugPrint("Error fetching recipes: $e");
//       // debugPrint("Stacktrace: $stacktrace");
//       // print("Error fetching recipes: $e");
//       return Future.error("Gagal memuat data: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.yellow[600],
//       appBar: const PreferredSize(
//         preferredSize: Size.fromHeight(120),
//         child: CustomHeader(
//           title: "Ini adalah rekomendasi resep sesuai dengan bahanmu",
//         ),
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: Container(
//                 margin: const EdgeInsets.only(top: 30),
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(20),
//                     topRight: Radius.circular(20),
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Padding(
//                       padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
//                       child: Text(
//                         "Rekomendasi",
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.black,
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: FutureBuilder<List<Recipe>>(
//                         future: _futureRecipes,
//                         builder: (context, snapshot) {
//                           if (snapshot.connectionState == ConnectionState.waiting) {
//                             return _buildShimmerLoading();
//                           } else if (snapshot.hasError) {
//                             return _buildErrorWidget(snapshot.error.toString());
//                           } else if (snapshot.data == null || snapshot.data!.isEmpty) {
//                             return _buildNoDataWidget();
//                           }

//                           final recipes = snapshot.data!;
//                           return ListView.builder(
//                             padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//                             itemCount: recipes.length,
//                             itemBuilder: (context, index) {
//                               final recipe = recipes[index];

//                               return RecipeCard(
//                                 recipe: recipe,
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => DetailMakanan(recipe: recipe),
//                                     ),
//                                   );
//                                 },
//                                 image: recipe.gambar,
//                               );
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // 🖼 **Perbaikan: CachedNetworkImage dengan Validasi URL**
//   Widget _buildImage(String? imageUrl) {
//     if (imageUrl == null || imageUrl.isEmpty) {
//       return Image.asset(
//         "assets/images/placeholder.png",
//         fit: BoxFit.cover,
//       );
//     }

//     return CachedNetworkImage(
//       imageUrl: Uri.encodeFull(imageUrl), // Encode URL untuk menghindari error
//       placeholder: (context, url) => Shimmer.fromColors(
//         baseColor: Colors.grey[300]!,
//         highlightColor: Colors.grey[100]!,
//         child: Container(
//           width: double.infinity,
//           height: 150,
//           color: Colors.white,
//         ),
//       ),
//       errorWidget: (context, url, error) => Image.asset(
//         "assets/images/placeholder.png", // Gunakan gambar default jika gagal
//         fit: BoxFit.cover,
//       ),
//       fit: BoxFit.cover,
//     );
//   }

//   // 🔄 **Shimmer Loading**
//   Widget _buildShimmerLoading() {
//     return ListView.builder(
//       itemCount: 5,
//       padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
//       itemBuilder: (context, index) {
//         return Shimmer.fromColors(
//           baseColor: Colors.grey[300]!,
//           highlightColor: Colors.grey[100]!,
//           child: Container(
//             margin: const EdgeInsets.only(bottom: 16),
//             height: 100,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // ❌ **Pesan Error**
//   Widget _buildErrorWidget(String errorMessage) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.error_outline, color: Colors.red, size: 60),
//           const SizedBox(height: 10),
//           const Text(
//             "Terjadi Kesalahan!",
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//           ),
//           const SizedBox(height: 5),
//           Text(errorMessage, textAlign: TextAlign.center),
//         ],
//       ),
//     );
//   }

//   // 📭 **Tidak Ada Data**
//   Widget _buildNoDataWidget() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Image.asset("assets/images/no_data.png", width: 200),
//           const SizedBox(height: 10),
//           const Text(
//             "Resep tidak ditemukan!",
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//           ),
//         ],
//       ),
//     );
//   }
// }
