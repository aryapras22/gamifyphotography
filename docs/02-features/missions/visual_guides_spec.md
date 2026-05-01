# Visual Guide Spec — Mission 01–10 (Composition Techniques)

> **Tujuan file ini:** Menjadi single source of truth bagi AI (Cursor, Copilot, Claude Code) saat merender widget `SvgPicture` atau `Image` untuk setiap visual guide misi. Setiap entri mendefinisikan: path asset, isi visual SVG, intent pedagogis, dan aturan render di Flutter.

---

## Aturan Umum Render (Wajib Dibaca AI)

```dart
// Gunakan flutter_svg package
// pubspec.yaml: flutter_svg: ^2.x.x

SvgPicture.asset(
  'assets/images/visual_guides/XX_nama_teknik.svg',
  width: double.infinity,
  fit: BoxFit.contain,
  semanticsLabel: '<judul misi> visual guide',
);
```

- Semua SVG berformat **portrait 500×800px** (`viewBox="0 0 500 800"`).
- Background SVG selalu `fill="#000"` (hitam) — pastikan container tidak menambah padding putih.
- Jangan scale melebihi lebar layar; gunakan `BoxFit.contain` agar proporsional.
- Tampilkan di **Page 2** mission detail (tab "Visual Guide"), bukan Page 1.
- Berikan `semanticsLabel` untuk aksesibilitas.

---

## Mission 01 — Rule of Thirds

| Properti | Nilai |
|---|---|
| **Asset path** | `assets/images/visual_guides/01_rule_of_thirds.svg` |
| **Ukuran SVG** | 500 × 800 px |
| **Kategori teknik** | Komposisi |
| **Poin reward** | 100 poin |

### Deskripsi Visual SVG

SVG menggambarkan **grid 3×3** di atas latar hitam:

- 2 garis vertikal putih semi-transparan di `x=167` dan `x=333`
- 2 garis horizontal putih semi-transparan di `y=267` dan `y=533`
- **4 titik persimpangan** (power points) ditandai dengan lingkaran merah `stroke=#e03030` radius 22px + tanda silang di tengahnya

### Intent Pedagogis

Menunjukkan kepada user bahwa subjek foto sebaiknya diletakkan di salah satu dari 4 titik persimpangan (bukan di tengah frame) untuk menciptakan komposisi yang lebih dinamis dan menarik.

### Instruksi Misi untuk User

> Ambil satu foto di mana subjek utama berada tepat di salah satu titik persimpangan grid rule of thirds. Aktifkan grid di kamera HP Anda.

---

## Mission 02 — Leading Lines

| Properti | Nilai |
|---|---|
| **Asset path** | `assets/images/visual_guides/02_leading_lines.svg` |
| **Ukuran SVG** | 500 × 800 px |
| **Kategori teknik** | Komposisi |
| **Poin reward** | 100 poin |

### Deskripsi Visual SVG

SVG menggambarkan **garis-garis konvergen** yang mengarah ke satu titik fokus (vanishing point) di bagian atas tengah frame:

- Beberapa garis diagonal dari sudut bawah kiri & kanan menuju titik tengah atas
- Latar hitam untuk menonjolkan garis
- Garis berwarna putih/terang untuk kontras maksimal

### Intent Pedagogis

Melatih user mengenali dan menggunakan elemen linear (jalan, rel, koridor, pagar) sebagai "jalan mata" yang memandu perhatian pemirsa menuju subjek utama.

### Instruksi Misi untuk User

> Foto satu adegan yang menggunakan garis nyata (jalan, pagar, lorong) yang mengarahkan pandangan ke subjek utama di ujung garis.

---

## Mission 03 — Framing

| Properti | Nilai |
|---|---|
| **Asset path** | `assets/images/visual_guides/03_framing.svg` |
| **Ukuran SVG** | 500 × 800 px |
| **Kategori teknik** | Komposisi |
| **Poin reward** | 100 poin |

### Deskripsi Visual SVG

SVG menggambarkan teknik **frame-within-frame**:

- Elemen berbentuk "bingkai" (seperti pintu, lengkungan, atau pohon) di tepi luar frame foto
- Area tengah terang/fokus yang menampilkan subjek
- Transisi gelap di tepian meniru efek vignette natural dari elemen pembingkai

### Intent Pedagogis

Mengajarkan user cara menggunakan elemen lingkungan (pintu terbuka, jendela, cabang pohon) sebagai bingkai alami untuk mengisolasi dan menonjolkan subjek utama.

### Instruksi Misi untuk User

