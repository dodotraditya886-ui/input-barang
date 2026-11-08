import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/toko_provider.dart';
import '../utils/app_theme.dart';
import '../utils/format.dart';
import '../utils/validators.dart';
import '../widgets/common_widgets.dart';

/// Catat barang masuk: stok bertambah sebanyak yang diisi dan tercatat di
/// riwayat. Harga jual dan email pemasok bisa diperbarui sekalian.
class StokHargaScreen extends StatefulWidget {
  const StokHargaScreen({super.key});

  @override
  State<StokHargaScreen> createState() => _StokHargaScreenState();
}

class _StokHargaScreenState extends State<StokHargaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _harga = TextEditingController();
  final _stok = TextEditingController();
  final _email = TextEditingController();
  String? _barangId;

  @override
  void dispose() {
    _harga.dispose();
    _stok.dispose();
    _email.dispose();
    super.dispose();
  }

  void _pilihBarang(String? id, TokoProvider provider) {
    setState(() => _barangId = id);
    final b = id == null ? null : provider.cariBarang(id);
    if (b == null) return;
    _harga.text = b.harga.toString();
    _email.text = b.emailPemasok;
  }

  void _simpan() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final provider = context.read<TokoProvider>();
    final id = _barangId!;
    final harga = int.parse(_harga.text);
    final angkaStok = int.parse(_stok.text);
    final email = _email.text.trim().toLowerCase();

    String? galat = provider.catatBarangMasuk(
      barangId: id,
      qty: angkaStok,
      emailPemasok: email,
    );
    final b = provider.cariBarang(id);
    if (galat == null && b != null && b.harga != harga) {
      galat = provider.ubahHargaStok(
        barangId: id,
        harga: harga,
        stok: b.stok,
        emailPemasok: email,
      );
    }

    if (galat != null) {
      Umpan.galat(context, galat);
      return;
    }
    Umpan.info(context, 'Barang masuk tercatat');
    setState(() {
      _barangId = null;
      _harga.clear();
      _stok.clear();
      _email.clear();
    });
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TokoProvider>();
    final terpilih = _barangId == null ? null : provider.cariBarang(_barangId!);
    final qty = int.tryParse(_stok.text);
    final riwayat = provider.riwayatMasuk.take(5).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Stok & harga')),
      body: SafeArea(
        child: provider.barang.isEmpty
            ? const KeadaanKosong(
                judul: 'Belum ada barang',
                pesan: 'Tambahkan barang di katalog dulu.',
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
                      decoration:
                          const InputDecoration(labelText: 'Pilih barang'),
                      items: provider.barang
                          .map((b) => DropdownMenuItem(
                                value: b.id,
                                child: Text('${b.kode} · ${b.nama}',
                                    overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: (id) => _pilihBarang(id, provider),
                      validator: (v) => v == null ? 'Pilih barang dulu' : null,
                    ),
                    if (terpilih != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Saat ini ${formatRupiah(terpilih.harga)} · stok ${terpilih.stok} ${terpilih.satuan}',
                        style: const TextStyle(
                            fontSize: 12.5, color: AppTheme.tintaRedup),
                      ),
                    ],
                    const SizedBox(height: 28),
                    const LabelSeksi('Stok masuk'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _stok,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Jumlah stok masuk',
                        helperText: 'Ditambahkan ke stok saat ini',
                        suffixText: terpilih?.satuan,
                      ),
                      validator: (v) =>
                          Validator.angka(v, 'Stok masuk', boleNol: false),
                    ),
                    if (terpilih != null && qty != null && qty > 0) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Stok jadi ${terpilih.stok + qty} ${terpilih.satuan}',
                        style: const TextStyle(
                            fontSize: 12.5, color: AppTheme.tintaRedup),
                      ),
                    ],
                    const SizedBox(height: 28),
                    const LabelSeksi('Harga dan pemasok'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _harga,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Harga jual',
                        prefixText: 'Rp ',
                      ),
                      validator: (v) =>
                          Validator.angka(v, 'Harga', boleNol: false),
                    ),
                    const SizedBox(height: 14),
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
                      onPressed: _simpan,
                      child: const Text('Simpan barang masuk'),
                    ),
                    const SizedBox(height: 32),
                    const LabelSeksi('Riwayat barang masuk'),
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
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var i = 0; i < riwayat.length; i++) ...[
                              if (i > 0) const Divider(),
                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
