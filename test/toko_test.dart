import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:project_uts/models/barang_model.dart';
import 'package:project_uts/providers/toko_provider.dart';
import 'package:project_uts/services/toko_storage.dart';
import 'package:project_uts/utils/format.dart';
import 'package:project_uts/utils/validators.dart';

/// Storage palsu di memori; lewat JSON agar serialisasi ikut teruji.
class FakeStorage implements TokoStorage {
  String? raw;

  @override
  Future<TokoData> muat() async {
    final data = raw;
    if (data == null) return const TokoData();
    return TokoData.fromJson(jsonDecode(data) as Map<String, dynamic>);
  }

  @override
  Future<void> simpan(TokoData data) async {
    raw = jsonEncode(data.toJson());
  }
}

BarangModel barang({
  String id = 'b1',
  String kode = 'BRG-001',
  int harga = 10000,
  int stok = 10,
}) =>
    BarangModel(
      id: id,
      kode: kode,
      nama: 'Barang $kode',
      kategori: 'Lainnya',
      satuan: 'pcs',
      harga: harga,
      stok: stok,
    );

void main() {
  late FakeStorage storage;
  late TokoProvider p;

  setUp(() {
    storage = FakeStorage();
    p = TokoProvider(storage: storage);
  });

  test('kode barang harus unik (tidak peka huruf besar/kecil)', () {
    expect(p.tambahBarang(barang()), isTrue);
    expect(p.tambahBarang(barang(id: 'b2', kode: 'brg-001')), isFalse);
    expect(p.jumlahBarang, 1);
  });

  test('edit barang boleh mempertahankan kodenya sendiri', () {
    p.tambahBarang(barang());
    expect(p.perbaruiBarang(barang(harga: 12000)), isTrue);
    expect(p.cariBarang('b1')!.harga, 12000);
  });

  test('order mengurangi stok dan menghitung total', () {
    p.tambahBarang(barang(stok: 10, harga: 5000));
    final hasil = p.buatOrder(pelanggan: 'Sari', qtyPerBarang: {'b1': 3});
    expect(hasil.error, isNull);
    expect(hasil.order!.total, 15000);
    expect(hasil.order!.nomor, 'ORD-0001');
    expect(p.cariBarang('b1')!.stok, 7);
  });

  test('order ditolak seluruhnya bila ada stok kurang', () {
    p.tambahBarang(barang(id: 'b1', kode: 'A', stok: 5));
    p.tambahBarang(barang(id: 'b2', kode: 'B', stok: 1));
    final hasil =
        p.buatOrder(pelanggan: 'Sari', qtyPerBarang: {'b1': 2, 'b2': 2});
    expect(hasil.order, isNull);
    expect(hasil.error, isNotNull);
    expect(p.cariBarang('b1')!.stok, 5); // tidak ada yang berkurang
    expect(p.jumlahOrder, 0);
  });

  test('order butuh pelanggan dan minimal satu barang', () {
    p.tambahBarang(barang());
    expect(p.buatOrder(pelanggan: ' ', qtyPerBarang: {'b1': 1}).error, isNotNull);
    expect(p.buatOrder(pelanggan: 'Sari', qtyPerBarang: {}).error, isNotNull);
  });

  test('batalkan order mengembalikan stok', () {
    p.tambahBarang(barang(stok: 10));
    final o = p.buatOrder(pelanggan: 'Sari', qtyPerBarang: {'b1': 4}).order!;
    expect(p.cariBarang('b1')!.stok, 6);
    expect(p.hapusOrder(o.id), isTrue);
    expect(p.cariBarang('b1')!.stok, 10);
  });

  test('riwayat order tetap utuh setelah barang diubah / dihapus', () {
    p.tambahBarang(barang(harga: 5000));
    final o = p.buatOrder(pelanggan: 'Sari', qtyPerBarang: {'b1': 2}).order!;
    p.perbaruiBarang(barang(harga: 9999));
    p.hapusBarang('b1');
    expect(p.order.first.total, 10000);
    expect(o.items.first.nama, 'Barang BRG-001');
    // membatalkan order untuk barang yang sudah dihapus tidak error
    expect(p.hapusOrder(o.id), isTrue);
  });

  test('nomor order berlanjut setelah ada order dibatalkan di tengah', () {
    p.tambahBarang(barang(stok: 100));
    p.buatOrder(pelanggan: 'A', qtyPerBarang: {'b1': 1});
    final o2 = p.buatOrder(pelanggan: 'B', qtyPerBarang: {'b1': 1}).order!;
    expect(o2.nomor, 'ORD-0002');
    expect(p.buatOrder(pelanggan: 'C', qtyPerBarang: {'b1': 1}).order!.nomor,
        'ORD-0003');
  });

  test('data tersimpan lalu dimuat ulang', () async {
    p.tambahBarang(barang());
    p.buatOrder(pelanggan: 'Sari', qtyPerBarang: {'b1': 2});
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    final p2 = TokoProvider(storage: storage);
    await p2.muat();
    expect(p2.jumlahBarang, 1);
    expect(p2.jumlahOrder, 1);
    expect(p2.cariBarang('b1')!.stok, 8);
  });

  test('data contoh tidak menggandakan kode', () {
    p.isiDataContoh();
    final n = p.jumlahBarang;
    p.isiDataContoh();
    expect(p.jumlahBarang, n);
  });

  validasi();

  test('formatRupiah', () {
    expect(formatRupiah(0), 'Rp 0');
    expect(formatRupiah(950), 'Rp 950');
    expect(formatRupiah(1250000), 'Rp 1.250.000');
  });
}