> Cari elemen alami atau buatan (pintu, jendela, lengkungan) dan gunakan sebagai bingkai untuk foto subjek Anda.

---

## Mission 04 — Symmetry

| Properti | Nilai |
|---|---|
| **Asset path** | `assets/images/visual_guides/04_symmetry.svg` |
| **Ukuran SVG** | 500 × 800 px |
| **Kategori teknik** | Komposisi |
| **Poin reward** | 100 poin |

### Deskripsi Visual SVG

SVG menggambarkan **simetri vertikal**:

- Garis sumbu tengah vertikal `x=250` sebagai garis cermin
- Bentuk/elemen yang identik di sisi kiri dan kanan sumbu
- Mungkin disertai elemen refleksi (misal bayangan di air)
- Palet warna simetris untuk memperkuat efek mirroring

### Intent Pedagogis

Melatih user menemukan dan mengabadikan simetri di lingkungan sekitar (bangunan, jalanan basah, cermin) untuk menciptakan foto yang estetis dan harmonis.

### Instruksi Misi untuk User

> Temukan objek atau adegan yang memiliki simetri sempurna (atau hampir sempurna), posisikan kamera tepat di sumbu simetri.

---

## Mission 05 — Golden Triangle

| Properti | Nilai |
|---|---|
| **Asset path** | `assets/images/visual_guides/05_golden_triangle.svg` |
| **Ukuran SVG** | 500 × 800 px |
| **Kategori teknik** | Komposisi |
| **Poin reward** | 100 poin |

### Deskripsi Visual SVG

SVG menggambarkan **grid segitiga emas**:

- Diagonal utama dari sudut kiri-bawah ke kanan-atas
- Dua garis tegak lurus dari sudut lainnya menuju diagonal utama
- Membentuk 3 segitiga siku-siku yang proporsional
- Titik-titik perpotongan ditandai sebagai power points

### Intent Pedagogis

Memperkenalkan alternatif rule of thirds yang lebih dinamis — subjek dikomposisikan mengikuti sumbu diagonal segitiga untuk menciptakan aliran visual yang lebih kuat.

### Instruksi Misi untuk User

> Susun elemen foto Anda mengikuti garis diagonal segitiga emas: subjek utama di satu segitiga, elemen pendukung di segitiga lainnya.

---

## Mission 06 — Negative Space

| Properti | Nilai |
|---|---|
| **Asset path** | `assets/images/visual_guides/06_negative_space.svg` |
| **Ukuran SVG** | 500 × 800 px |
| **Kategori teknik** | Komposisi |
| **Poin reward** | 100 poin |

### Deskripsi Visual SVG

SVG menggambarkan **kontras antara subjek kecil dan area kosong besar**:

- Subjek kecil (misal siluet orang/objek) di satu sisi frame
- Area latar yang dominan, kosong, dan bersih (langit, tembok polos, air)
- Proporsi subjek vs ruang kosong: ~1:4 hingga 1:6

### Intent Pedagogis

Mengajarkan user bahwa "ruang kosong" bukan kekosongan, melainkan elemen desain aktif yang memberikan napas, keseimbangan, dan memperkuat isolasi subjek.

### Instruksi Misi untuk User

> Foto satu subjek kecil dengan latar yang sangat bersih dan dominan. Biarkan minimal 70% frame menjadi area kosong.

---

## Mission 07 — Rule of Odds

| Properti | Nilai |
|---|---|
| **Asset path** | `assets/images/visual_guides/07_rule_of_odds.svg` |
| **Ukuran SVG** | 500 × 800 px |
| **Kategori teknik** | Komposisi |
| **Poin reward** | 100 poin |

### Deskripsi Visual SVG

SVG menggambarkan **pengelompokan objek ganjil (3 atau 5 objek)**:

- 3 objek identik atau serupa disusun dalam satu frame
- Objek tengah menjadi fokus/anchor visual
- 2 objek di sisi kiri & kanan sebagai elemen pendukung
- Komposisi tidak simetri sempurna namun terasa seimbang

### Intent Pedagogis

Mengajarkan prinsip psikologi visual bahwa jumlah objek ganjil secara alami terasa lebih menarik dan dinamis dibandingkan jumlah genap.

### Instruksi Misi untuk User

> Foto 3 atau 5 objek serupa dalam satu frame. Pastikan ada satu objek yang menjadi "pusat" visual.

---

## Mission 08 — Depth of Field

| Properti | Nilai |
|---|---|
| **Asset path** | `assets/images/visual_guides/08_depth_of_field.svg` |
| **Ukuran SVG** | 500 × 800 px |
| **Kategori teknik** | Komposisi / Teknis |
| **Poin reward** | 100 poin |

