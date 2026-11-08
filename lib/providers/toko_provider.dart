import 'package:flutter/foundation.dart';

import '../models/barang_model.dart';
import '../models/order_model.dart';
import '../models/stok_masuk_model.dart';
import '../services/toko_storage.dart';
import '../utils/id_generator.dart';


typedef HasilOrder = ({OrderModel? order, String? error});


class TokoProvider extends ChangeNotifier {
  TokoProvider({TokoStorage? storage})
      : _storage = storage ?? SharedPrefsTokoStorage();

  final TokoStorage _storage;

  List<BarangModel> _barang = const [];
  List<OrderModel> _order = const []; // terlama → terbaru
  List<StokMasukModel> _masuk = const []; // terlama → terbaru
  bool _siap = false;
  bool _disposed = false;
  Future<void> _antrianSimpan = Future.value();

  bool get siap => _siap;
  List<BarangModel> get barang => _barang;

  /// Order terbaru di urutan pertama.
  List<OrderModel> get order => _order.reversed.toList(growable: false);

  /// Barang masuk terbaru di urutan pertama.
  List<StokMasukModel> get riwayatMasuk => _masuk.reversed.toList(growable: false);

  int get jumlahBarang => _barang.length;
  int get jumlahOrder => _order.length;
  int get jumlahStokMenipis =>
      _barang.where((b) => b.menipis || b.habis).length;

  /// Nilai persediaan = Σ harga × stok.
  int get nilaiStok => _barang.fold(0, (j, b) => j + b.harga * b.stok);

  /// Total nilai seluruh order.
  int get totalPenjualan => _order.fold(0, (j, o) => j + o.total);

  List<String> get kategoriTerpakai {
    final set = _barang.map((b) => b.kategori).toSet();
    return BarangModel.daftarKategori.where(set.contains).toList();
  }

  Future<void> muat() async {
    final data = await _storage.muat();
    if (_disposed) return;
    _barang = List.unmodifiable(data.barang);
    _order = List.unmodifiable(data.order);
    _masuk = List.unmodifiable(data.masuk);
    _siap = true;
    notifyListeners();
  }

  // ===========================================================================
  // Barang
  // ===========================================================================

  BarangModel? cariBarang(String id) {
    for (final b in _barang) {
      if (b.id == id) return b;
    }
    return null;
  }

  bool kodeSudahAda(String kode, {String? kecualiId}) {
    final k = kode.trim().toUpperCase();
    return _barang.any((b) => b.kode.toUpperCase() == k && b.id != kecualiId);
  }

  /// Kode berikutnya yang belum dipakai, mis. BRG-004.
  String sarankanKode() {
    var n = _barang.length + 1;
    while (kodeSudahAda('BRG-${n.toString().padLeft(3, '0')}')) {
      n++;
    }
    return 'BRG-${n.toString().padLeft(3, '0')}';
  }

  /// Mengembalikan false bila kode sudah dipakai barang lain.
  bool tambahBarang(BarangModel barang) {
    if (kodeSudahAda(barang.kode)) return false;
    _terapkan(barang: [..._barang, barang]);
    return true;
  }

  bool perbaruiBarang(BarangModel barang) {
    if (kodeSudahAda(barang.kode, kecualiId: barang.id)) return false;
    if (cariBarang(barang.id) == null) return false;
    _terapkan(
      barang: _barang.map((b) => b.id == barang.id ? barang : b).toList(),
    );
    return true;
  }

  /// Order lama tidak terpengaruh karena menyimpan salinan data barang.
  bool hapusBarang(String id) {
    if (cariBarang(id) == null) return false;
    _terapkan(barang: _barang.where((b) => b.id != id).toList());
    return true;
  }

  // ===========================================================================
  // Barang masuk & koreksi harga/stok
  // ===========================================================================

  /// Mencatat barang masuk: stok bertambah, email pemasok barang diperbarui.
  /// Mengembalikan pesan galat, atau null bila berhasil.
  String? catatBarangMasuk({
    required String barangId,
    required int qty,
    required String emailPemasok,
    DateTime? waktu,
  }) {
    final b = cariBarang(barangId);
    if (b == null) return 'Barang tidak ditemukan';
    if (qty <= 0) return 'Jumlah masuk harus lebih dari 0';

    final catatan = StokMasukModel(
      id: generateId(),
      barangId: b.id,
      kode: b.kode,
      nama: b.nama,
      satuan: b.satuan,
      qty: qty,
      emailPemasok: emailPemasok,
      waktu: waktu ?? DateTime.now(),
    );
    _terapkan(
      barang: _barang
          .map((x) => x.id == b.id
              ? x.copyWith(stok: x.stok + qty, emailPemasok: emailPemasok)
              : x)
          .toList(),
      masuk: [..._masuk, catatan],
    );
    return null;
  }

  /// Mengganti harga jual dan stok (koreksi / stok opname) sekaligus.
  String? ubahHargaStok({
    required String barangId,
    required int harga,
    required int stok,
    required String emailPemasok,
  }) {
    final b = cariBarang(barangId);
    if (b == null) return 'Barang tidak ditemukan';
    if (harga <= 0) return 'Harga harus lebih dari 0';
    if (stok < 0) return 'Stok tidak boleh minus';
    _terapkan(
      barang: _barang
          .map((x) => x.id == b.id
              ? x.copyWith(harga: harga, stok: stok, emailPemasok: emailPemasok)
              : x)
          .toList(),
    );
    return null;
  }

