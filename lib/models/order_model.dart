/// Satu baris barang di dalam order.
///
/// Kode, nama, dan harga disalin (snapshot) saat order dibuat, sehingga
/// riwayat order tidak berubah ketika barang di katalog diedit atau dihapus.
class OrderItem {
  final String barangId;
  final String kode;
  final String nama;
  final String satuan;
  final int harga;
  final int qty;

  const OrderItem({
    required this.barangId,
    required this.kode,
    required this.nama,
    required this.satuan,
    required this.harga,
    required this.qty,
  });

  int get subtotal => harga * qty;

  Map<String, dynamic> toJson() => {
        'barangId': barangId,
        'kode': kode,
        'nama': nama,
        'satuan': satuan,
        'harga': harga,
        'qty': qty,
      };

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      barangId: (json['barangId'] as String?) ?? '',
      kode: (json['kode'] as String?) ?? '',
      nama: (json['nama'] as String?) ?? '',
      satuan: (json['satuan'] as String?) ?? 'pcs',
      harga: (json['harga'] as num?)?.toInt() ?? 0,
      qty: (json['qty'] as num?)?.toInt() ?? 0,
    );
  }
}

class OrderModel {
  final String id;
  final String nomor;
  final DateTime waktu;
  final String pelanggan;
  final String catatan;
  final List<OrderItem> items;

  const OrderModel({
    required this.id,
    required this.nomor,
    required this.waktu,
    required this.pelanggan,
    this.catatan = '',
    required this.items,
  });

  int get total => items.fold(0, (jumlah, i) => jumlah + i.subtotal);
  int get jumlahUnit => items.fold(0, (jumlah, i) => jumlah + i.qty);

  Map<String, dynamic> toJson() => {
        'id': id,
        'nomor': nomor,
        'waktu': waktu.toIso8601String(),
        'pelanggan': pelanggan,
        'catatan': catatan,
        'items': items.map((i) => i.toJson()).toList(),
      };

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: (json['id'] as String?) ?? '',
      nomor: (json['nomor'] as String?) ?? '',
      waktu: json['waktu'] != null
          ? DateTime.tryParse(json['waktu'] as String) ?? DateTime.now()
          : DateTime.now(),
      pelanggan: (json['pelanggan'] as String?) ?? '',
      catatan: (json['catatan'] as String?) ?? '',
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
