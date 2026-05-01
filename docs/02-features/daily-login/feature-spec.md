# feature-spec.md — Daily Login

## Deskripsi Fitur

System streak harian untuk mendorong user membuka aplikasi setiap hari.
User mendapat +50 poin per claim. Streak 7 hari penuh membuka Badge Survivor.

---

## User Journey

```
User buka app (hari baru)
  → Cek apakah hari ini sudah claim?
  → Belum → Tampilkan popup Daily Login
      → User tap "Claim Hari X"
      → +50 poin ditambahkan
      → Hari X di-highlight sebagai selesai
      → Popup ditutup
  → Sudah → Langsung ke Home
```

---

## Desain Popup

```
┌─────────────────────────────┐
│   🎯 Login Harian!          │
│                             │
│  [ H1 ][ H2 ][ H3 ][ H4 ]  │
│  [ H5 ][ H6 ][ H7 ]        │
│  (hari selesai = ✅)        │
│  (hari ini = 🔥 aktif)      │
│  (hari selanjutnya = abu)   │
│                             │
│  +50 Poin per hari          │
│  [ Claim Hari X ]           │
└─────────────────────────────┘
```

---

## Business Rules

| Rule | Detail |
|------|--------|
| Streak reset | Jika user tidak login selama >1 hari, streak kembali ke hari 1 |
| Double claim | Tidak bisa claim dua kali dalam satu hari (cek timestamp terakhir) |
| Badge trigger | Streak 7 hari berturut-turut → Badge Survivor + 100 poin |
| Poin | +50 per claim, langsung update total poin user |

---

## Data yang Dibutuhkan (Tambahan ke UserModel)

```dart
// Tambahkan ke UserModel (@freezed)
required int currentStreak,       // Streak hari ini (0-7)
required DateTime? lastLoginDate, // Timestamp claim terakhir
required List<bool> streakDays,   // [true, true, false, ...] untuk 7 hari
```
