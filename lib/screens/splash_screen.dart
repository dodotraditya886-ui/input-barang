import 'dart:async';

import 'package:flutter/material.dart';

import '../utils/app_theme.dart';
import 'login_screen.dart';

/// Layar pembuka singkat, lalu pindah ke login.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Lapak',
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w700,
                letterSpacing: -1.4,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'barang · order · katalog',
              style: TextStyle(fontSize: 13, color: AppTheme.tintaRedup),
            ),
          ],
        ),
      ),
    );
  }
}
