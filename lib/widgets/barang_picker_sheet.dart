import 'package:flutter/material.dart';

import '../models/barang_model.dart';
import '../utils/app_theme.dart';
import '../utils/format.dart';
import 'common_widgets.dart';

/// Bottom sheet untuk memilih satu barang (dipakai di form order).
/// Barang yang sudah ada di keranjang atau stoknya habis tidak ditampilkan.
Future<BarangModel?> pilihBarang(
  BuildContext context, {
  required List<BarangModel> tersedia,
}) {
  return showModalBottomSheet<BarangModel>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _BarangPickerSheet(tersedia: tersedia),
  );
}

class _BarangPickerSheet extends StatefulWidget {
  final List<BarangModel> tersedia;
  const _BarangPickerSheet({required this.tersedia});

  @override
  State<_BarangPickerSheet> createState() => _BarangPickerSheetState();
}

class _BarangPickerSheetState extends State<_BarangPickerSheet> {
  String _cari = '';

  @override
  Widget build(BuildContext context) {
    final q = _cari.trim().toLowerCase();
    final hasil = widget.tersedia
        .where((b) =>
            q.isEmpty ||
            b.nama.toLowerCase().contains(q) ||
            b.kode.toLowerCase().contains(q))
        .toList();
    final tinggi = MediaQuery.of(context).size.height * 0.75;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: tinggi,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pilih barang',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  TextField(
                    autofocus: false,
                    onChanged: (v) => setState(() => _cari = v),
                    decoration: const InputDecoration(
                      hintText: 'Cari nama atau kode',
                      prefixIcon: Icon(Icons.search, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: hasil.isEmpty
                  ? const KeadaanKosong(
                      judul: 'Tidak ada barang',
                      pesan:
                          'Barang yang stoknya habis atau sudah masuk daftar order tidak ditampilkan.',
                    )
                  : ListView.separated(
                      itemCount: hasil.length,
                      separatorBuilder: (_, _) => const Divider(),
                      itemBuilder: (_, i) {
                        final b = hasil[i];
                        return InkWell(
                          onTap: () => Navigator.pop(context, b),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(b.kode, style: AppTheme.mono(size: 11)),
                                      const SizedBox(height: 2),
                                      Text(b.nama,
                                          style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 4),
                                      StokLabel(barang: b),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(formatRupiah(b.harga),
                                    style: AppTheme.mono(
                                        size: 13,
                                        weight: FontWeight.w600,
                                        color: AppTheme.tinta)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
