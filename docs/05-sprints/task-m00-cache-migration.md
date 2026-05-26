# Task: Implementasi Firestore Cache Migration (Pendekatan 1)

## Konteks

Repo: `aryapras22/gamifyphotography` (Flutter + Riverpod + Firebase)

Aplikasi saat ini menyimpan konten level secara hardcoded di
`lib/core/level_content_data.dart`. Proses migrasi ke Firestore sedang berjalan.
Masalah: Firestore offline persistence mungkin menyimpan data level lama di cache
lokal device, sehingga perlu dibersihkan sekali saat versi baru pertama kali dibuka.

**Tujuan task ini:** Implementasi `AppMigrationService` yang menghapus cache Firestore
lama secara otomatis, satu kali saja, menggunakan `clearPersistence()`. Dipanggil di
`main.dart` setelah `Firebase.initializeApp()` dan sebelum `runApp()`.

---

## File yang Harus Dibuat / Dimodifikasi

### 1. BUAT file baru: `lib/services/app_migration_service.dart`

Buat file ini dari nol dengan isi berikut **persis**:

```dart
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
```

---

### 2. MODIFIKASI file: `lib/main.dart`

File `main.dart` saat ini berisi:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}
```

Ubah menjadi:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/app.dart';
import 'services/app_migration_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Bersihkan cache Firestore lama (satu kali saja per instalasi versi baru)
  await AppMigrationService.runIfNeeded();

  runApp(const ProviderScope(child: MyApp()));
}
```

**Perubahan yang dilakukan:**
- Tambah import `services/app_migration_service.dart`
- Tambah satu baris pemanggilan `await AppMigrationService.runIfNeeded();`
  di antara `Firebase.initializeApp()` dan `runApp()`
- Tidak ada perubahan lain

---

## Verifikasi Setelah Implementasi

Setelah file dibuat dan `main.dart` dimodifikasi, jalankan perintah berikut untuk
memastikan tidak ada compile error:

```bash
flutter analyze lib/services/app_migration_service.dart lib/main.dart
```

Output yang diharapkan: `No issues found!`

---

## Constraints

- **Jangan** tambahkan dependency baru ke `pubspec.yaml` —
  `shared_preferences: ^2.2.3` dan `cloud_firestore: ^5.0.0` sudah ada.
- **Jangan** modifikasi file lain selain dua file di atas.
- **Jangan** hapus atau ubah konten `LevelContentData` — itu tugas sprint terpisah.
- `AppMigrationService` harus bisa dipanggil berkali-kali tanpa efek samping
  (idempotent) — hanya `clearPersistence()` yang dijalankan satu kali.
- Jika `clearPersistence()` melempar exception, **tangkap dan log** — jangan rethrow.
  App harus tetap bisa `runApp()` meski migrasi gagal.

---

## Catatan Teknis

`FirebaseFirestore.instance.clearPersistence()` hanya bisa dipanggil setelah
`db.terminate()` — urutan ini **wajib diikuti**. Setelah `clearPersistence()`,
Firestore akan otomatis reconnect dan fetch data segar dari server saat query
pertama kali dijalankan; tidak perlu memanggil reinitialize secara manual.

SharedPreferences key menggunakan suffix versi (`_v2`). Jika di masa depan
perlu paksa clear ulang (misalnya ada skema Firestore yang berubah lagi),
cukup ubah suffix menjadi `_v3` di konstanta `_cacheCleared` — flag lama
tidak akan ditemukan sehingga clear akan dijalankan ulang.
