import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/toko_provider.dart';
import '../utils/app_theme.dart';
import '../utils/format.dart';
import '../widgets/barang_picker_sheet.dart';
import '../widgets/common_widgets.dart';

/// Form input order barang.
///
/// Keranjang menyimpan id barang → jumlah (urutan penambahan terjaga).
/// [barangAwalId] dipakai saat membuka form dari katalog.
class OrderFormScreen extends StatefulWidget {
  final String? barangAwalId;

  const OrderFormScreen({super.key, this.barangAwalId});

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pelanggan = TextEditingController();
  final _catatan = TextEditingController();
  final Map<String, int> _keranjang = {};
  String? _galatKeranjang;

  @override
  void initState() {
    super.initState();
    final id = widget.barangAwalId;
    if (id != null) {
      final b = context.read<TokoProvider>().cariBarang(id);
      if (b != null && !b.habis) _keranjang[b.id] = 1;
    }
  }

  @override
  void dispose() {
    _pelanggan.dispose();
    _catatan.dispose();
    super.dispose();
  }

  Future<void> _tambahBarang() async {
    final provider = context.read<TokoProvider>();
    final tersedia = provider.barang
        .where((b) => !b.habis && !_keranjang.containsKey(b.id))
        .toList();
    final dipilih = await pilihBarang(context, tersedia: tersedia);
    if (dipilih == null || !mounted) return;
    setState(() {
      _keranjang[dipilih.id] = 1;
      _galatKeranjang = null;
    });
  }

  int _total(TokoProvider provider) {
    var total = 0;
    _keranjang.forEach((id, qty) {
      final b = provider.cariBarang(id);
      if (b != null) total += b.harga * qty;
    });
    return total;
  }

  void _kirim() {
    final formOk = _formKey.currentState?.validate() ?? false;
    if (_keranjang.isEmpty) {
      setState(() => _galatKeranjang = 'Tambahkan minimal satu barang');
      return;
    }
    if (!formOk) return;

    final hasil = context.read<TokoProvider>().buatOrder(
          pelanggan: _pelanggan.text,
          catatan: _catatan.text,
          qtyPerBarang: Map.of(_keranjang),
        );
    if (hasil.error != null) {
      Umpan.galat(context, hasil.error!);
      return;
    }
    Umpan.info(context, 'Order ${hasil.order!.nomor} tersimpan');
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TokoProvider>();
    final total = _total(provider);

    return Scaffold(
      appBar: AppBar(title: const Text('Order baru')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              const LabelSeksi('Pemesan'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pelanggan,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Nama pelanggan'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Nama pelanggan wajib diisi'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _catatan,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Catatan (opsional)',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 28),
              LabelSeksi(
                'Barang dipesan',
                trailing: TextButton.icon(
                  onPressed: provider.barang.isEmpty ? null : _tambahBarang,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Tambah'),
                ),
              ),
              const SizedBox(height: 8),
              if (provider.barang.isEmpty)
                const Bingkai(
                  child: Text(
                    'Katalog masih kosong. Tambahkan barang terlebih dahulu.',
                    style: TextStyle(color: AppTheme.tintaRedup, fontSize: 14),
                  ),
                )
              else if (_keranjang.isEmpty)
                Bingkai(
                  child: Text(
                    'Belum ada barang. Tekan Tambah untuk memilih dari katalog.',
                    style: TextStyle(
                      color: _galatKeranjang == null
                          ? AppTheme.tintaRedup
                          : AppTheme.merah,
                      fontSize: 14,
                    ),
                  ),
                )
              else
                Bingkai(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (final e in _keranjang.entries.toList().asMap().entries)
                        _barisKeranjang(
                          provider,
                          e.value.key,
                          e.value.value,
                          terakhir: e.key == _keranjang.length - 1,
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppTheme.tinta, width: 1.5),
                  ),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text('Total',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                    Text(
                      formatRupiah(total),
                      style: AppTheme.mono(
                          size: 18,
                          weight: FontWeight.w700,
                          color: AppTheme.tinta),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(onPressed: _kirim, child: const Text('Simpan order')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _barisKeranjang(
    TokoProvider provider,
    String id,
    int qty, {
    required bool terakhir,
  }) {
    final b = provider.cariBarang(id);
    if (b == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: terakhir
            ? null
            : const Border(bottom: BorderSide(color: AppTheme.garis)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.kode, style: AppTheme.mono(size: 11)),
                    const SizedBox(height: 2),
                    Text(b.nama,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Hapus dari order',
                visualDensity: VisualDensity.compact,
                onPressed: () => setState(() => _keranjang.remove(id)),
                icon: const Icon(Icons.close, size: 18),
                color: AppTheme.tintaRedup,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              StepperJumlah(
                nilai: qty,
                maks: b.stok,
                onChanged: (n) => setState(() => _keranjang[id] = n),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${formatRupiah(b.harga)} × $qty ${b.satuan}',
                  style: AppTheme.mono(size: 11.5),
                ),
              ),
              Text(
                formatRupiah(b.harga * qty),
                style: AppTheme.mono(
                    size: 13, weight: FontWeight.w600, color: AppTheme.tinta),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Stok tersedia ${b.stok} ${b.satuan}',
              style: const TextStyle(fontSize: 12, color: AppTheme.tintaRedup)),
        ],
      ),
    );
  }
}
