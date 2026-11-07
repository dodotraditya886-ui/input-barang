import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/toko_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

/// main() → MyApp → MultiProvider(AuthProvider, TokoProvider)
///        → Splash → Login → Home
///        → (Katalog • Input barang • Input order)
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppTheme.kertas,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TokoProvider()..muat()),
      ],
      child: MaterialApp(
        title: 'Lapak',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.tema,
        home: const SplashScreen(),
      ),
    );
  }
}
