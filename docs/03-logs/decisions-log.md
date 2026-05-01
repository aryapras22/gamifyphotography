# decisions-log.md — GamifyPhotography

> Architecture Decision Records (ADR). Catat setiap keputusan teknis penting
> beserta alasannya agar tidak dipertanyakan ulang di masa depan.

---

## ADR-001: State Management — Riverpod

**Tanggal:** sebelum 2026-05-01 (sudah ada di kode)
**Status:** ✅ Diterima

**Keputusan:** Menggunakan `flutter_riverpod` ^2.5.1

**Alasan:**
- Compile-safe: error terdeteksi saat compile, bukan runtime
- Tidak butuh BuildContext untuk mengakses provider
- Mendukung pola MVVM dengan `StateNotifier` secara natural
- Auto-dispose untuk mencegah memory leak

---

## ADR-002: Kamera — package `camera` (bukan `image_picker`)

**Tanggal:** 2026-05-01
**Status:** ✅ Diterima

**Keputusan:** Gunakan `camera` package untuk semua foto challenge

**Alasan:**
- Requirement: user WAJIB foto langsung (tidak boleh dari galeri)
- `image_picker` memperbolehkan galeri — melanggar requirement
- `camera` package memberikan kontrol penuh atas kamera

**Trade-off:** Implementasi lebih kompleks, tapi sesuai tujuan pedagogis app

---

## ADR-003: Model Immutability — @freezed

**Tanggal:** 2026-05-01
**Status:** ✅ Diterima (belum diimplementasi)

**Keputusan:** Semua model wajib menggunakan `@freezed`

**Alasan:**
- Mencegah bug state mutation yang sudah ada (BUG-01, BUG-03)
- `copyWith` otomatis di-generate
- `fromJson`/`toJson` otomatis
- Kompatibel dengan Riverpod StateNotifier pattern

---

## ADR-004: Formula Level

**Tanggal:** 2026-05-01
**Status:** ⏳ Perlu konfirmasi pembimbing

**Keputusan (proposal):** `level = jumlahMisiSelesai + 1`

**Alasan:**
- Formula saat ini `(points ~/ 100) + 1` inkonsisten dengan badge requirement
- Badge Veteran (level 30) tidak mungkin dicapai dengan 10 misi MVP
- Formula berbasis misi lebih predictable dan sesuai game design
