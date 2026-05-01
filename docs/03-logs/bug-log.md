# bug-log.md — GamifyPhotography

> Catat semua bug yang ditemukan, root cause-nya, dan cara fix-nya.

---

| ID | Severity | Status | File | Deskripsi | Root Cause | Fix |
|----|----------|--------|------|-----------|------------|-----|
| BUG-01 | 🔴 Critical | Open | `challenge_view_model.dart` | State mutation langsung pada objek `challenge` | Field `ChallengeModel` bukan final | Konversi ke `@freezed`, gunakan `copyWith` |
| BUG-02 | 🔴 Critical | Open | `auth_view_model.dart` | Mock bypass: login selalu sukses tanpa validasi | Kode development tidak dihapus | Hapus bypass, sambungkan ke `AuthService` |
| BUG-03 | 🟠 High | Open | `user_model.dart` | Field `points`, `level` bisa diubah langsung dari luar | Tidak menggunakan `@freezed` | Konversi ke `@freezed` |
| BUG-04 | 🟠 High | Open | `challenge_view_model.dart` | Import `CraftingViewModel` dari `ChallengeViewModel` | Cross-ViewModel dependency | Buat `service_providers.dart`, akses via service layer |
| BUG-05 | 🟡 Medium | Open | `crafting_view_model.dart` | `userServiceProvider` didefinisikan di dalam file ini | Provider tidak di-centralize | Pindah ke `service_providers.dart` |
| BUG-06 | 🟡 Medium | Open | `models/*.dart` | Semua model belum `@freezed` | Belum diimplementasi | Jalankan migrasi `@freezed` per model |
| BUG-07 | 🟡 Medium | Open | `challenge_view_model.dart` | Menggunakan `image_picker` yang memperbolehkan galeri | Package yang salah | Ganti ke `camera` package |
