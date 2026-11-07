/// Catatan barang masuk dari pemasok. Kode/nama disalin saat dicatat
/// agar riwayat tetap terbaca walau barang kemudian dihapus.
class StokMasukModel {
  final String id;
  final String barangId;
  final String kode;
  final String nama;
  final String satuan;
  final int qty;
  final int hargaBeli;
  final String emailPemasok;
  final DateTime waktu;

  const StokMasukModel({
    required this.id,
    required this.barangId,
    required this.kode,
    required this.nama,
    required this.satuan,
    required this.qty,
    required this.hargaBeli,
    required this.emailPemasok,
    required this.waktu,
  });

  int get totalBeli => qty * hargaBeli;

  Map<String, dynamic> toJson() => {
        'id': id,
        'barangId': barangId,
        'kode': kode,
        'nama': nama,
        'satuan': satuan,
        'qty': qty,
        'hargaBeli': hargaBeli,
        'emailPemasok': emailPemasok,
        'waktu': waktu.toIso8601String(),
      };

  factory StokMasukModel.fromJson(Map<String, dynamic> json) {
    return StokMasukModel(
      id: (json['id'] as String?) ?? '',
      barangId: (json['barangId'] as String?) ?? '',
      kode: (json['kode'] as String?) ?? '',
      nama: (json['nama'] as String?) ?? '',
      satuan: (json['satuan'] as String?) ?? 'pcs',
      qty: (json['qty'] as num?)?.toInt() ?? 0,
      hargaBeli: (json['hargaBeli'] as num?)?.toInt() ?? 0,
      emailPemasok: (json['emailPemasok'] as String?) ?? '',
      waktu: json['waktu'] != null
          ? DateTime.tryParse(json['waktu'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
