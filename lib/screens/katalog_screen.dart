import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/barang_model.dart';
import '../providers/toko_provider.dart';
import '../utils/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common_widgets.dart';
import 'barang_form_screen.dart';
import 'order_form_screen.dart';

enum _Urutan {
  nama('Nama A–Z'),
  termurah('Harga terendah'),
  termahal('Harga tertinggi'),
  stokTerbanyak('Stok terbanyak'),
  stokTersedikit('Stok tersedikit');

  final String label;
  const _Urutan(this.label);
}

/// Katalog barang: pencarian, filter kategori, pengurutan, dan detail barang.
class KatalogScreen extends StatefulWidget {
  const KatalogScreen({super.key});

  @override
  State<KatalogScreen> createState() => _KatalogScreenState();
}

class _KatalogScreenState extends State<KatalogScreen> {
  String _cari = '';
  String? _kategori; // null = semua
  _Urutan _urutan = _Urutan.nama;

  List<BarangModel> _saring(List<BarangModel> semua) {
    final q = _cari.trim().toLowerCase();
    final hasil = semua.where((b) {
      if (_kategori != null && b.kategori != _kategori) return false;
      if (q.isEmpty) return true;
      return b.nama.toLowerCase().contains(q) ||
          b.kode.toLowerCase().contains(q);
    }).toList();

    int cmpNama(BarangModel a, BarangModel b) =>
        a.nama.toLowerCase().compareTo(b.nama.toLowerCase());

    hasil.sort((a, b) {
      switch (_urutan) {
        case _Urutan.nama:
          return cmpNama(a, b);
        case _Urutan.termurah:
          return a.harga != b.harga ? a.harga - b.harga : cmpNama(a, b);
        case _Urutan.termahal:
          return a.harga != b.harga ? b.harga - a.harga : cmpNama(a, b);
        case _Urutan.stokTerbanyak:
          return a.stok != b.stok ? b.stok - a.stok : cmpNama(a, b);
        case _Urutan.stokTersedikit:
          return a.stok != b.stok ? a.stok - b.stok : cmpNama(a, b);
      }
    });
    return hasil;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TokoProvider>();
    final kategori = provider.kategoriTerpakai;
    // Filter yang kategorinya sudah tidak punya barang dianggap tidak aktif.
    final aktif = kategori.contains(_kategori) ? _kategori : null;
    if (aktif != _kategori) _kategori = aktif;

    final hasil = _saring(provider.barang);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog'),
        actions: [
          PopupMenuButton<_Urutan>(
            tooltip: 'Urutkan',
            icon: const Icon(Icons.sort),
            initialValue: _urutan,
            onSelected: (u) => setState(() => _urutan = u),
            itemBuilder: (_) => _Urutan.values
                .map((u) => PopupMenuItem(value: u, child: Text(u.label)))
                .toList(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const BarangFormScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Barang'),
      ),
      body: provider.barang.isEmpty
          ? KeadaanKosong(
              judul: 'Katalog masih kosong',
              pesan:
                  'Tambahkan barang lewat tombol di kanan bawah, atau isi dengan data contoh untuk mencoba aplikasi.',
              aksi: OutlinedButton(
                onPressed: provider.isiDataContoh,
                child: const Text('Isi data contoh'),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: TextField(
                    onChanged: (v) => setState(() => _cari = v),
                    decoration: const InputDecoration(
                      hintText: 'Cari nama atau kode barang',
                      prefixIcon: Icon(Icons.search, size: 20),
                    ),
                  ),
                ),
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _FilterChip(
                        label: 'Semua',
                        aktif: _kategori == null,
                        onTap: () => setState(() => _kategori = null),
                      ),
                      for (final k in kategori)
                        _FilterChip(
                          label: k,
                          aktif: _kategori == k,
                          onTap: () => setState(() => _kategori = k),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${hasil.length} barang · ${_urutan.label}',
                          style: const TextStyle(
                              fontSize: 12.5, color: AppTheme.tintaRedup),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: hasil.isEmpty
                      ? const KeadaanKosong(
                          judul: 'Tidak ditemukan',
                          pesan:
                              'Coba kata kunci lain atau pilih kategori Semua.',
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 240,
                            mainAxisExtent: 172,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: hasil.length,
                          itemBuilder: (_, i) => _KartuBarang(
                            barang: hasil[i],
                            onTap: () => _bukaDetail(hasil[i].id),
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  void _bukaDetail(String id) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _DetailBarang(barangId: id),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool aktif;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.aktif,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: aktif ? AppTheme.tinta : Colors.transparent,
            border: Border.all(color: aktif ? AppTheme.tinta : AppTheme.garis),
            borderRadius: BorderRadius.circular(AppTheme.radius),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: aktif ? AppTheme.kertas : AppTheme.tinta,
            ),
          ),
        ),
      ),
    );
  }
}

class _KartuBarang extends StatelessWidget {
  final BarangModel barang;
  final VoidCallback onTap;