  // ===========================================================================
  // Order
  // ===========================================================================

  /// [qtyPerBarang]: id barang → jumlah. Seluruh order ditolak bila ada satu
  /// baris yang stoknya tidak cukup (tidak ada order setengah jadi).
  HasilOrder buatOrder({
    required String pelanggan,
    String catatan = '',
    required Map<String, int> qtyPerBarang,
    DateTime? waktu,
  }) {
    if (pelanggan.trim().isEmpty) {
      return (order: null, error: 'Nama pelanggan wajib diisi');
    }
    if (qtyPerBarang.isEmpty) {
      return (order: null, error: 'Tambahkan minimal satu barang');
    }

    final items = <OrderItem>[];
    for (final e in qtyPerBarang.entries) {
      final b = cariBarang(e.key);
      if (b == null) {
        return (order: null, error: 'Ada barang yang sudah dihapus dari katalog');
      }
      if (e.value <= 0) {
        return (order: null, error: 'Jumlah ${b.nama} harus lebih dari 0');
      }
      if (e.value > b.stok) {
        return (
          order: null,
          error: 'Stok ${b.nama} hanya ${b.stok} ${b.satuan}',
        );
      }
      items.add(OrderItem(
        barangId: b.id,
        kode: b.kode,
        nama: b.nama,
        satuan: b.satuan,
        harga: b.harga,
        qty: e.value,
      ));
    }

    final baru = OrderModel(
      id: generateId(),
      nomor: _nomorBerikutnya(),
      waktu: waktu ?? DateTime.now(),
      pelanggan: pelanggan.trim(),
      catatan: catatan.trim(),
      items: items,
    );

    final stokBaru = _barang.map((b) {
      final qty = qtyPerBarang[b.id];
      return qty == null ? b : b.copyWith(stok: b.stok - qty);
    }).toList();

    _terapkan(barang: stokBaru, order: [..._order, baru]);
    return (order: baru, error: null);
  }

  /// Menghapus order dan mengembalikan stok barang yang masih ada di katalog.
  bool hapusOrder(String id) {
    final idx = _order.indexWhere((o) => o.id == id);
    if (idx < 0) return false;
    final target = _order[idx];
    final kembali = {for (final i in target.items) i.barangId: i.qty};
    final stokBaru = _barang.map((b) {
      final qty = kembali[b.id];
      return qty == null ? b : b.copyWith(stok: b.stok + qty);
    }).toList();
    _terapkan(
      barang: stokBaru,
      order: _order.where((o) => o.id != id).toList(),
    );
    return true;
  }

  String _nomorBerikutnya() {
    var maks = 0;
    for (final o in _order) {
      final n = int.tryParse(o.nomor.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      if (n > maks) maks = n;
    }
    return 'ORD-${(maks + 1).toString().padLeft(4, '0')}';
  }

  // ===========================================================================
  // Data contoh
  // ===========================================================================

  /// Mengisi katalog contoh. Kode yang sudah ada dilewati.
  void isiDataContoh() {
    const contoh = [
      ['BRG-001', 'Beras Pandan Wangi 5 kg', 'Makanan', 'pak', 72000, 24],
      ['BRG-002', 'Minyak Goreng 2 liter', 'Makanan', 'pcs', 38000, 18],
      ['BRG-003', 'Kopi Bubuk Robusta 250 g', 'Minuman', 'pcs', 27500, 3],
      ['BRG-004', 'Teh Celup isi 25', 'Minuman', 'box', 9500, 40],
      ['BRG-005', 'Buku Tulis A5 isi 10', 'Alat Tulis', 'pak', 32000, 15],
      ['BRG-006', 'Pulpen Gel 0.5 mm', 'Alat Tulis', 'lusin', 41000, 0],
      ['BRG-007', 'Kabel USB-C 1 m', 'Elektronik', 'pcs', 35000, 12],
      ['BRG-008', 'Lampu LED 9 watt', 'Elektronik', 'pcs', 18000, 30],
      ['BRG-009', 'Sabun Cuci Piring 800 ml', 'Rumah Tangga', 'pcs', 16500, 22],
      ['BRG-010', 'Sapu Ijuk', 'Rumah Tangga', 'pcs', 24000, 5],
    ];
    final tambahan = <BarangModel>[];
    for (final c in contoh) {
      if (kodeSudahAda(c[0] as String)) continue;
      tambahan.add(BarangModel(
        id: generateId(),
        kode: c[0] as String,
        nama: c[1] as String,
        kategori: c[2] as String,
        satuan: c[3] as String,
        harga: c[4] as int,
        stok: c[5] as int,
      ));
    }
    if (tambahan.isEmpty) return;
    _terapkan(barang: [..._barang, ...tambahan]);
  }

  // ===========================================================================
  // Internal
  // ===========================================================================

  void _terapkan({
    List<BarangModel>? barang,
    List<OrderModel>? order,
    List<StokMasukModel>? masuk,
  }) {
    if (barang != null) _barang = List.unmodifiable(barang);
    if (order != null) _order = List.unmodifiable(order);
    if (masuk != null) _masuk = List.unmodifiable(masuk);
    notifyListeners();
    _jadwalkanSimpan();
  }

  
  void _jadwalkanSimpan() {
    final snapshot = TokoData(barang: _barang, order: _order, masuk: _masuk);
    _antrianSimpan = _antrianSimpan
        .then((_) => _storage.simpan(snapshot))
        .catchError((Object e) {
      debugPrint('Penyimpanan gagal: $e');
    });
  }

  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
