import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/barang_model.dart';
import '../providers/toko_provider.dart';
import '../utils/app_theme.dart';
import '../utils/format.dart';
import '../utils/id_generator.dart';
import '../utils/validators.dart';
import '../widgets/common_widgets.dart';

/// Form input data barang. Bila [barang] diberikan, form berfungsi sebagai edit.
class BarangFormScreen extends StatefulWidget {
  final BarangModel? barang;

  const BarangFormScreen({super.key, this.barang});

  @override
  State<BarangFormScreen> createState() => _BarangFormScreenState();
}

class _BarangFormScreenState extends State<BarangFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _kode;
  late final TextEditingController _nama;
  late final TextEditingController _harga;
  late final TextEditingController _stok;
  late final TextEditingController _deskripsi;
  late final TextEditingController _email;
  late String _kategori;
  late String _satuan;

  bool get _edit => widget.barang != null;

  @override
  void initState() {
    super.initState();
    final b = widget.barang;
    _kode = TextEditingController(
        text: b?.kode ?? context.read<TokoProvider>().sarankanKode());
    _nama = TextEditingController(text: b?.nama ?? '');
    _harga = TextEditingController(text: b == null ? '' : b.harga.toString());
    _stok = TextEditingController(text: b == null ? '' : b.stok.toString());
    _deskripsi = TextEditingController(text: b?.deskripsi ?? '');
    _email = TextEditingController(text: b?.emailPemasok ?? '');
    _kategori = b?.kategori ?? BarangModel.daftarKategori.first;
    _satuan = b?.satuan ?? BarangModel.daftarSatuan.first;
  }

  @override
  void dispose() {
    _kode.dispose();
    _nama.dispose();
    _harga.dispose();
    _stok.dispose();
    _deskripsi.dispose();
    _email.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final provider = context.read<TokoProvider>();

    final data = BarangModel(
      id: widget.barang?.id ?? generateId(),
      kode: _kode.text.trim().toUpperCase(),
      nama: _nama.text.trim(),
      kategori: _kategori,
      satuan: _satuan,
      harga: int.parse(_harga.text),
      stok: int.parse(_stok.text),
      deskripsi: _deskripsi.text.trim(),
      emailPemasok: _email.text,
    );

    final ok = _edit ? provider.perbaruiBarang(data) : provider.tambahBarang(data);
    if (!ok) {
      Umpan.galat(context, 'Kode ${data.kode} sudah dipakai barang lain');
      return;
    }
    Umpan.info(context, _edit ? '${data.nama} diperbarui' : '${data.nama} ditambahkan');
    Navigator.of(context).pop(true);
  }

  String? _wajib(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? '$label wajib diisi' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_edit ? 'Ubah barang' : 'Barang baru')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              const LabelSeksi('Identitas'),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _kode,
                      textCapitalization: TextCapitalization.characters,
                      style: AppTheme.mono(
                          size: 14, color: AppTheme.tinta),
                      decoration: const InputDecoration(labelText: 'Kode'),
                      validator: (v) => _wajib(v, 'Kode'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      initialValue: _kategori,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      items: BarangModel.daftarKategori
                          .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                          .toList(),
                      onChanged: (v) => setState(() => _kategori = v ?? _kategori),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _nama,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Nama barang'),
                validator: (v) => _wajib(v, 'Nama barang'),
              ),
              const SizedBox(height: 28),
              const LabelSeksi('Harga dan stok'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _harga,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'Harga satuan',
                  prefixText: 'Rp ',
                ),
                validator: (v) => Validator.angka(v, 'Harga', boleNol: false),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _stok,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(labelText: 'Stok'),
                      validator: (v) => Validator.angka(v, 'Stok'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: _satuan,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Satuan'),
                      items: BarangModel.daftarSatuan
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setState(() => _satuan = v ?? _satuan),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Email pemasok (opsional)',
                  hintText: 'nama@gmail.com',
                ),
                validator: (v) => Validator.email(v, wajib: false),
              ),
              const SizedBox(height: 28),
              const LabelSeksi('Keterangan'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _deskripsi,
                minLines: 3,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi (opsional)',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: _simpan,
                child: Text(_edit ? 'Simpan perubahan' : 'Simpan barang'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
