// lib/services/app_migration_service.dart
// TASK-M00 — One-time Firestore cache clearing on app migration

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppMigrationService {
  /// Key yang dicek di SharedPreferences.
  /// Ganti suffix angka (v2, v3, ...) setiap kali perlu paksa clear ulang.
  static const String _cacheCleared = 'firestore_cache_cleared_v2';

  /// Jalankan sebelum runApp(). Aman dipanggil setiap kali app start —
  /// proses clear hanya terjadi SATU KALI selama lifetime instalasi
  /// (dikontrol oleh SharedPreferences flag).
  static Future<void> runIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Sudah pernah dijalankan — skip
      if (prefs.getBool(_cacheCleared) == true) {
        debugPrint('[AppMigration] Cache already cleared, skipping.');
        return;
      }

      debugPrint('[AppMigration] First run detected — clearing Firestore local cache...');

      final db = FirebaseFirestore.instance;

      // Step 1: Terminate semua koneksi Firestore aktif
      await db.terminate();

      // Step 2: Hapus semua data cache offline di storage lokal device
      await db.clearPersistence();

      // Step 3: Tandai sudah selesai agar tidak dijalankan lagi
      await prefs.setBool(_cacheCleared, true);

      debugPrint('[AppMigration] ✅ Firestore local cache cleared successfully.');
    } catch (e) {
      // Gagal bukan fatal — app tetap lanjut berjalan normal.
      // Firestore akan reconnect dan fetch data segar dari server.
      debugPrint('[AppMigration] ⚠️ Cache clear failed (non-fatal): $e');
    }
  }
}
