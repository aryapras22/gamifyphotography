# feature-spec.md — Leaderboard

## Deskripsi Fitur

Leaderboard menampilkan peringkat semua user berdasarkan total poin.
Mendorong kompetisi sehat antar staf SIG.

---

## Layout

```
┌─────────────────────────────┐
│       🏆 Leaderboard        │
├─────────────────────────────┤
│ 🥇 1. Budi Santoso   1.250p │
│ 🥈 2. Siti Rahayu    1.100p │
│ 🥉 3. Ahmad Fauzi      950p │
│    4. Dewi Kusuma      800p │  ← highlight jika ini user aktif
│    ...                      │
└─────────────────────────────┘
```

---

## Business Rules

| Rule | Detail |
|------|--------|
| Urutan | Descending berdasarkan total poin |
| Highlight | Row user yang sedang login diberi warna berbeda |
| Refresh | Data di-fetch ulang setiap kali halaman dibuka (tidak real-time) |
| Top 3 | Baris 1–3 mendapat ikon medali (🥇🥈🥉) |

---

## dev-tasks.md — Leaderboard

| ID | Task | Estimasi | Status |
|----|------|----------|--------|
| TASK-L01 | Buat `LeaderboardService.getLeaderboard()` (mock: list 10 user) | 30 mnt | ⏳ |
| TASK-L02 | Buat `LeaderboardViewModel` (StateNotifier): fetch + sort by points | 30 mnt | ⏳ |
| TASK-L03 | Sambungkan `LeaderboardView` ke `LeaderboardViewModel` | 30 mnt | ⏳ |
| TASK-L04 | Highlight baris user aktif (bandingkan ID dengan user login) | 20 mnt | ⏳ |
| TASK-L05 | Tampilkan ikon medali untuk top 3 | 20 mnt | ⏳ |
| TASK-L06 | Tambahkan loading skeleton + empty state | 20 mnt | ⏳ |
