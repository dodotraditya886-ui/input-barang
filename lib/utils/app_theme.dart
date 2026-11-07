import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tema "kertas & tinta": latar krem, garis tipis, satu warna aksen.
/// Tanpa gradient, tanpa bayangan; hierarki dibuat lewat tipografi dan garis.
class AppTheme {
  AppTheme._();

  static const Color kertas = Color(0xFFF4F1EA);
  static const Color permukaan = Color(0xFFFBFAF6);
  static const Color garis = Color(0xFFDAD5C8);
  static const Color tinta = Color(0xFF1F1D19);
  static const Color tintaRedup = Color(0xFF6E695D);
  static const Color aksen = Color(0xFFB8471A);
  static const Color aksenGelap = Color(0xFF93360F);
  static const Color hijau = Color(0xFF2F6B3A);
  static const Color kuning = Color(0xFF9A6A00);
  static const Color merah = Color(0xFFB3261E);

  static const double radius = 6;

  /// Warna penanda tiap kategori (redup, agar tidak ramai).
  static Color warnaKategori(String kategori) {
    switch (kategori) {
      case 'Makanan':
        return const Color(0xFFB8471A);
      case 'Minuman':
        return const Color(0xFF2B6A74);
      case 'Alat Tulis':
        return const Color(0xFF3B4F8A);
      case 'Elektronik':
        return const Color(0xFF5B5B5B);
      case 'Rumah Tangga':
        return const Color(0xFF6B7A2A);
      default:
        return const Color(0xFF7A5A3A);
    }
  }

  static TextStyle mono({
    double size = 12,
    FontWeight weight = FontWeight.w500,
    Color color = tintaRedup,
  }) =>
      GoogleFonts.ibmPlexMono(
          fontSize: size, fontWeight: weight, color: color);

  static ThemeData get tema {
    final skema = ColorScheme.fromSeed(
      seedColor: aksen,
      brightness: Brightness.light,
    ).copyWith(
      primary: aksen,
      onPrimary: Colors.white,
      secondary: tinta,
      surface: kertas,
      onSurface: tinta,
      outline: garis,
      error: merah,
    );

    final teks = GoogleFonts.ibmPlexSansTextTheme().apply(
      bodyColor: tinta,
      displayColor: tinta,
    );

    OutlineInputBorder garisInput(Color warna, [double lebar = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: warna, width: lebar),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: skema,
      scaffoldBackgroundColor: kertas,
      textTheme: teks,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: kertas,
        foregroundColor: tinta,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: GoogleFonts.ibmPlexSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: tinta,
        ),
        shape: const Border(bottom: BorderSide(color: garis)),
      ),
      dividerTheme: const DividerThemeData(
        space: 1,
        thickness: 1,
        color: garis,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: permukaan,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: garisInput(garis),
        enabledBorder: garisInput(garis),
        focusedBorder: garisInput(tinta, 1.5),
        errorBorder: garisInput(merah),
        focusedErrorBorder: garisInput(merah, 1.5),
        labelStyle: GoogleFonts.ibmPlexSans(color: tintaRedup, fontSize: 14),
        floatingLabelStyle:
            GoogleFonts.ibmPlexSans(color: tinta, fontWeight: FontWeight.w500),
        hintStyle: GoogleFonts.ibmPlexSans(
            color: tintaRedup.withValues(alpha: 0.6), fontSize: 14),
        errorStyle: GoogleFonts.ibmPlexSans(color: merah, fontSize: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: tinta,
          foregroundColor: kertas,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius)),
          textStyle: GoogleFonts.ibmPlexSans(
              fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: tinta,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          side: const BorderSide(color: tinta),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius)),
          textStyle: GoogleFonts.ibmPlexSans(
              fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: aksen,
          textStyle: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: aksen,
        foregroundColor: Colors.white,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        extendedTextStyle: GoogleFonts.ibmPlexSans(
            fontSize: 14, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: tinta,
        contentTextStyle:
            GoogleFonts.ibmPlexSans(color: kertas, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: permukaan,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: garis),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: permukaan,
        surfaceTintColor: Colors.transparent,
        showDragHandle: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: permukaan,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: garis),
        ),
      ),
    );
  }
}
