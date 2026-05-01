# Badge Asset Spec — Semua Badge (01–10)

> **Tujuan file ini:** Menjadi referensi tunggal bagi AI saat mengimplementasikan widget badge, kondisi unlock, dan path asset SVG untuk seluruh 10 badge di aplikasi GamifyPhotography.

---

## Aturan Umum Render Badge (Wajib Dibaca AI)

```dart
// Gunakan flutter_svg package
// pubspec.yaml: flutter_svg: ^2.x.x

// Badge TERKUNCI (belum diperoleh)
ColorFiltered(
  colorFilter: const ColorFilter.matrix([
    0.2, 0.2, 0.2, 0, 0,
    0.2, 0.2, 0.2, 0, 0,
    0.2, 0.2, 0.2, 0, 0,
    0,   0,   0,   1, 0,
  ]),
  child: SvgPicture.asset('assets/images/badges/XX_nama.svg', width: 80),
)

// Badge TERBUKA (sudah diperoleh) — tampilkan full color
SvgPicture.asset(
  'assets/images/badges/XX_nama.svg',
  width: 80,
  semanticsLabel: '<nama badge> badge',
);
```

- Ukuran standar badge di **Profile screen**: `width: 80`
- Ukuran badge di **notifikasi unlock popup**: `width: 120`
- Badge yang belum di-unlock ditampilkan dalam grayscale menggunakan `ColorFiltered`
- Semua SVG badge memiliki latar transparan atau gelap — cocok untuk dark/light theme

---

## Daftar Lengkap Badge

### Badge 01 — Starter

| Properti | Nilai |
|---|---|
| **Asset path** | `assets/images/badges/01_starter.svg` |
| **File size** | ~4.1 KB |
| **Kondisi unlock** | Menyelesaikan Mission pertama (Mission Level 1) |
| **Pesan selamat** | "Selamat karena kamu sudah berani memulai hal baru!" |
| **Poin bonus** | 100 poin |

**Deskripsi visual:** Badge untuk pemula — desain bersifat welcoming dan sederhana, menggambarkan semangat awal memulai perjalanan.

---

### Badge 02 — Rookie

| Properti | Nilai |
|---|---|
| **Asset path** | `assets/images/badges/02_rookie.svg` |
| **File size** | ~2.6 KB |
| **Kondisi unlock** | Mencapai Level 15 |
| **Pesan selamat** | "Selamat karena kamu sudah mencapai level 15!" |
| **Poin bonus** | 100 poin |

**Deskripsi visual:** Badge rookie — desain menunjukkan progres awal, lebih kompleks dari Starter, menggambarkan user yang mulai mahir.

---

### Badge 03 — Veteran

| Properti | Nilai |
|---|---|
| **Asset path** | `assets/images/badges/03_veteran.svg` |
| **File size** | ~2.8 KB |
| **Kondisi unlock** | Mencapai Level 30 |
| **Pesan selamat** | "Selamat karena kamu sudah mencapai level 30!" |
| **Poin bonus** | 100 poin |

**Deskripsi visual:** Badge veteran — desain lebih megah dan detail, menggambarkan pengalaman dan keahlian yang sudah matang.

---

### Badge 04 — Special Mission

| Properti | Nilai |
|---|---|
| **Asset path** | `assets/images/badges/04_special_mission.svg` |
| **File size** | ~3.0 KB |
| **Kondisi unlock** | Menyelesaikan special mission pertama (tersedia di Level 10) |
| **Pesan selamat** | "Selamat karena kamu sudah menyelesaikan spesial misi pertama!" |
| **Poin bonus** | 100 poin |

**Deskripsi visual:** Badge bertema misi khusus — desain memiliki elemen yang lebih "eksklusif", membedakan dirinya dari badge progres biasa.

---

### Badge 05 — Conqueror

| Properti | Nilai |
|---|---|
| **Asset path** | `assets/images/badges/05_conqueror.svg` |
| **File size** | ~3.6 KB |
| **Kondisi unlock** | TBD — definisikan kondisi unlock di `mission_config.dart` |
| **Pesan selamat** | "Selamat, kamu adalah Conqueror sejati!" |
| **Poin bonus** | 100 poin |

**Deskripsi visual:** Badge penakluk — desain kuat dan dominan, file SVG terbesar kedua (~3.6KB) menandakan kompleksitas visual yang tinggi.

---

### Badge 06 — Wanderer

| Properti | Nilai |
|---|---|
| **Asset path** | `assets/images/badges/06_wanderer.svg` |
| **File size** | ~3.4 KB |
| **Kondisi unlock** | TBD — definisikan kondisi unlock di `mission_config.dart` |
| **Pesan selamat** | "Selamat, kamu adalah Wanderer yang tak kenal batas!" |
| **Poin bonus** | 100 poin |

**Deskripsi visual:** Badge penjelajah — desain bertema petualangan dan eksplorasi.

---

### Badge 07 — Adaptor

| Properti | Nilai |
|---|---|
| **Asset path** | `assets/images/badges/07_adaptor.svg` |
| **File size** | ~3.3 KB |
| **Kondisi unlock** | TBD — definisikan kondisi unlock di `mission_config.dart` |
| **Pesan selamat** | "Selamat, kamu adalah Adaptor yang luar biasa!" |
| **Poin bonus** | 100 poin |

**Deskripsi visual:** Badge adaptasi — desain menggambarkan fleksibilitas dan kemampuan menyesuaikan diri.

---

### Badge 08 — Survivor

