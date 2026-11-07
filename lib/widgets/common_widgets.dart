import 'package:flutter/material.dart';

import '../models/barang_model.dart';
import '../utils/app_theme.dart';

/// Label seksi kecil huruf kapital, gaya formulir cetak.
class LabelSeksi extends StatelessWidget {
  final String teks;
  final Widget? trailing;

  const LabelSeksi(this.teks, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            teks.toUpperCase(),
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
              color: AppTheme.tintaRedup,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Kotak berbingkai tipis tempat mengelompokkan isi.
class Bingkai extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const Bingkai({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppTheme.permukaan,
        border: Border.all(color: AppTheme.garis),
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: child,
    );
  }
}

/// Penanda stok: teks berwarna dengan titik, bukan pil berwarna-warni.
class StokLabel extends StatelessWidget {
  final BarangModel barang;
  final double ukuran;

  const StokLabel({super.key, required this.barang, this.ukuran = 12.5});

  @override
  Widget build(BuildContext context) {
    final Color warna;
    final String teks;
    if (barang.habis) {
      warna = AppTheme.merah;
      teks = 'Habis';
    } else if (barang.menipis) {
      warna = AppTheme.kuning;
      teks = 'Sisa ${barang.stok} ${barang.satuan}';
    } else {
      warna = AppTheme.hijau;
      teks = '${barang.stok} ${barang.satuan}';
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: warna, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            teks,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: ukuran,
              fontWeight: FontWeight.w500,
              color: warna,
            ),
          ),
        ),
      ],
    );
  }
}

/// Keadaan kosong: teks saja, tanpa ikon besar dalam lingkaran.
class KeadaanKosong extends StatelessWidget {
  final String judul;
  final String pesan;
  final Widget? aksi;

  const KeadaanKosong({
    super.key,
    required this.judul,
    required this.pesan,
    this.aksi,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                judul,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                pesan,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppTheme.tintaRedup,
                ),
              ),
              if (aksi != null) ...[
                const SizedBox(height: 18),
                aksi!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Stepper jumlah: [-] 3 [+], tanpa dekorasi berlebih.
class StepperJumlah extends StatelessWidget {
  final int nilai;
  final int maks;
  final ValueChanged<int> onChanged;

  const StepperJumlah({
    super.key,
    required this.nilai,
    required this.maks,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    Widget tombol(IconData ikon, VoidCallback? aksi, String tip) {
      return SizedBox(
        width: 38,
        height: 38,
        child: IconButton(
          tooltip: tip,
          padding: EdgeInsets.zero,
          onPressed: aksi,
          icon: Icon(ikon, size: 18),
          color: AppTheme.tinta,
          disabledColor: AppTheme.garis,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.garis),
        borderRadius: BorderRadius.circular(AppTheme.radius),
        color: AppTheme.permukaan,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          tombol(Icons.remove, nilai > 1 ? () => onChanged(nilai - 1) : null,
              'Kurangi'),
          SizedBox(
            width: 34,
            child: Text(
              '$nilai',
              textAlign: TextAlign.center,
              style: AppTheme.mono(
                  size: 14, weight: FontWeight.w600, color: AppTheme.tinta),
            ),
          ),
          tombol(Icons.add, nilai < maks ? () => onChanged(nilai + 1) : null,
              'Tambah'),
        ],
      ),
    );
  }
}
