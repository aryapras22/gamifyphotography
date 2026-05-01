# assumptions.md — GamifyPhotography

## Asumsi Produk

| ID | Asumsi | Risiko jika Salah | Cara Validasi |
|----|--------|-------------------|---------------|
| P1 | Staf SIG mau menggunakan kamera HP untuk submit foto misi | User enggan karena kualitas rendah | Uji usability dengan 3–5 staf SIG |
| P2 | 10 misi Komposisi cukup untuk evaluasi skripsi (SUS + UES) | Data tidak representatif | Konfirmasi dengan pembimbing |
| P3 | Sistem poin + badge + leaderboard memotivasi user | User tidak peduli gamifikasi | Pantau mission completion rate |
| P4 | Visual guide berupa foto contoh sudah cukup | User butuh video demonstrasi | Amati pertanyaan berulang saat uji coba |

## Asumsi Teknis

| ID | Asumsi | Risiko jika Salah | Cara Validasi |
|----|--------|-------------------|---------------|
| T1 | REST API backend akan tersedia sebelum integrasi | Harus bangun backend sendiri | Konfirmasi dengan dosen pembimbing |
| T2 | `camera` package bekerja di device target (Android 8+) | Crash di device SIG | Tes langsung di device staf SIG |
| T3 | Foto dari kamera perlu di-compress sebelum upload | Upload gagal (file terlalu besar) | Uji dengan foto ~5MB |
| T4 | Leaderboard tidak perlu real-time, cukup refresh saat buka | Leaderboard terasa stale | Evaluasi feedback user |
| T5 | Level dihitung per misi selesai, bukan per poin | Inkonsistensi badge requirement | Finalisasi sebelum implementasi |

## Asumsi Bisnis / Akademis

| ID | Asumsi | Risiko jika Salah | Cara Validasi |
|----|--------|-------------------|---------------|
| B1 | Aplikasi cukup sebagai prototype skripsi (tidak perlu Play Store) | Butuh proses signing panjang | Konfirmasi scope dengan pembimbing |
| B2 | Data foto yang disubmit tidak bersifat sensitif | Perlu kebijakan privasi ketat | Cek regulasi data internal SIG |

---

## ⚠️ Formula Level — PERLU DIFINALISASI SEBELUM IMPLEMENTASI

**Kode saat ini (tidak konsisten):**
```dart
user.level = (user.points ~/ 100) + 1;
```

**Masalah:** Badge Rookie di level 15 butuh 1.400 poin, tapi max poin MVP hanya ~1.850.
Badge Veteran (level 30) mustahil dicapai dengan 10 misi.

**Rekomendasi (berbasis misi selesai):**
```
level = jumlahMisiSelesai + 1
```

| Kondisi | Level | Badge Trigger |
|---------|-------|---------------|
| Belum ada misi | 1 | — |
| Misi ke-1 selesai | 2 | Badge Starter |
| Misi ke-9 selesai | 10 | Badge Special Mission |
| Misi ke-14 selesai | 15 | Badge Rookie |
| Misi ke-29 selesai | 30 | Badge Veteran |

> **ACTION REQUIRED:** Konfirmasi formula ini dengan pembimbing sebelum coding.
