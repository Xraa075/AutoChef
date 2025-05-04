class Intro {
  final String image;
  final String title;
  final String description;

  Intro({
    required this.image,
    required this.title,
    required this.description,
  });
}

// 🔹 Data Intro
List<Intro> introData = [
  Intro(
    image: "lib/assets/images/image1.png",
    title: "Selamat Datang di AutoChef!",
    description: "Temukan rekomendasi resep terbaik berdasarkan bahan yang kamu miliki.",
  ),
  Intro(
    image: "lib/assets/images/image2.png",
    title: "Masukkan Bahan Masakan",
    description: "Cukup ketik bahan-bahan yang kamu punya dan dapatkan inspirasi masakan.",
  ),
  Intro(
    image: "lib/assets/images/image3.png",
    title: "Mulai Memasak Sekarang!",
    description: "Dapatkan petunjuk langkah demi langkah untuk membuat makanan lezat.",
  ),
];
