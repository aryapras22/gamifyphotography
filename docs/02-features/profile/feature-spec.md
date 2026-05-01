# feature-spec.md — Profile

## Deskripsi Fitur

Profile menampilkan identitas user, badge yang diperoleh, dan galeri foto
dari hasil submit challenge misi.

---

## Layout (Scroll dari atas ke bawah)

```
┌─────────────────────────────┐
│  [Avatar/Inisial]           │
│  Nama User                  │
│  Level X  •  Total Poin     │
├─────────────────────────────┤
│  🏅 Badge Saya              │
│  [Starter] [Rookie] [...]   │
│  (terkunci = abu-abu)       │
├─────────────────────────────┤
│  📸 Foto Saya               │
│  [ foto1 ] [ foto2 ]        │
│  [ foto3 ] [ foto4 ]        │
│  (empty state jika kosong)  │
└─────────────────────────────┘
```

---

## Business Rules

| Rule | Detail |
|------|--------|
| Avatar | Tampilkan inisial nama jika tidak ada foto profil |
| Badge terkunci | Tampil abu-abu dengan ikon gembok |
| Galeri | Hanya foto dari submit challenge (bukan foto umum) |
| Tap foto | Dialog detail: nama misi + tanggal submit |
| Empty galeri | Ilustrasi + teks "Selesaikan misi untuk foto pertamamu!" |

---

## dev-tasks.md — Profile

| ID | Task | Estimasi | Status |
|----|------|----------|--------|
| TASK-P01 | Buat `ProfileViewModel`: ambil data user, badge, dan foto dari service | 45 mnt | ⏳ |
| TASK-P02 | Buat `profile_view.dart`: header identitas + level + poin | 45 mnt | ⏳ |
| TASK-P03 | Buat `BadgeGridWidget`: tampilkan 5 badge (earned/locked) | 30 mnt | ⏳ |
| TASK-P04 | Buat `PhotoGalleryWidget`: grid 2 kolom foto dari challenge | 30 mnt | ⏳ |
| TASK-P05 | Buat `PhotoDetailDialog`: nama misi + tanggal saat tap foto | 20 mnt | ⏳ |
| TASK-P06 | Tambah empty state galeri dengan ilustrasi | 20 mnt | ⏳ |
