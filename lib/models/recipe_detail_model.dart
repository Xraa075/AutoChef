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

  RecipeDetail({
    required this.id,
    required this.namaResep,
    required this.urlGambar,
    required this.waktuMasak,
    this.kategori,
    required this.negara,
    required this.bahan,
    required this.langkahLangkah,
  });

  factory RecipeDetail.fromJson(Map<String, dynamic> json) => RecipeDetail(
        id: json["id"],
        namaResep: json["nama_resep"],
        urlGambar: json["url_gambar"],
        waktuMasak: json["waktu_masak"],
        kategori: json["kategori"],
        negara: json["negara"],
        bahan: List<Bahan>.from(json["bahan"].map((x) => Bahan.fromJson(x))),
        langkahLangkah: List<Langkah>.from(
            json["langkah_langkah"].map((x) => Langkah.fromJson(x))),
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