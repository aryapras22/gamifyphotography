# implementation-log.md — GamifyPhotography

> Catat setiap perubahan penting pada kode di sini.
> Format: `[YYYY-MM-DD] TASK-XXX: Deskripsi singkat apa yang diubah dan alasannya`

---

## Log

```
[2026-05-01] INIT: Dokumentasi SDD dibuat. Struktur docs/ dibuat berdasarkan
             analisis kode existing di GitHub. 7 known bugs diidentifikasi.
             Critical fixes (BUG-01 s.d. BUG-07) perlu diselesaikan sebelum
             pengembangan fitur baru.

[2026-05-01] TASK-M01: Buat lib/providers/service_providers.dart
             Alasan: Centralize semua service provider, hapus cross-ViewModel import
             File yang diubah: lib/providers/service_providers.dart (BARU)
             Side effect: crafting_view_model.dart diupdate untuk pakai file ini

[2026-05-01] TASK-M02 + M03: Migrasi semua model ke @freezed
             Alasan: BUG-03, BUG-06 — field mutable, tidak ada copyWith otomatis
             File yang diubah: models/module_model.dart, challenge_model.dart,
             user_model.dart, badge_model.dart, leaderboard_model.dart
             Side effect: build_runner dijalankan, semua .freezed.dart + .g.dart digenerate

[2026-05-01] TASK-M04: Refactor ChallengeViewModel ke immutable state
             Alasan: BUG-01 — state mutation langsung
             File yang diubah: lib/view_models/challenge_view_model.dart
             Side effect: ChallengeState kini punya manual copyWith, semua update via state =

[2026-05-01] TASK-M05: Ganti image_picker → camera package
             Alasan: BUG-07 — image_picker mengizinkan upload dari galeri
             File yang diubah: challenge_view_model.dart menggunakan XFile dari camera
             Side effect: ChallengeView harus diupdate juga

[2026-05-02] TASK-M12: Buat CustomCameraView (kamera native + SVG overlay)
             Alasan: ChallengeView butuh kamera langsung, bukan picker
             File yang diubah: lib/views/mission/custom_camera_view.dart (BARU)
             Side effect: Membutuhkan SVG assets di assets/images/visual_guides/
             Issue: Duplicate import camera/camera.dart di baris 2 & 3 (BUG-08)

[2026-05-02] TASK-M12 (lanjutan): Integrasi CustomCameraView ke ChallengeView
             Alasan: Flow capture foto harus melalui CustomCameraView
             File yang diubah: lib/views/mission/challenge_view.dart
             Side effect: Setelah capture, otomatis uploadPhoto + completeChallenge + navigate
             Issue: completeChallenge terpanggil 2x — saat capture dan saat tombol (BUG-09)
```

---

## Template Entry

```
[YYYY-MM-DD] TASK-XXX: Deskripsi perubahan
             Alasan: ...
             File yang diubah: lib/...
             Side effect: (jika ada)
```