void validasi() {
  group('Validator.angka', () {
    test('menolak huruf, spasi, simbol, dan kosong', () {
      expect(Validator.angka('abc', 'Harga'), isNotNull);
      expect(Validator.angka('12a', 'Harga'), isNotNull);
      expect(Validator.angka('1 000', 'Harga'), isNotNull);
      expect(Validator.angka('1.000', 'Harga'), isNotNull);
      expect(Validator.angka('-5', 'Harga'), isNotNull);
      expect(Validator.angka('', 'Harga'), isNotNull);
    });
    test('menerima angka murni; nol hanya bila diizinkan', () {
      expect(Validator.angka('15000', 'Harga'), isNull);
      expect(Validator.angka('0', 'Stok'), isNull);
      expect(Validator.angka('0', 'Harga', boleNol: false), isNotNull);
    });
  });

  group('Validator.email', () {
    test('menolak huruf kapital', () {
      expect(Validator.email('Nama@gmail.com'), contains('kapital'));
      expect(Validator.email('nama@Gmail.com'), contains('kapital'));
    });
    test('menolak salah ketik gmail.com', () {
      for (final d in ['gmial.com', 'gmai.com', 'gamil.com', 'gmail.con', 'gmail.co', 'gmaill.com']) {
        expect(Validator.email('nama@$d'), contains('gmail.com'), reason: d);
      }
    });
    test('menolak format salah', () {
      expect(Validator.email('nama'), isNotNull);
      expect(Validator.email('nama@gmail'), isNotNull);
      expect(Validator.email('@gmail.com'), isNotNull);
      expect(Validator.email('na ma@gmail.com'), isNotNull);
    });
    test('menerima email benar dan domain lain yang sah', () {
      expect(Validator.email('nama.baru@gmail.com'), isNull);
      expect(Validator.email('a@mail.com'), isNull);
      expect(Validator.email('a@yahoo.com'), isNull);
      expect(Validator.email('a@kampus.ac.id'), isNull);
    });
    test('opsional bila tidak wajib', () {
      expect(Validator.email('', wajib: false), isNull);
      expect(Validator.email(''), isNotNull);
    });
  });

  group('barang masuk & ubah harga/stok', () {
    test('barang masuk menambah stok dan tercatat', () {
      final p = TokoProvider(storage: FakeStorage());
      p.tambahBarang(barang(stok: 4));
      expect(
        p.catatBarangMasuk(
            barangId: 'b1', qty: 6, hargaBeli: 7000, emailPemasok: 'a@gmail.com'),
        isNull,
      );
      expect(p.cariBarang('b1')!.stok, 10);
      expect(p.cariBarang('b1')!.emailPemasok, 'a@gmail.com');
      expect(p.riwayatMasuk.single.totalBeli, 42000);
    });
    test('barang masuk menolak jumlah 0', () {
      final p = TokoProvider(storage: FakeStorage());
      p.tambahBarang(barang());
      expect(
        p.catatBarangMasuk(
            barangId: 'b1', qty: 0, hargaBeli: 1, emailPemasok: 'a@gmail.com'),
        isNotNull,
      );
    });
    test('ubah harga & stok', () {
      final p = TokoProvider(storage: FakeStorage());
      p.tambahBarang(barang());
      expect(
        p.ubahHargaStok(
            barangId: 'b1', harga: 20000, stok: 3, emailPemasok: 'a@gmail.com'),
        isNull,
      );
      final b = p.cariBarang('b1')!;
      expect([b.harga, b.stok], [20000, 3]);
    });
  });
}