### Deskripsi Visual SVG

SVG menggambarkan **efek bokeh / selective focus**:

- Layer foreground: objek dekat, tajam (in-focus)
- Layer midground: subjek utama, paling tajam
- Layer background: blur/bokeh yang jelas
- Mungkin ada indikator visual berupa lingkaran kabur (circle of confusion) di background

### Intent Pedagogis

Memperkenalkan konsep kedalaman bidang fokus — bagaimana posisi subjek relatif terhadap kamera dan latar belakang menciptakan efek isolasi yang artistik.

### Instruksi Misi untuk User

> Foto satu objek dari dekat (makro atau portrait) dengan latar belakang yang jauh. Manfaatkan mode portrait HP atau zoom in untuk efek bokeh.

---

## Mission 09 — Point of View

| Properti | Nilai |
|---|---|
| **Asset path** | `assets/images/visual_guides/09_point_of_view.svg` |
| **Ukuran SVG** | 500 × 800 px |
| **Kategori teknik** | Komposisi |
| **Poin reward** | 100 poin |

### Deskripsi Visual SVG

SVG menggambarkan **perbandingan sudut pandang berbeda** (kemungkinan 2–3 mini-panel):

- Panel eye-level: sudut normal (pandangan mata manusia)
- Panel low-angle: kamera diarahkan ke atas, subjek tampak besar/dramatis
- Panel high-angle / bird's eye: kamera dari atas, subjek tampak kecil/unik
- Masing-masing panel mungkin diberi label atau ikon panah arah kamera

### Intent Pedagogis

Melatih user keluar dari kebiasaan memotret dari sudut mata (eye-level) dan bereksperimen dengan perspektif berbeda untuk mendapatkan hasil yang lebih kreatif.

### Instruksi Misi untuk User

> Foto subjek yang sama dari 3 sudut berbeda: eye-level, low-angle (dari bawah), dan high-angle (dari atas). Submit foto terbaik dari salah satu sudut non-standar.

---

## Mission 10 — Center Dominance

| Properti | Nilai |
|---|---|
| **Asset path** | `assets/images/visual_guides/10_center_dominance.svg` |
| **Ukuran SVG** | 500 × 800 px |
| **Kategori teknik** | Komposisi |
| **Poin reward** | 100 poin |

### Deskripsi Visual SVG

SVG menggambarkan **subjek dominan di pusat frame**:

- Subjek besar ditempatkan persis di tengah frame
- Elemen pendukung yang lebih kecil mengelilingi subjek secara simetris
- Mungkin ada lingkaran konsentris atau garis radial dari pusat untuk menekankan fokus sentral

### Intent Pedagogis

Mengajarkan bahwa center composition — meski berlawanan dengan rule of thirds — efektif untuk foto produk, portrait formal, dan pola radial yang kuat.

### Instruksi Misi untuk User

> Tempatkan subjek utama tepat di tengah frame dengan sengaja. Pastikan ada elemen pendukung yang mengelilinginya secara merata.

---

## Catatan Implementasi Flutter

```dart
// lib/features/mission/presentation/widgets/visual_guide_widget.dart

import 'package:flutter_svg/flutter_svg.dart';

class VisualGuideWidget extends StatelessWidget {
  final int missionId; // 1–10

  const VisualGuideWidget({super.key, required this.missionId});

  String get _assetPath {
    const paths = {
      1:  'assets/images/visual_guides/01_rule_of_thirds.svg',
      2:  'assets/images/visual_guides/02_leading_lines.svg',
      3:  'assets/images/visual_guides/03_framing.svg',
      4:  'assets/images/visual_guides/04_symmetry.svg',
      5:  'assets/images/visual_guides/05_golden_triangle.svg',
      6:  'assets/images/visual_guides/06_negative_space.svg',
      7:  'assets/images/visual_guides/07_rule_of_odds.svg',
      8:  'assets/images/visual_guides/08_depth_of_field.svg',
      9:  'assets/images/visual_guides/09_point_of_view.svg',
      10: 'assets/images/visual_guides/10_center_dominance.svg',
    };
    return paths[missionId] ?? paths[1]!;
  }

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      _assetPath,
      width: double.infinity,
      fit: BoxFit.contain,
      semanticsLabel: 'Visual guide for mission $missionId',
    );
  }
}
```

> ⚠️ **Pastikan semua SVG terdaftar di `pubspec.yaml`:**
> ```yaml
> flutter:
>   assets:
>     - assets/images/visual_guides/
> ```
