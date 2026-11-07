/// Validasi input form. Dipisah dari widget agar mudah diuji.
class Validator {
  Validator._();

  /// Angka bulat murni: tidak boleh huruf, spasi, titik, koma, atau simbol.
  static String? angka(String? v, String label, {bool boleNol = true}) {
    if (v == null || v.isEmpty) return '$label wajib diisi';
    if (!RegExp(r'^[0-9]+$').hasMatch(v)) {
      return '$label hanya boleh berisi angka (tanpa huruf, spasi, atau simbol)';
    }
    if (v.length > 12) return '$label terlalu besar';
    if (!boleNol && int.parse(v) <= 0) return '$label harus lebih dari 0';
    return null;
  }

  /// Domain umum selain gmail yang mirip gmail.com tetapi benar adanya.
  static const _domainAman = {
    'yahoo.com',
    'ymail.com',
    'mail.com',
    'outlook.com',
    'hotmail.com',
    'icloud.com',
    'proton.me',
  };

  /// Email: huruf kecil semua, format benar, dan domain tidak salah ketik
  /// dari gmail.com (mis. gmial.com, gmai.com, gmail.con).
  static String? email(String? v, {bool wajib = true}) {
    if (v == null || v.isEmpty) return wajib ? 'Email wajib diisi' : null;
    if (v != v.toLowerCase()) {
      return 'Email tidak boleh memakai huruf kapital';
    }
    if (!RegExp(r'^[a-z0-9._%+\-]+@[a-z0-9\-]+(\.[a-z0-9\-]+)+$').hasMatch(v)) {
      return 'Format email tidak valid, contoh: nama@gmail.com';
    }
    final domain = v.split('@').last;
    if (domain != 'gmail.com' &&
        !_domainAman.contains(domain) &&
        _jarak(domain, 'gmail.com') <= 2) {
      return 'Domain "@$domain" salah ketik, maksudnya @gmail.com?';
    }
    return null;
  }

  /// Jarak Levenshtein: jumlah minimal perubahan huruf antara dua teks.
  static int _jarak(String a, String b) {
    var sebelum = List<int>.generate(b.length + 1, (i) => i);
    for (var i = 1; i <= a.length; i++) {
      final kini = List<int>.filled(b.length + 1, 0)..[0] = i;
      for (var j = 1; j <= b.length; j++) {
        final biaya = a[i - 1] == b[j - 1] ? 0 : 1;
        kini[j] = [
          sebelum[j] + 1,
          kini[j - 1] + 1,
          sebelum[j - 1] + biaya,
        ].reduce((x, y) => x < y ? x : y);
      }
      sebelum = kini;
    }
    return sebelum[b.length];
  }
}
