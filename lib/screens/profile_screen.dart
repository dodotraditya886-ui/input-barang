import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common_widgets.dart';
import 'login_screen.dart';

/// Profil akun dan daftar anggota kelompok.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const List<({String nama, String npm, String peran})> _anggota = [
    (nama: 'Rahmawati Nur Fatimah', npm: '5240411232'),
    (nama: 'ica bibit bangunan', npm: '5240411235'),
    (nama: 'Ahmad Atsnal Lathief', npm: '5240411242'),
    (nama: 'Muhammad Nabil S. Adji', npm: '524041150'),
    (nama: 'Raditya Arva Narajuna Fatiha', npm: '5240411060'),
  ];

  Future<void> _keluar(BuildContext context) async {
    final ya = await konfirmasi(
      context,
      judul: 'Keluar dari aplikasi?',
      pesan: 'Anda perlu login lagi untuk melanjutkan.',
      labelAksi: 'Keluar',
    );
    if (!ya || !context.mounted) return;
    context.read<AuthProvider>().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            const Text(
              'Admin',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            const Text(
              'Pengelola Lapak',
              style: TextStyle(fontSize: 14, color: AppTheme.tintaRedup),
            ),
            const SizedBox(height: 28),
            const LabelSeksi('Anggota kelompok'),
            const SizedBox(height: 10),
            Bingkai(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < _anggota.length; i++) ...[
                    if (i > 0) const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _anggota[i].nama,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${_anggota[i].npm} · ${_anggota[i].peran}',
                            style: AppTheme.mono(size: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 28),
            const LabelSeksi('Tentang aplikasi'),
            const SizedBox(height: 10),
            const Text(
              'Lapak mencatat data barang, menyimpan order pelanggan, dan '
              'menampilkan katalog. Stok berkurang otomatis saat order '
              'disimpan dan kembali bila order dibatalkan. Data tersimpan di '
              'perangkat.\n\nDibuat dengan Flutter dan Provider.',
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: AppTheme.tintaRedup,
              ),
            ),
            const SizedBox(height: 28),
            OutlinedButton(
              onPressed: () => _keluar(context),
              child: const Text('Keluar'),
            ),
          ],
        ),
      ),
    );
  }
}
