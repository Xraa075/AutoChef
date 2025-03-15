class Recipe {
  final int id;
  final String namaResep;
  final String bahan;
  final String steps;
  final String gambar;

  Recipe({
    required this.id,
    required this.namaResep,
    required this.bahan,
    required this.steps,
    required this.gambar,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      namaResep: json['nama_resep'],
      bahan: json['bahan'],
      steps: json['steps'],
      gambar: "http://localhost:8000/api/proxy-image?url=${json['gambar']}",
    );
  }
}