| Properti | Nilai |
|---|---|
| **Asset path** | `assets/images/badges/08_survivor.svg` |
| **File size** | ~3.6 KB |
| **Kondisi unlock** | Menyelesaikan daily login 7 hari berturut-turut |
| **Pesan selamat** | "Selamat karena telah menyelesaikan daily login 7 hari!" |
| **Poin bonus** | 100 poin |

**Deskripsi visual:** Badge survivor — desain tangguh dan resilient, menggambarkan konsistensi dan ketahanan user.

> 💡 **Catatan implementasi:** Cek streak di Firestore field `dailyLoginStreak`. Trigger unlock saat nilai mencapai `7`.

---

### Badge 09 — Sharpshooter

| Properti | Nilai |
|---|---|
| **Asset path** | `assets/images/badges/09_sharpshooter.svg` |
| **File size** | ~3.1 KB |
| **Kondisi unlock** | TBD — definisikan kondisi unlock di `mission_config.dart` |
| **Pesan selamat** | "Selamat, ketepatan bidikanmu luar biasa, Sharpshooter!" |
| **Poin bonus** | 100 poin |

**Deskripsi visual:** Badge ketepatan — desain bertema presisi dan akurasi, cocok untuk teknik fotografi yang membutuhkan ketepatan tinggi.

---

### Badge 10 — Explorer

| Properti | Nilai |
|---|---|
| **Asset path** | `assets/images/badges/10_explorer.svg` |
| **File size** | ~3.8 KB (terbesar) |
| **Kondisi unlock** | TBD — definisikan kondisi unlock di `mission_config.dart` |
| **Pesan selamat** | "Selamat, kamu adalah Explorer yang luar biasa!" |
| **Poin bonus** | 100 poin |

**Deskripsi visual:** Badge explorer — file SVG terbesar (~3.8KB) menandakan detail visual paling kompleks. Desain bertema eksplorasi penuh semangat.

---

## Tabel Ringkasan Badge

| ID | Nama | Asset Path | Kondisi Unlock | Poin |
|---|---|---|---|---|
| 01 | Starter | `assets/images/badges/01_starter.svg` | Selesaikan Mission Level 1 | 100 |
| 02 | Rookie | `assets/images/badges/02_rookie.svg` | Capai Level 15 | 100 |
| 03 | Veteran | `assets/images/badges/03_veteran.svg` | Capai Level 30 | 100 |
| 04 | Special Mission | `assets/images/badges/04_special_mission.svg` | Selesaikan Special Mission Level 10 | 100 |
| 05 | Conqueror | `assets/images/badges/05_conqueror.svg` | TBD | 100 |
| 06 | Wanderer | `assets/images/badges/06_wanderer.svg` | TBD | 100 |
| 07 | Adaptor | `assets/images/badges/07_adaptor.svg` | TBD | 100 |
| 08 | Survivor | `assets/images/badges/08_survivor.svg` | Daily login 7 hari berturut-turut | 100 |
| 09 | Sharpshooter | `assets/images/badges/09_sharpshooter.svg` | TBD | 100 |
| 10 | Explorer | `assets/images/badges/10_explorer.svg` | TBD | 100 |

---

## Implementasi Flutter — BadgeWidget

```dart
// lib/features/badge/presentation/widgets/badge_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BadgeWidget extends StatelessWidget {
  final int badgeId;        // 1–10
  final bool isUnlocked;
  final double size;

  const BadgeWidget({
    super.key,
    required this.badgeId,
    required this.isUnlocked,
    this.size = 80,
  });

  static const Map<int, String> _assetPaths = {
    1:  'assets/images/badges/01_starter.svg',
    2:  'assets/images/badges/02_rookie.svg',
    3:  'assets/images/badges/03_veteran.svg',
    4:  'assets/images/badges/04_special_mission.svg',
    5:  'assets/images/badges/05_conqueror.svg',
    6:  'assets/images/badges/06_wanderer.svg',
    7:  'assets/images/badges/07_adaptor.svg',
    8:  'assets/images/badges/08_survivor.svg',
    9:  'assets/images/badges/09_sharpshooter.svg',
    10: 'assets/images/badges/10_explorer.svg',
  };

  static const Map<int, String> _badgeNames = {
    1: 'Starter', 2: 'Rookie', 3: 'Veteran',
    4: 'Special Mission', 5: 'Conqueror', 6: 'Wanderer',
    7: 'Adaptor', 8: 'Survivor', 9: 'Sharpshooter', 10: 'Explorer',
  };

  @override
  Widget build(BuildContext context) {
    final svgWidget = SvgPicture.asset(
      _assetPaths[badgeId]!,
      width: size,
      height: size,
      semanticsLabel: '${_badgeNames[badgeId]} badge',
    );

    if (isUnlocked) return svgWidget;

    // Grayscale filter untuk badge terkunci
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix([
        0.2, 0.2, 0.2, 0, 0,
        0.2, 0.2, 0.2, 0, 0,
        0.2, 0.2, 0.2, 0, 0,
        0,   0,   0,   0.5, 0,
      ]),
      child: svgWidget,
    );
  }
}
```

## Implementasi Flutter — BadgeUnlockPopup

```dart
// Tampilkan popup saat badge baru di-unlock
void showBadgeUnlockDialog(BuildContext context, int badgeId) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BadgeWidget(badgeId: badgeId, isUnlocked: true, size: 120),
          const SizedBox(height: 16),
          Text(
            BadgeWidget._badgeNames[badgeId] ?? '',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text('Badge baru berhasil diperoleh! +100 poin'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Keren!'),
        ),
      ],
    ),
  );
}
```

> ⚠️ **Pastikan semua SVG badge terdaftar di `pubspec.yaml`:**
> ```yaml
> flutter:
>   assets:
>     - assets/images/badges/
> ```
