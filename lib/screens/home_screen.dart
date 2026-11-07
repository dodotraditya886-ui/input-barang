import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order_model.dart';
import '../providers/toko_provider.dart';
import '../utils/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common_widgets.dart';
import 'barang_form_screen.dart';
import 'barang_masuk_screen.dart';
import 'katalog_screen.dart';
import 'order_form_screen.dart';
import 'profile_screen.dart';
import 'ubah_harga_stok_screen.dart';

/// Beranda: ringkasan angka, tiga menu utama, dan order terakhir.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _buka(BuildContext context, Widget layar) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => layar));

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TokoProvider>();
    final terakhir = provider.order.take(5).toList();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Lapak',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.8,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Profil',
                  onPressed: () => _buka(context, const ProfileScreen()),
                  icon: const Icon(Icons.person_outline),
                ),
              ],
            ),
            const Text(
              'Pencatatan barang dan order',
              style: TextStyle(fontSize: 14, color: AppTheme.tintaRedup),
            ),
            const SizedBox(height: 24),
            _Ringkasan(provider: provider),
            const SizedBox(height: 28),
            const LabelSeksi('Menu'),
            const SizedBox(height: 10),
            Bingkai(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _BarisMenu(
                    nomor: '01',
                    judul: 'Katalog barang',
                    keterangan: '${provider.jumlahBarang} barang terdaftar',
                    onTap: () => _buka(context, const KatalogScreen()),
                  ),
                  const Divider(),
                  _BarisMenu(
                    nomor: '02',
                    judul: 'Input data barang',
                    keterangan: 'Tambah barang ke katalog',
                    onTap: () => _buka(context, const BarangFormScreen()),
                  ),
                  const Divider(),
                  _BarisMenu(
                    nomor: '03',
                    judul: 'Input order barang',
                    keterangan: 'Catat pesanan pelanggan',
                    onTap: () => _buka(context, const OrderFormScreen()),
                  ),
                  const Divider(),
                  _BarisMenu(
                    nomor: '04',
                    judul: 'Barang masuk',
                    keterangan: 'Tambah stok dari pemasok',
                    onTap: () => _buka(context, const BarangMasukScreen()),
                  ),
                  const Divider(),
                  _BarisMenu(
                    nomor: '05',
                    judul: 'Ubah harga & stok',
                    keterangan: 'Koreksi harga jual dan stok',
                    onTap: () => _buka(context, const UbahHargaStokScreen()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const LabelSeksi('Order terakhir'),
            const SizedBox(height: 10),
            if (terakhir.isEmpty)
              const Bingkai(
                child: Text(
                  'Belum ada order. Order yang disimpan akan muncul di sini.',
                  style: TextStyle(fontSize: 14, color: AppTheme.tintaRedup),
                ),
              )
            else
              Bingkai(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (var i = 0; i < terakhir.length; i++) ...[
                      if (i > 0) const Divider(),
                      _BarisOrder(order: terakhir[i]),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Ringkasan extends StatelessWidget {
  final TokoProvider provider;
  const _Ringkasan({required this.provider});

  @override
  Widget build(BuildContext context) {
    Widget sel(String label, String nilai, {Color? warna}) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.tintaRedup)),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    nilai,
                    style: AppTheme.mono(
                      size: 18,
                      weight: FontWeight.w700,
                      color: warna ?? AppTheme.tinta,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

    const sekat = VerticalDivider(width: 1, thickness: 1, color: AppTheme.garis);

    return Column(
      children: [
        Bingkai(
          padding: EdgeInsets.zero,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                sel('Jenis barang', '${provider.jumlahBarang}'),
                sekat,
                sel('Order', '${provider.jumlahOrder}'),
                sekat,
                sel(
                  'Stok menipis',
                  '${provider.jumlahStokMenipis}',
                  warna: provider.jumlahStokMenipis > 0 ? AppTheme.kuning : null,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Bingkai(
          padding: EdgeInsets.zero,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                sel('Nilai persediaan', formatRupiah(provider.nilaiStok)),
                sekat,
                sel('Total order', formatRupiah(provider.totalPenjualan)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BarisMenu extends StatelessWidget {
  final String nomor;
  final String judul;
  final String keterangan;
  final VoidCallback onTap;

  const _BarisMenu({
    required this.nomor,
    required this.judul,
    required this.keterangan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Text(nomor,
                style: AppTheme.mono(
                    size: 13, weight: FontWeight.w600, color: AppTheme.aksen)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(judul,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(keterangan,
                      style: const TextStyle(
                          fontSize: 13, color: AppTheme.tintaRedup)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, size: 18, color: AppTheme.tintaRedup),
          ],
        ),
      ),
    );
  }
}

class _BarisOrder extends StatelessWidget {
  final OrderModel order;
  const _BarisOrder({required this.order});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => _DetailOrder(orderId: order.id),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.nomor, style: AppTheme.mono(size: 11.5)),
                  const SizedBox(height: 2),
                  Text(order.pelanggan,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(
                    '${formatTanggalJam(order.waktu)} · ${order.items.length} barang',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.tintaRedup),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(formatRupiah(order.total),
                style: AppTheme.mono(
                    size: 13, weight: FontWeight.w600, color: AppTheme.tinta)),
          ],
        ),
      ),
    );
  }
}

class _DetailOrder extends StatelessWidget {
  final String orderId;
  const _DetailOrder({required this.orderId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TokoProvider>();
    OrderModel? o;
    for (final x in provider.order) {
      if (x.id == orderId) o = x;
    }
    if (o == null) return const SizedBox(height: 1);
    final order = o;
    final navigator = Navigator.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(order.nomor,
                style: AppTheme.mono(
                    size: 12, weight: FontWeight.w600, color: AppTheme.aksen)),
            const SizedBox(height: 4),
            Text(order.pelanggan,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(formatTanggalJam(order.waktu),
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.tintaRedup)),
            const SizedBox(height: 16),
            const Divider(),
            for (final i in order.items) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(i.nama,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2),
                          Text(
                            '${i.qty} ${i.satuan} × ${formatRupiah(i.harga)}',
                            style: AppTheme.mono(size: 11.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(formatRupiah(i.subtotal),
                        style: AppTheme.mono(
                            size: 13,
                            weight: FontWeight.w600,
                            color: AppTheme.tinta)),
                  ],
                ),
              ),
              const Divider(),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Total',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                  Text(formatRupiah(order.total),
                      style: AppTheme.mono(
                          size: 17,
                          weight: FontWeight.w700,
                          color: AppTheme.tinta)),
                ],
              ),
            ),
            if (order.catatan.isNotEmpty) ...[
              const LabelSeksi('Catatan'),
              const SizedBox(height: 6),
              Text(order.catatan,
                  style: const TextStyle(fontSize: 14, height: 1.5)),
              const SizedBox(height: 16),
            ],
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.merah,
                side: const BorderSide(color: AppTheme.merah),
              ),
              onPressed: () async {
                final ya = await konfirmasi(
                  context,
                  judul: 'Batalkan order?',
                  pesan:
                      '${order.nomor} akan dihapus dan stok barang dikembalikan.',
                  labelAksi: 'Batalkan order',
                );
                if (!ya || !context.mounted) return;
                provider.hapusOrder(order.id);
                navigator.pop();
              },
              child: const Text('Batalkan order'),
            ),
          ],
        ),
      ),
    );
  }
}
