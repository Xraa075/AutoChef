import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk keluar dari aplikasi
import 'package:autochef/views/recipe/recommendation_screen.dart';
import 'package:autochef/widgets/header.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class InputRecipe extends StatefulWidget {
  const InputRecipe({super.key});

  @override
  State<InputRecipe> createState() => _InputRecipeState();
}

class _InputRecipeState extends State<InputRecipe> {
  final List<TextEditingController> controllers = [];

  @override
  void initState() {
    super.initState();
    _addInputField(); // Mulai dengan 1 input field
  }

  void _addInputField() {
    if (controllers.length >= 9) {
      _showPopup("Maksimal hanya dapat memasukkan 9 bahan.");
      return;
    }
    setState(() {
      controllers.add(TextEditingController());
    });
  }

  void _removeInputField(int index) {
    if (controllers.length > 1) {
      setState(() {
        controllers[index].dispose();
        controllers.removeAt(index);
      });
    }
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> fetchRecipes() async {
    List<String> bahan =
        controllers.map((controller) => controller.text.trim()).toList();

    // Validasi jika input kosong
    if (bahan.isEmpty || bahan.every((element) => element.isEmpty)) {
      _showPopup("Harap masukkan minimal satu bahan.");
      return;
    }

    String bahanQuery = bahan.join(',');

    String url =
        'http://127.0.0.1:8000/api/resepmakanan/search?bahan=$bahanQuery';

    try {
      final response = await http.get(Uri.parse(url));

      debugPrint("Request URL: $url");
      debugPrint("Response Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data == null || data.isEmpty) {
          _showPopup(
            "Tidak ada resep ditemukan untuk bahan yang kamu masukkan.",
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RekomendationRecipe(bahan: bahan),
          ),
        );
      } else {
        _showPopup("Gagal mendapatkan data resep. Coba lagi nanti.");
      }
    } catch (e) {
      debugPrint("Error: $e");
      _showPopup(
        "Terjadi kesalahan saat mengambil data. Periksa koneksi internetmu.",
      );
    }
  }

  void _showPopup(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          title: Row(
            children: [
              Icon(Icons.info, color: Colors.orange),
              SizedBox(width: 10),
              Text("Informasi"),
            ],
          ),
          content: Text(message, style: TextStyle(fontSize: 15)),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop(); // Tutup aplikasi jika user tekan back
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFBC72A),
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(120),
          child: CustomHeader(
            title:
                "AutoChef siap mecarikan rekomendasi resep sesuai bahan yang kamu miliki",
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 30),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Bahan apa yang kamu miliki?",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Tuliskan bahan-bahanmu",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: _addInputField,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[300],
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(Icons.add, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // List Input Bahan
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: controllers.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Colors.grey!),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      "${index + 1}.",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: controllers[index],
                                        decoration: const InputDecoration(
                                          hintText: "Masukkan Bahan Makanan",
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    if (controllers.length >
                                        1) // Tidak hapus jika hanya 1
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed:
                                            () => _removeInputField(index),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: 46,
                          child: ElevatedButton(
                            onPressed: fetchRecipes,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              'Cari',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
