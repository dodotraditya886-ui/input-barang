import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import 'home_screen.dart';

/// Login. Kredensial demo (hardcoded): admin / 123.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const String _username = 'admin';
  static const String _password = '123';

  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _lihat = false;
  String? _galat;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _masuk() {
    setState(() => _galat = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_userCtrl.text.trim() == _username && _passCtrl.text == _password) {
      context.read<AuthProvider>().login();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      setState(() => _galat = 'Username atau password salah');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lapak',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Masuk untuk mengelola barang dan order.',
                      style: TextStyle(fontSize: 14, color: AppTheme.tintaRedup),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _userCtrl,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      decoration: const InputDecoration(labelText: 'Username'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Username wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: !_lihat,
                      onFieldSubmitted: (_) => _masuk(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          tooltip: _lihat ? 'Sembunyikan' : 'Tampilkan',
                          onPressed: () => setState(() => _lihat = !_lihat),
                          icon: Icon(
                            _lihat
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                          ),
                        ),
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Password wajib diisi'
                          : null,
                    ),
                    if (_galat != null) ...[
                      const SizedBox(height: 12),
                      Text(_galat!,
                          style: const TextStyle(
                              fontSize: 13, color: AppTheme.merah)),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _masuk,
                        child: const Text('Masuk'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Demo: admin / 123',
                      style: AppTheme.mono(size: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
