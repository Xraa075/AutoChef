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
  // Tambahan variable baru untuk menyimpan status favorit
  bool is_favorited; 

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
    this.is_favorited = false,
  });

  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;

    return int.tryParse(value.toString()) ?? 0;
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: _parseToInt(json['id']),
      namaResep: json['nama_resep'] ?? '',
      bahan: json['bahan'] ?? '',
      steps: json['steps'] ?? '',
      gambar: json['url_gambar'] ?? json['gambar'] ?? '', 
      kategori: json['kategori']?.toString() ?? '',
      negara: json['negara'] ?? '',
      waktu: _parseToInt(json['waktu_masak'] ?? json['waktu']), 
      kalori: _parseToInt(json['kalori']),
      protein: _parseToInt(json['protein']),
      karbohidrat: _parseToInt(json['karbohidrat']),
      is_favorited: json['is_favorited'] ?? false, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_resep': namaResep,
      'gambar': gambar,
      'negara': negara,
      'waktu': waktu,
      'kalori': kalori,
      'protein': protein,
      'karbohidrat': karbohidrat,
      'bahan': bahan,
      'steps': steps,
      // Langsung mengambil data status favorit yang dikirim oleh server
      'is_favorited': is_favorited,
    };
  }
}