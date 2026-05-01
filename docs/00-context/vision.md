# vision.md — GamifyPhotography

## Tujuan Utama

GamifyPhotography adalah aplikasi pelatihan teknik fotografi berbasis gamifikasi
untuk staf **Corporate Communication Semen Indonesia Group (SIG)**.
Karyawan (usia 35–60 tahun) belajar fotografi secara mandiri, fleksibel, dan terstruktur
tanpa bergantung pada pelatihan formal.

## Target Pengguna

- **Primer:** Staf Corporate Communication SIG yang menggunakan HP untuk dokumentasi
- **Karakteristik:** Usia 35–60 tahun, waktu terbatas, familiar smartphone, awam gamifikasi

## Nilai Utama

1. **Belajar lewat praktik** — Setiap misi mengharuskan user mengambil foto nyata dengan kamera
2. **Motivasi berkelanjutan** — Poin, level, badge, leaderboard mendorong konsistensi belajar
3. **Konten terstruktur** — Materi dalam 2 halaman per misi (teori + visual guide)
4. **Reward nyata** — Crafting system: kumpulkan 5.000 poin untuk "membangun jembatan kreativitas"

## Batasan Aplikasi — Apa yang TIDAK Dibangun di MVP

- ❌ Tidak ada fitur sosial (komentar, share ke sosmed)
- ❌ Tidak ada AI/auto-feedback terhadap foto yang disubmit
- ❌ Tidak ada fitur premium/berbayar
- ❌ Hanya kategori **Komposisi** untuk MVP (10 misi pertama)
- ❌ Hanya Bahasa Indonesia
- ❌ Belum ada push notification
- ❌ User **tidak boleh upload dari galeri** — wajib pakai kamera secara langsung

## Tech Stack

| Layer | Teknologi | Versi |
|-------|-----------|-------|
| Framework | Flutter | ^3.x (Android target) |
| State Management | flutter_riverpod | ^2.5.1 |
| Routing | go_router | ^13.0.0 |
| HTTP Client | Dio | ^5.4.0 |
| Kamera | camera package | latest |
| Animasi | lottie | latest |
| Code Gen | freezed + json_serializable | latest |
| Auth | Firebase Auth | belum diintegrasi |

## Prinsip Pengembangan

- **Immutable state** — semua model wajib `@freezed`, mutasi hanya via `copyWith`
- **Single responsibility** — satu ViewModel per screen
- **Service layer terpisah** — semua `Provider<XxxService>` di `service_providers.dart`
- **No galeri** — foto hanya dari kamera (`camera` package, bukan `image_picker`)
