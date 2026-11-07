import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/barang_model.dart';
import '../models/order_model.dart';
import '../models/stok_masuk_model.dart';

/// Seluruh data yang disimpan: katalog barang + riwayat order.
class TokoData {
  final List<BarangModel> barang;
  final List<OrderModel> order;
  final List<StokMasukModel> masuk;

  const TokoData({
    this.barang = const [],
    this.order = const [],
    this.masuk = const [],
  });

  Map<String, dynamic> toJson() => {
        'barang': barang.map((b) => b.toJson()).toList(),
        'order': order.map((o) => o.toJson()).toList(),
        'masuk': masuk.map((m) => m.toJson()).toList(),
      };

  factory TokoData.fromJson(Map<String, dynamic> json) {
    return TokoData(
      barang: (json['barang'] as List<dynamic>? ?? [])
          .map((e) => BarangModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      order: (json['order'] as List<dynamic>? ?? [])
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      masuk: (json['masuk'] as List<dynamic>? ?? [])
          .map((e) => StokMasukModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Kontrak penyimpanan; dipisah agar provider mudah diuji dengan storage palsu.
abstract class TokoStorage {
  Future<TokoData> muat();
  Future<void> simpan(TokoData data);
}

/// Implementasi default: JSON di `shared_preferences`.
class SharedPrefsTokoStorage implements TokoStorage {
  static const String _key = 'lapak.data.v1';

  @override
  Future<TokoData> muat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return const TokoData();
      return TokoData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      // Data rusak: mulai dari kosong daripada crash.
      debugPrint('Gagal memuat data: $e');
      return const TokoData();
    }
  }

  @override
  Future<void> simpan(TokoData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(data.toJson()));
    } catch (e) {
      debugPrint('Gagal menyimpan data: $e');
    }
  }
}
