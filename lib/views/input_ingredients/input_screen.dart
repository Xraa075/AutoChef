import 'package:autochef/views/recipe/recommendation_screen.dart';
import 'package:autochef/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';

class InputRecipe extends StatefulWidget {
  const InputRecipe({super.key});

  @override
  State<InputRecipe> createState() => _InputRecipeState();
}

class _InputRecipeState extends State<InputRecipe> {
  final List<TextEditingController> controllers = [];
  final List<FocusNode> focusNodes = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _addInputField();
  }

  void _addInputField() {
    if (controllers.length >= 9) {
      _showPopup("Maksimal hanya dapat memasukkan 9 bahan.");
      return;
    }
    setState(() {
      controllers.add(TextEditingController());
      focusNodes.add(FocusNode());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (focusNodes.isNotEmpty) {
        FocusScope.of(context).requestFocus(focusNodes.last);
      }
    });
  }

  void _removeInputField(int index) {
    if (controllers.length > 1) {
      setState(() {
        controllers[index].dispose();
        controllers.removeAt(index);

        focusNodes[index].dispose();
        focusNodes.removeAt(index);
      });
    }
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> fetchRecipes() async {
    List<String> bahan =
        controllers.map((controller) => controller.text.trim()).toList();

    if (bahan.isEmpty || bahan.any((element) => element.isEmpty)) {
      _showPopup("Harap isi seluruh form dengan bahan yang kamu miliki");
      return;
    }

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _showPopup("Kamu sedang offline. Periksa koneksi internetmu.");
      return;
    }

    setState(() => isLoading = true);

    String bahanQuery = bahan.join(',');
    String url = 'http://156.67.214.60/api/resepmakanan?bahan=$bahanQuery';

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
      _showPopup("Terjadi kesalahan saat mengambil data. Coba lagi nanti.");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showPopup(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: Row(
            children: [
              Icon(Icons.info, color: Color(0xFFF46A06)),
              SizedBox(width: 10),
              Text("Informasi"),
            ],
          ),
          content: Text(message, style: TextStyle(fontSize: 16)),
          actions: [
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF46A06),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
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
        SystemNavigator.pop();
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
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
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
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: _addInputField,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFF46A06),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(Icons.add, color: Colors.white),
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
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: Colors.grey),
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
                                        focusNode: focusNodes[index],
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                            RegExp(r'[a-zA-Z\s]'),
                                          ),
                                        ],
                                        decoration: const InputDecoration(
                                          hintText: "Masukkan Bahan Makanan",
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    if (controllers.length > 1)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Color(0xFFF46A06),
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
                          height: 45,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : fetchRecipes,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFF46A06),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child:
                                isLoading
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    )
                                    : const Text(
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
