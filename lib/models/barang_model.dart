/// Satu jenis barang di katalog.
///
/// Immutable: untuk mengubah, pakai [copyWith] lalu serahkan ke provider.
class BarangModel {
  static const List<String> daftarKategori = [
    'Makanan',
    'Minuman',
    'Alat Tulis',
    'Elektronik',
    'Rumah Tangga',
    'Lainnya',
  ];

  static const List<String> daftarSatuan = [
    'pcs',
    'box',
    'pak',
    'lusin',
    'kg',
    'liter',
  ];

  /// Stok di bawah atau sama dengan angka ini dianggap menipis.
  static const int batasStokMenipis = 5;

  final String id;
  final String kode;
  final String nama;
  final String kategori;
  final String satuan;
  final int harga;
  final int stok;
  final String deskripsi;
  final String emailPemasok;

  const BarangModel({
    required this.id,
    required this.kode,
    required this.nama,
    required this.kategori,
    required this.satuan,
    required this.harga,
    required this.stok,
    this.deskripsi = '',
    this.emailPemasok = '',
  });

  bool get habis => stok <= 0;
  bool get menipis => stok > 0 && stok <= batasStokMenipis;

  BarangModel copyWith({
    String? kode,
    String? nama,
    String? kategori,
    String? satuan,
    int? harga,
    int? stok,
    String? deskripsi,
    String? emailPemasok,
  }) {
    return BarangModel(
      id: id,
      kode: kode ?? this.kode,
      nama: nama ?? this.nama,
      kategori: kategori ?? this.kategori,
      satuan: satuan ?? this.satuan,
      harga: harga ?? this.harga,
      stok: stok ?? this.stok,
      deskripsi: deskripsi ?? this.deskripsi,
      emailPemasok: emailPemasok ?? this.emailPemasok,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kode': kode,
        'nama': nama,
        'kategori': kategori,
        'satuan': satuan,
        'harga': harga,
        'stok': stok,
        'deskripsi': deskripsi,
        'emailPemasok': emailPemasok,
      };

  factory BarangModel.fromJson(Map<String, dynamic> json) {
    return BarangModel(
      id: json['id'] as String,
      kode: json['kode'] as String,
      nama: json['nama'] as String,
      kategori: (json['kategori'] as String?) ?? 'Lainnya',
      satuan: (json['satuan'] as String?) ?? 'pcs',
      harga: (json['harga'] as num?)?.toInt() ?? 0,
      stok: (json['stok'] as num?)?.toInt() ?? 0,
      deskripsi: (json['deskripsi'] as String?) ?? '',
      emailPemasok: (json['emailPemasok'] as String?) ?? '',
    );
  }
}
