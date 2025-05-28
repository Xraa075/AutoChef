import 'package:flutter/material.dart';
import 'package:autochef/models/recipe.dart';
import 'package:autochef/views/recipe/components/steps.dart';
import 'package:autochef/views/recipe/components/recipe_info.dart';
import 'package:autochef/views/recipe/components/ingredients.dart';

class DetailMakanan extends StatefulWidget {
  // Mengubah menjadi StatefulWidget
  final Recipe recipe;

  const DetailMakanan({super.key, required this.recipe});

  @override
  State<DetailMakanan> createState() => _DetailMakananState();
}

class _DetailMakananState extends State<DetailMakanan> {
  // Membuat State
  bool isFavorite = false; // Menambahkan state untuk status favorit

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// **Gambar Latar Belakang**
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.network(
              widget.recipe.gambar, // Menggunakan widget.recipe
              width: double.infinity,
              height: 292,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 292,
                  color: Colors.grey[300], // Warna latar belakang abu-abu
                  child: const Center(
                    child: Icon(
                      Icons.fastfood, // Ikon makanan
                      size: 80, // Ukuran ikon
                      color: Colors.grey, // Warna abu-abu
                    ),
                  ),
                );
              },
            ),
          ),

          /// **Tombol Kembali**
          Positioned(
            top: 40, // Jarak dari atas
            left: 10, // Jarak dari kiri
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withOpacity(0.5),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.black,
                  size: 25,
                ),
              ),
            ),
          ),

          /// **Bottom Sheet Bisa Ditarik**
          DraggableScrollableSheet(
            initialChildSize: 0.71,
            minChildSize: 0.71,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(
                          bottom: 10,
                          top: 10,
                        ), // Menambahkan margin top
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
                        // Menggunakan Row untuk menampung nama resep dan ikon
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween, // Agar ikon di paling kanan
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start, // Agar text dan icon align di atas
                        children: [
                          Expanded(
                            // Agar teks nama resep bisa wrap jika panjang
                            child: Text(
                              widget
                                  .recipe
                                  .namaResep, // Menggunakan widget.recipe
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons
                                      .favorite_border, // Menggunakan state isFavorite
                              color:
                                  isFavorite
                                      ? Colors.red
                                      : Colors
                                          .grey, // Warna ikon berdasarkan status
                              size: 30, // Ukuran ikon
                            ),
                            onPressed: () {
                              // Logika untuk menambahkan/menghapus dari favorit akan ditambahkan di sini nanti
                              // Untuk sekarang, kita ubah state nya saja untuk demo UI
                              setState(() {
                                isFavorite = !isFavorite;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 6),

                      /// **Kategori dan Negara**
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${widget.recipe.negara}", // Menggunakan widget.recipe
                            style: TextStyle(
                              fontSize: 18,
                              color: const Color.fromARGB(121, 0, 0, 0),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      /// **Informasi Resep**
                      RecipeInfo(
                        waktu: widget.recipe.waktu, // Menggunakan widget.recipe
                        kalori:
                            widget.recipe.kalori, // Menggunakan widget.recipe
                        protein:
                            widget.recipe.protein, // Menggunakan widget.recipe
                        karbohidrat:
                            widget
                                .recipe
                                .karbohidrat, // Menggunakan widget.recipe
                      ),
                      SizedBox(height: 20),

                      /// **Bahan-bahan**
                      Ingredients(
                        ingredients: widget.recipe.bahan.split(",") ?? [],
                      ), // Menggunakan widget.recipe
                      SizedBox(height: 20),

                      /// **Langkah-langkah**
                      Steps(
                        steps: widget.recipe.steps.split(".") ?? [],
                      ), // Menggunakan widget.recipe
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
