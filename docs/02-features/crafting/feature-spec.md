# feature-spec.md — Crafting

## Deskripsi Fitur

Crafting adalah sistem endgame visual. User "membangun jembatan kreativitas"
dengan mengumpulkan 5.000 poin dari semua aktivitas di app.

---

## Sumber Poin (Total 5.000)

| Sumber | Jumlah | Poin per Unit | Total |
|--------|--------|---------------|-------|
| Mission selesai | 35 misi | 100 | 3.500 |
| Task selesai | 5 task | 100 | 500 |
| Badge diperoleh | 5 badge | 100 | 500 |
| Daily login | X hari | 50 | variabel |

---

## Visual Milestone Jembatan

| Poin | Visual |
|------|--------|
| 0 – 1.999 | Pondasi jembatan (tanah dan tiang) |
| 2.000 – 3.999 | Rangka jembatan (struktur besi) |
| 4.000 – 4.999 | Jembatan hampir selesai (papan terpasang) |
| 5.000+ | Jembatan selesai penuh (animasi selebrasi) |

---

## User Journey

```
[Home] → Tap tab "Crafting"
  → Tampil visual jembatan sesuai total poin
  → Tampil progress bar: X / 5.000 poin
  → (Jika milestone baru tercapai) → Animasi Lottie satu kali
```

---

## dev-tasks.md — Crafting

| ID | Task | Estimasi | Status |
|----|------|----------|--------|
| TASK-C01 | Pindahkan `userServiceProvider` ke `service_providers.dart` | 15 mnt | ⏳ |
| TASK-C02 | Buat 4 aset visual jembatan (Lottie/SVG) sesuai milestone | 60 mnt | ⏳ |
| TASK-C03 | Update `CraftingViewModel`: tampilkan milestone berdasarkan total poin | 30 mnt | ⏳ |
| TASK-C04 | Implementasi animasi transisi saat poin melewati milestone baru | 45 mnt | ⏳ |
| TASK-C05 | Tampilkan progress bar animasi: dari poin lama ke poin baru | 30 mnt | ⏳ |
