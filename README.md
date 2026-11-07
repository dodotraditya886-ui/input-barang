# Lapak

Aplikasi Flutter untuk mencatat barang, order pelanggan, dan menampilkan katalog.
Proyek UTS Pemrograman Mobile.

Login demo: username `admin`, password `123`.

## Fitur

- **Input data barang** — kode (unik), nama, kategori, satuan, harga, stok, deskripsi.
  Form yang sama dipakai untuk mengubah barang.
- **Input order barang** — nama pelanggan, catatan, pilih barang dari katalog, atur
  jumlah (dibatasi stok), total dihitung langsung. Stok berkurang saat order disimpan.
- **Katalog barang** — kartu barang dengan pencarian, filter kategori, pengurutan
  (nama / harga / stok), penanda stok menipis & habis. Ketuk barang untuk detail,
  ubah, hapus, atau langsung buat order.
- **Beranda** — ringkasan (jumlah barang, order, stok menipis, nilai persediaan,
  total order) dan 5 order terakhir. Order bisa dibuka dan dibatalkan (stok kembali).
- Data **tersimpan permanen** di perangkat (`shared_preferences`).

## Arsitektur

```
lib/
├── main.dart                   MultiProvider + MaterialApp
├── models/
│   ├── barang_model.dart       Barang (immutable)
│   └── order_model.dart        Order + OrderItem (snapshot kode/nama/harga)
├── providers/
│   ├── toko_provider.dart      Sumber data barang & order + aturan bisnis
│   └── auth_provider.dart      Status login
├── services/toko_storage.dart  Kontrak penyimpanan + implementasi shared_preferences
├── screens/                    Splash, Login, Home, Katalog, BarangForm, OrderForm, Profile
├── widgets/                    Komponen reusable
└── utils/                      Tema, format Rupiah/tanggal, generator ID
```

Aturan data ditegakkan di `TokoProvider`, bukan hanya di form:

- Kode barang unik.
- Order ditolak seluruhnya bila ada satu baris yang stoknya kurang.
- Item order menyimpan salinan kode/nama/harga, sehingga riwayat tidak berubah saat
  barang diedit atau dihapus.

## Menjalankan

```bash
flutter pub get
flutter run
flutter test
```
