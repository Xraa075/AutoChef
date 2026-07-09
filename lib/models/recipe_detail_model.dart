import 'dart:convert';

RecipeDetail recipeDetailFromJson(String str) =>
    RecipeDetail.fromJson(json.decode(str));


class RecipeDetail {
  final int id;
  final String namaResep;
  final String urlGambar;
  final int waktuMasak;
  final String? kategori;
  final String negara;
  final List<Bahan> bahan;
  final List<Langkah> langkahLangkah;
  final TotalNutrisi? totalNutrisi;

  RecipeDetail({
    required this.id,
    required this.namaResep,
    required this.urlGambar,
    required this.waktuMasak,
    this.kategori,
    required this.negara,
    required this.bahan,
    required this.langkahLangkah,
    this.totalNutrisi,
  });

  factory RecipeDetail.fromJson(Map<String, dynamic> json) => RecipeDetail(
        id: json["id"],
        namaResep: json["nama_resep"],
        urlGambar: json["url_gambar"],
        waktuMasak: json["waktu_masak"],
        kategori: json["kategori"]?.toString(),
        negara: json["negara"]?.toString() ?? '',
        bahan: List<Bahan>.from(json["bahan"].map((x) => Bahan.fromJson(x))),
        langkahLangkah: List<Langkah>.from(
            json["langkah_langkah"].map((x) => Langkah.fromJson(x))),
        totalNutrisi: json["total_nutrisi"] != null 
            ? TotalNutrisi.fromJson(json["total_nutrisi"]) 
            : null,
      );
      
}

class Bahan {
  final int idBahan;
  final String namaBahan;
  final BahanDetail detailBahan;

  Bahan({
    required this.idBahan,
    required this.namaBahan,
    required this.detailBahan,
  });

  factory Bahan.fromJson(Map<String, dynamic> json) => Bahan(
        idBahan: json["id_bahan"],
        namaBahan: json["nama_bahan"],
        detailBahan: BahanDetail.fromJson(json["detail_bahan"]),
      );
}

class BahanDetail {
  final String jumlah;
  final String satuan;
  final String? catatan;

  BahanDetail({
    required this.jumlah,
    required this.satuan,
    this.catatan,
  });

  factory BahanDetail.fromJson(Map<String, dynamic> json) => BahanDetail(
        jumlah: json["jumlah"],
        satuan: json["satuan"],
        catatan: json["catatan"],
      );
}

class Langkah {
  final int urutan;
  final String instruksi;

  Langkah({
    required this.urutan,
    required this.instruksi,
  });

  factory Langkah.fromJson(Map<String, dynamic> json) => Langkah(
        urutan: json["urutan"],
        instruksi: json["instruksi"],
      );
}

class TotalNutrisi {
  final num kaloriKcal;
  final num proteinGram;
  final num karbohidratGram;
  final num lemakGram;
  final num seratGram;

  TotalNutrisi({
    required this.kaloriKcal,
    required this.proteinGram,
    required this.karbohidratGram,
    required this.lemakGram,
    required this.seratGram,
  });

  factory TotalNutrisi.fromJson(Map<String, dynamic> json) {
    return TotalNutrisi(
      kaloriKcal: json['kalori_kcal'] ?? 0,
      proteinGram: json['protein_gram'] ?? 0,
      karbohidratGram: json['karbohidrat_gram'] ?? 0,
      lemakGram: json['lemak_gram'] ?? 0,
      seratGram: json['serat_gram'] ?? 0,
    );
  }
}