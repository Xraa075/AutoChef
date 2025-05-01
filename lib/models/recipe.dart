class Recipe {
  final int id;
  final String namaResep;
  final String bahan;
  final String steps;
  final String gambar;
  final String kategori;
  final String negara;
  final int waktu;
  final int kalori;
  final int protein;
  final int karbohidrat;

  Recipe({
    required this.id,
    required this.namaResep,
    required this.bahan,
    required this.steps,
    required this.gambar,
    required this.kategori,
    required this.negara,
    required this.waktu,
    required this.kalori,
    required this.protein,
    required this.karbohidrat,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      namaResep: json['nama_resep'],
      bahan: json['bahan'],
      steps: json['steps'],
      gambar: json['gambar'],
      kategori: json['kategori'],
      negara: json['negara'],
      waktu: json['waktu'],
      kalori: json['kalori'],
      protein: json['protein'],
      karbohidrat: json['karbohidrat'],
    );
  }
}
