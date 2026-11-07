int _counter = 0;

/// Membuat ID unik untuk entitas baru (barang / order).
///
/// Gabungan timestamp mikrodetik + counter berurutan, sehingga dua ID yang
/// dibuat pada milidetik yang sama (mis. saat impor massal) tidak bentrok.
String generateId() {
  _counter = (_counter + 1) % 1000000;
  return '${DateTime.now().microsecondsSinceEpoch}$_counter';
}
