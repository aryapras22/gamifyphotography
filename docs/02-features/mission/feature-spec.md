# feature-spec.md — Mission (Core)

## Deskripsi Fitur

Mission adalah fitur inti. User mempelajari teknik fotografi melalui konten 2 halaman,
lalu membuktikan pemahaman dengan mengambil foto langsung menggunakan kamera device.

---

## User Journey

```
[Home] → Tap "Mission"
  → [Module List View]
      → Tap salah satu misi
  → [Module Detail — Page 1: Teori]
      → Tap "Lihat Visual Guide"
  → [Module Detail — Page 2: Visual Guide]
      → Tap "Mulai Challenge"
  → [Challenge Brief View]
      → Tap "Buka Kamera"
  → [Challenge View — Kamera aktif]
      → Ambil foto → Preview
      → Tap "Retake" atau "Submit"
  → [Feedback View]
      → Animasi poin masuk
      → "Kembali ke Home" atau "Misi Berikutnya"
```

---

## 10 Misi Komposisi (MVP)

| ID | Nama Misi | Deskripsi Singkat |
|----|-----------|-------------------|
| M01 | Rule of Thirds | Letakkan subjek di titik potong garis sepertiga |
| M02 | Leading Lines | Gunakan garis untuk mengarahkan mata ke subjek |
| M03 | Framing within a Frame | Gunakan elemen alami sebagai bingkai subjek |
| M04 | Symmetry and Patterns | Temukan simetri atau pola berulang |
| M05 | Golden Triangle | Bagi frame diagonal menjadi segitiga |
| M06 | Negative Space | Ruang kosong di sekitar subjek |
| M07 | Rule of Odds | Foto dengan subjek berjumlah ganjil (3 atau 5) |
| M08 | Depth of Field | Pemisahan foreground-subjek-background (bokeh) |
| M09 | Point of View | Sudut tidak biasa: bird's eye atau frog's eye |
| M10 | Center Dominance | Subjek tepat di tengah |

---

## Struktur Konten Per Misi

### Halaman 1 — Teori
- Nama teknik, deskripsi 2–3 paragraf, contoh foto, tombol "Lihat Visual Guide"

### Halaman 2 — Visual Guide
- Kapan digunakan, cara menggunakan, gambar diagram, tombol "Mulai Challenge"

---

## Edge Cases

| Kondisi | Perilaku |
|---------|----------|
| Misi sudah selesai | Info selesai + poin diperoleh, tidak bisa diulang |
| Izin kamera ditolak | Dialog instruksi ke Settings |
| Upload gagal | Snackbar error, foto tidak hilang, bisa retry |
| Foto >5MB | Kompres otomatis sebelum upload |
| Tidak ada koneksi | Pesan offline yang jelas |
