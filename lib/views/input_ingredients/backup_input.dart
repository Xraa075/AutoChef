// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:autochef/views/recipe/recommendation_screen.dart';
// import 'package:autochef/widgets/header.dart';

// class InputRecipe extends StatefulWidget {
//   const InputRecipe({super.key});

//   @override
//   State<InputRecipe> createState() => InputRecipeState();
// }

// class InputRecipeState extends State<InputRecipe> {
//   final List<TextEditingController> controllers = [];

//   @override
//   void initState() {
//     super.initState();
//     for (int i = 0; i < 1; i++) {
//       controllers.add(TextEditingController());
//     }
//   }

//   void addInputField() {
//     setState(() {
//       controllers.add(TextEditingController());
//     });
//   }

//   void removeInputField(int index) {
//     setState(() {
//       controllers[index].dispose();
//       controllers.removeAt(index);
//     });
//   }

//   Future<void> fetchRecipes() async {
//     List<String> bahan = controllers.map((controller) => controller.text).toList();
//     String bahanQuery = bahan.join(',');

//     String url = 'http://localhost:8000/api/resepmakanan/search?bahan=$bahanQuery';

//     try {
//       final response = await http.get(Uri.parse(url));

//       print("Request URL: $url");
//       print("Response Code: ${response.statusCode}");
//       print("Response Body: ${response.body}");

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         if (data == null || data.isEmpty) {
//           throw Exception('Tidak ada resep ditemukan.');
//         }

//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => RekomendationRecipe(bahan: bahan),
//           ),
//         );
//       } else {
//         throw Exception('Gagal mendapatkan data resep. Kode: ${response.statusCode}');
//       }
//     } catch (e) {
//       print("Error: $e");
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Text("Error"),
//             content: Text("Gagal mendapatkan data resep: $e"),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: const Text("OK"),
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.yellow[600],
//       appBar: const PreferredSize(
//         preferredSize: Size.fromHeight(120), 
//         child: CustomHeader(title: "Ini adalah rekomendasi resep sesuai dengan bahanmu"),
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: Container(
//                 margin: const EdgeInsets.only(top: 30),
//                 padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
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
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "Bahan apa yang kamu miliki?",
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black,
//                               ),
//                             ),
//                             SizedBox(height: 4),
//                             Text(
//                               "Tuliskan bahan-bahanmu",
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.black54,
//                               ),
//                             ),
//                           ],
//                         ),
//                         GestureDetector(
//                           onTap: addInputField,
//                           child: Container(
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: Colors.grey[300],
//                             ),
//                             padding: const EdgeInsets.all(8),
//                             child: const Icon(Icons.add, color: Colors.black),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 30),
//                     Expanded(
//                       child: ListView.builder(
//                         padding: const EdgeInsets.only(bottom: 20),
//                         itemCount: controllers.length,
//                         itemBuilder: (context, index) {
//                           return Padding(
//                             padding: const EdgeInsets.only(bottom: 10),
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 16,
//                                 vertical: 12,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withOpacity(0.9),
//                                 borderRadius: BorderRadius.circular(12),
//                                 border: Border.all(color: Colors.grey[300]!),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.grey.withOpacity(0.1),
//                                     blurRadius: 4,
//                                     offset: const Offset(0, 2),
//                                   ),
//                                 ],
//                               ),
//                               child: Row(
//                                 children: [
//                                   Text(
//                                     "${index + 1}.",
//                                     style: const TextStyle(
//                                       fontSize: 16,
//                                       color: Colors.black,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 8),
//                                   Expanded(
//                                     child: TextField(
//                                       controller: controllers[index],
//                                       decoration: const InputDecoration(
//                                         hintText: "Masukkan Bahan Makanan",
//                                         border: InputBorder.none,
//                                       ),
//                                     ),
//                                   ),
//                                   IconButton(
//                                     icon: const Icon(
//                                       Icons.delete,
//                                       color: Colors.red,
//                                     ),
//                                     onPressed: () => removeInputField(index),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     Center(
//                       child: SizedBox(
//                         width: double.infinity,
//                         height: 48,
//                         child: ElevatedButton(
//                           onPressed: fetchRecipes,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.orange,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: const Text(
//                             'Cari',
//                             style: TextStyle(fontSize: 16, color: Colors.white),
//                           ),
//                         ),
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
// }
