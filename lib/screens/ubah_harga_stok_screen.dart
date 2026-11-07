import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/toko_provider.dart';
import '../utils/app_theme.dart';
import '../utils/format.dart';
import '../utils/validators.dart';
import '../widgets/common_widgets.dart';

/// Koreksi harga jual dan stok satu barang (mis. setelah stok opname),
/// sekaligus memperbarui email pemasoknya.
class UbahHargaStokScreen extends StatefulWidget {
  const UbahHargaStokScreen({super.key});

  @override
  State<UbahHargaStokScreen> createState() => _UbahHargaStokScreenState();
}

class _UbahHargaStokScreenState extends State<UbahHargaStokScreen> {
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

  void _pilih(String? id, TokoProvider provider) {
    setState(() => _barangId = id);
    final b = id == null ? null : provider.cariBarang(id);
    if (b == null) return;
    _harga.text = b.harga.toString();
    _stok.text = b.stok.toString();
    _email.text = b.emailPemasok;
  }

  void _simpan() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final galat = context.read<TokoProvider>().ubahHargaStok(
          barangId: _barangId!,
          harga: int.parse(_harga.text),
          stok: int.parse(_stok.text),
          emailPemasok: _email.text.trim().toLowerCase(),
        );
    if (galat != null) {
      Umpan.galat(context, galat);
      return;
    }
    Umpan.info(context, 'Harga dan stok diperbarui');
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TokoProvider>();
    final terpilih = _barangId == null ? null : provider.cariBarang(_barangId!);

    return Scaffold(
      appBar: AppBar(title: const Text('Ubah harga & stok')),
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
                    if (terpilih != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Saat ini ${formatRupiah(terpilih.harga)} · stok ${terpilih.stok} ${terpilih.satuan}',
                        style: const TextStyle(
                            fontSize: 12.5, color: AppTheme.tintaRedup),
                      ),
                    ],
                    const SizedBox(height: 28),
                    const LabelSeksi('Nilai baru'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _harga,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Harga baru',
                        prefixText: 'Rp ',
                      ),
                      validator: (v) =>
                          Validator.angka(v, 'Harga', boleNol: false),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _stok,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Stok baru',
                        suffixText: terpilih?.satuan,
                      ),
                      validator: (v) => Validator.angka(v, 'Stok'),
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
                        onPressed: _simpan, child: const Text('Simpan perubahan')),
                  ],
                ),
              ),
      ),
    );
  }
}