  const _KartuBarang({required this.barang, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final warna = AppTheme.warnaKategori(barang.kategori);
    return Material(
      color: AppTheme.permukaan,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        side: const BorderSide(color: AppTheme.garis),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pita kategori: pengganti foto produk.
            Container(
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              color: warna.withValues(alpha: 0.10),
              child: Row(
                children: [
                  Text(barang.kode,
                      style: AppTheme.mono(
                          size: 11, weight: FontWeight.w600, color: warna)),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      barang.kategori,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: warna),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      barang.nama,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14,
                          height: 1.25,
                          fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Text(
                      formatRupiah(barang.harga),
                      style: AppTheme.mono(
                          size: 14,
                          weight: FontWeight.w700,
                          color: AppTheme.tinta),
                    ),
                    const SizedBox(height: 4),
                    StokLabel(barang: barang, ukuran: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Detail barang. Membaca ulang dari provider agar ikut berubah setelah edit.
class _DetailBarang extends StatelessWidget {
  final String barangId;
  const _DetailBarang({required this.barangId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TokoProvider>();
    final b = provider.cariBarang(barangId);
    if (b == null) return const SizedBox(height: 1);

    final warna = AppTheme.warnaKategori(b.kategori);
    final navigator = Navigator.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(b.kode,
                    style: AppTheme.mono(
                        size: 12, weight: FontWeight.w600, color: warna)),
                const SizedBox(width: 8),
                Text(b.kategori, style: TextStyle(fontSize: 12, color: warna)),
              ],
            ),
            const SizedBox(height: 6),
            Text(b.nama,
                style: const TextStyle(
                    fontSize: 21, height: 1.25, fontWeight: FontWeight.w600)),
            const SizedBox(height: 14),
            Text(formatRupiah(b.harga),
                style: AppTheme.mono(
                    size: 22, weight: FontWeight.w700, color: AppTheme.tinta)),
            Text('per ${b.satuan}',
                style: const TextStyle(
                    fontSize: 12.5, color: AppTheme.tintaRedup)),
            const SizedBox(height: 16),
            const Divider(),
            _baris('Stok', StokLabel(barang: b, ukuran: 14)),
            const Divider(),
            _baris(
              'Nilai persediaan',
              Text(formatRupiah(b.harga * b.stok),
                  style: AppTheme.mono(
                      size: 13, weight: FontWeight.w600, color: AppTheme.tinta)),
            ),
            const Divider(),
            if (b.deskripsi.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(b.deskripsi,
                  style: const TextStyle(
                      fontSize: 14, height: 1.5, color: AppTheme.tinta)),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: b.habis
                  ? null
                  : () {
                      navigator.pop();
                      navigator.push(MaterialPageRoute(
                          builder: (_) => OrderFormScreen(barangAwalId: b.id)));
                    },
              child: Text(b.habis ? 'Stok habis' : 'Buat order'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      navigator.pop();
                      navigator.push(MaterialPageRoute(
                          builder: (_) => BarangFormScreen(barang: b)));
                    },
                    child: const Text('Ubah'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.merah,
                      side: const BorderSide(color: AppTheme.merah),
                    ),
                    onPressed: () async {
                      final ya = await konfirmasi(
                        context,
                        judul: 'Hapus barang?',
                        pesan:
                            '${b.nama} akan dihapus dari katalog. Riwayat order tetap tersimpan.',
                      );
                      if (!ya || !context.mounted) return;
                      navigator.pop();
                      provider.hapusBarang(b.id);
                    },
                    child: const Text('Hapus'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _baris(String label, Widget nilai) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 14, color: AppTheme.tintaRedup)),
          ),
          nilai,
        ],
      ),
    );
  }
}
