import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/barang_model.dart';
import '../providers/toko_provider.dart';
import '../utils/app_theme.dart';
import '../utils/format.dart';
import '../utils/validators.dart';
import '../widgets/common_widgets.dart';

/// Catat barang masuk dari pemasok: stok bertambah, harga beli dan email
/// pemasok tersimpan di riwayat.
class BarangMasukScreen extends StatefulWidget {
  const BarangMasukScreen({super.key});

  @override
  State<BarangMasukScreen> createState() => _BarangMasukScreenState();
}

class _BarangMasukScreenState extends State<BarangMasukScreen> {
  final _formKey = GlobalKey<FormState>();
  final _qty = TextEditingController();
  final _hargaBeli = TextEditingController();
  final _email = TextEditingController();
  String? _barangId;

  @override
  void dispose() {
    _qty.dispose();
    _hargaBeli.dispose();
    _email.dispose();
    super.dispose();
  }

  void _pilih(String? id, TokoProvider provider) {
    setState(() => _barangId = id);
    final b = id == null ? null : provider.cariBarang(id);
    if (b != null) _email.text = b.emailPemasok;
  }

  void _simpan() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final provider = context.read<TokoProvider>();
    final galat = provider.catatBarangMasuk(
      barangId: _barangId!,
      qty: int.parse(_qty.text),
      hargaBeli: int.parse(_hargaBeli.text),
      emailPemasok: _email.text.trim().toLowerCase(),
    );
    if (galat != null) {
      Umpan.galat(context, galat);
      return;
    }
    Umpan.info(context, 'Barang masuk tercatat');
    setState(() {
      _barangId = null;
      _qty.clear();
      _hargaBeli.clear();
      _email.clear();
    });
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TokoProvider>();
    final BarangModel? terpilih =
        _barangId == null ? null : provider.cariBarang(_barangId!);
    final qty = int.tryParse(_qty.text);
    final riwayat = provider.riwayatMasuk.take(5).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Barang masuk')),
      body: SafeArea(
        child: provider.barang.isEmpty
            ? const KeadaanKosong(
                judul: 'Belum ada barang',
                pesan: 'Tambahkan barang di katalog dulu sebelum mencatat barang masuk.',
              )
            : Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  children: [
                    const LabelSeksi('Barang'),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      key: ValueKey(_barangId),
                      initialValue: _barangId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Pilih barang'),
                      items: provider.barang
                          .map((b) => DropdownMenuItem(
                                value: b.id,
                                child: Text('${b.kode} · ${b.nama}',
                                    overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: (id) => _pilih(id, provider),
                      validator: (v) => v == null ? 'Pilih barang dulu' : null,
                    ),
                    const SizedBox(height: 28),
                    const LabelSeksi('Jumlah dan harga'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _qty,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Stok masuk',
                        suffixText: terpilih?.satuan,
                      ),
                      validator: (v) =>
                          Validator.angka(v, 'Stok masuk', boleNol: false),
                    ),
                    if (terpilih != null && qty != null && qty > 0) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Stok jadi ${terpilih.stok + qty} ${terpilih.satuan} (sekarang ${terpilih.stok})',
                        style: const TextStyle(
                            fontSize: 12.5, color: AppTheme.tintaRedup),
                      ),
                    ],
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _hargaBeli,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Harga beli per satuan',
                        prefixText: 'Rp ',
                      ),
                      validator: (v) =>
                          Validator.angka(v, 'Harga beli', boleNol: false),
                    ),
                    const SizedBox(height: 28),
                    const LabelSeksi('Pemasok'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      inputFormatters: [HurufKecilFormatter()],
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: 'Email pemasok',
                        hintText: 'nama@gmail.com',
                      ),
                      validator: Validator.email,
                    ),
                    const SizedBox(height: 28),
                    FilledButton(
                        onPressed: _simpan, child: const Text('Simpan barang masuk')),
                    const SizedBox(height: 32),
                    const LabelSeksi('Riwayat terakhir'),
                    const SizedBox(height: 10),
                    if (riwayat.isEmpty)
                      const Bingkai(
                        child: Text('Belum ada barang masuk.',
                            style: TextStyle(
                                fontSize: 14, color: AppTheme.tintaRedup)),
                      )
                    else
                      Bingkai(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            for (var i = 0; i < riwayat.length; i++) ...[
                              if (i > 0) const Divider(),
                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(riwayat[i].nama,
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500)),
                                          const SizedBox(height: 2),
                                          Text(
                                            '+${riwayat[i].qty} ${riwayat[i].satuan} · ${riwayat[i].emailPemasok}',
                                            style: AppTheme.mono(size: 11.5),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(formatTanggalJam(riwayat[i].waktu),
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppTheme.tintaRedup)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(formatRupiah(riwayat[i].totalBeli),
                                        style: AppTheme.mono(
                                            size: 13,
                                            weight: FontWeight.w600,
                                            color: AppTheme.tinta)),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
