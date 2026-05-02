# bug-log.md — GamifyPhotography

> Catat semua bug yang ditemukan, root cause-nya, dan cara fix-nya.

---

| ID | Severity | Status | File | Deskripsi | Root Cause | Fix |
|----|----------|--------|------|-----------|------------|-----|
| BUG-01 | 🔴 Critical | ✅ Closed | `challenge_view_model.dart` | State mutation langsung pada objek `challenge` | Field `ChallengeModel` bukan final | Konversi ke `@freezed`, gunakan `copyWith` |
| BUG-02 | 🔴 Critical | ✅ Closed | `auth_view_model.dart` | Mock bypass: login selalu sukses tanpa validasi | Kode development tidak dihapus | Hapus bypass, sambungkan ke `AuthService` |
| BUG-03 | 🟠 High | ✅ Closed | `user_model.dart` | Field `points`, `level` bisa diubah langsung dari luar | Tidak menggunakan `@freezed` | Konversi ke `@freezed` |
| BUG-04 | 🟠 High | ✅ Closed | `challenge_view_model.dart` | Import `CraftingViewModel` dari `ChallengeViewModel` | Cross-ViewModel dependency | Buat `service_providers.dart`, akses via service layer |
| BUG-05 | 🟡 Medium | ✅ Closed | `crafting_view_model.dart` | `userServiceProvider` didefinisikan di dalam file ini | Provider tidak di-centralize | Pindah ke `service_providers.dart` |
| BUG-06 | 🟡 Medium | ✅ Closed | `models/*.dart` | Semua model belum `@freezed` | Belum diimplementasi | Jalankan migrasi `@freezed` per model |
| BUG-07 | 🟡 Medium | ✅ Closed | `challenge_view_model.dart` | Menggunakan `image_picker` yang memperbolehkan galeri | Package yang salah | Ganti ke `camera` package |
| BUG-08 | 🟡 Medium | ⏳ Open | `custom_camera_view.dart` | Duplicate import `package:camera/camera.dart` di baris 2 dan 3 | Copy-paste saat buat file | Hapus salah satu import duplikat |
| BUG-09 | 🟡 Medium | ⏳ Open | `challenge_view.dart` | `completeChallenge()` dipanggil 2x: saat capture dan saat tombol "CEK HASIL" | Dua flow yang tidak konsisten | Pisahkan flow: capture hanya uploadPhoto, tombol yang trigger completeChallenge |
