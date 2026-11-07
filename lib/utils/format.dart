import 'package:flutter/material.dart';

import 'app_theme.dart';

/// 1250000 → "Rp 1.250.000"
String formatRupiah(int nilai) {
  final negatif = nilai < 0;
  final digit = nilai.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digit.length; i++) {
    if (i > 0 && (digit.length - i) % 3 == 0) buf.write('.');
    buf.write(digit[i]);
  }
  return '${negatif ? '-' : ''}Rp $buf';
}

const _bulan = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

String _dua(int n) => n.toString().padLeft(2, '0');

/// "07 Nov 2026"
String formatTanggal(DateTime t) => '${_dua(t.day)} ${_bulan[t.month - 1]} ${t.year}';

/// "07 Nov 2026, 10.08"
String formatTanggalJam(DateTime t) =>
    '${formatTanggal(t)}, ${_dua(t.hour)}.${_dua(t.minute)}';

/// Notifikasi snackbar seragam.
class Umpan {
  Umpan._();

  static void info(BuildContext context, String pesan) => _tampil(context, pesan);

  static void galat(BuildContext context, String pesan) =>
      _tampil(context, pesan, warna: AppTheme.merah);

  static void _tampil(BuildContext context, String pesan, {Color? warna}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(pesan),
          backgroundColor: warna,
          margin: const EdgeInsets.all(16),
        ),
      );
  }
}

/// Dialog konfirmasi; `true` hanya bila tombol aksi ditekan.
Future<bool> konfirmasi(
  BuildContext context, {
  required String judul,
  required String pesan,
  String labelAksi = 'Hapus',
}) async {
  final hasil = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(judul,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
      content: Text(pesan,
          style: const TextStyle(fontSize: 14, color: AppTheme.tintaRedup)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          style: TextButton.styleFrom(foregroundColor: AppTheme.tintaRedup),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: TextButton.styleFrom(foregroundColor: AppTheme.merah),
          child: Text(labelAksi),
        ),
      ],
    ),
  );
  return hasil ?? false;
}
