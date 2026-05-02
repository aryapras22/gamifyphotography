# UI/UX Audit & Design System — GamifyPhotography

> **Dibuat oleh:** Senior UI/UX Research & Principal Product Design Audit  
> **Tanggal:** 2026-05-02  
> **Versi Codebase:** Post-Sprint #6 (MVP UI Complete)  
> **Scope:** Full audit + redesign guidelines untuk handoff ke developer

---

## Ringkasan Eksekutif

GamifyPhotography memiliki fondasi arsitektur yang kuat (MVVM + Riverpod) dan semua fitur MVP sudah terimplementasi. Namun dari audit visual, terdapat **gap signifikan antara kualitas arsitektur kode dengan kualitas pengalaman visual**. Onboarding adalah satu halaman placeholder, home screen adalah kumpulan tombol plain, dan tidak ada design language yang konsisten di seluruh app. Dokumen ini menetapkan standar visual autoritatif dan panduan interaksi untuk membawa GamifyPhotography ke kualitas produk yang layak diuji oleh pengguna profesional SIG.

---

## Bagian 1 — Audit UI/UX & Temuan Friction Point

### 1.1 Peta Friction Point per Screen

| Screen | Temuan | Severity | Rekomendasi |
|--------|--------|----------|-------------|
| **Onboarding** | Satu halaman, ikon generik, satu tombol — tidak ada value proposition, tidak ada preview fitur | 🔴 Critical | Multi-step carousel dengan visual storytelling |
| **Home** | Daftar `ElevatedButton` vertikal tanpa hierarki visual — terlihat seperti debug menu | 🔴 Critical | Redesign ke dashboard gamifikasi dengan XP bar, streak, dan CTA primer tunggal |
| **Login/Register** | Belum diaudit secara visual tapi pola standar perlu branding konsisten | 🟠 High | Tambahkan logo, brand color, subtle background |
| **Module List** | Navigasi zigzag sudah ada (positif!) tapi belum ada indikator progress keseluruhan | 🟠 High | Tambahkan progress bar kategori di atas map zigzag |
| **Module Detail** | PageView 2 halaman bagus, tapi transisi antar halaman perlu polish | 🟡 Medium | Slide + fade transition, dot indicator yang jelas |
| **Challenge (Kamera)** | Overlay SVG di viewfinder adalah ide bagus, tapi UI kontrol kamera terlalu minimalis | 🟠 High | Redesign HUD kamera: shutter button floating, timer, exposure indicator |
| **Feedback View** | Belum diaudit secara visual — diasumsikan minimal | 🟠 High | Tambahkan celebration animation (Lottie), breakdown poin, next mission CTA |
| **Crafting** | Visualisasi jembatan dengan milestone sudah ada — perlu dipastikan progress bar smooth | 🟡 Medium | Pastikan animasi milestone menggunakan easing curve yang sesuai |
| **Leaderboard** | Medali top 3 sudah ada — perlu header visual yang lebih impresif | 🟡 Medium | Podium visual untuk top 3, avatar placeholder per user |
| **Profile** | Badge grid + foto grid ada — perlu visual hierarchy yang lebih kuat | 🟡 Medium | Stats card prominent di atas, badge dengan hover/tap tooltip |
| **Daily Login** | Bottom sheet 7 indikator sudah ada — perlu visual yang lebih rewarding | 🟡 Medium | Animasi streak fire, kalender mini yang lebih intuitif |

### 1.2 Core Flow Audit: Onboarding → Login → Mission Loop

**Flow Saat Ini (bermasalah):**
```
Onboarding (1 halaman flat) → Login → Home (list tombol) → 
Pilih Mission → Module List (zigzag) → Module Detail → 
Challenge Brief → Camera → Feedback → [kembali ke mana?]
```

**Masalah kritis di flow:**
1. **Dead end setelah Feedback** — tidak ada CTA eksplisit untuk lanjut ke misi berikutnya
2. **Home tidak komunikatif** — user tidak tahu progress mereka, tidak ada hook untuk kembali
3. **Onboarding tidak menjual value** — user langsung disuruh login tanpa tau kenapa harus pakai app ini
4. **Tidak ada empty state** — jika misi pertama belum diambil, module list langsung tampil tanpa context

**Flow yang Direkomendasikan:**
```
Onboarding Carousel (3 slide: Belajar → Praktik → Naik Level)
  ↓
Login / Register (branded)
  ↓
Daily Login Sheet (jika hari baru) → Dismiss
  ↓
Home Dashboard (XP bar + streak + primary CTA: "Lanjut Belajar")
  ↓
Module Map (zigzag dengan progress indicator per kategori)
  ↓
Module Detail (Teori → Visual Guide, swipe atau next button)
  ↓
Challenge Brief (overlay misi yang perlu difoto)
  ↓
Camera HUD (live viewfinder + SVG overlay + shutter)
  ↓
Photo Preview (konfirmasi foto)
  ↓
Feedback / Reward Screen (poin + XP + badge unlock jika ada)
  ↓
[CTA: "Misi Berikutnya" atau "Kembali ke Peta"]
```

---

## Bagian 2 — Design System & Visual Authority

### 2.1 Mode: Light Mode (Rekomendasi Utama)

Target pengguna adalah staf SIG berusia 35–60 tahun yang menggunakan app di luar ruangan (medan fotografi). **Light mode** lebih mudah dibaca di siang hari dan cahaya terang, serta mengurangi eye strain untuk segmen usia ini. Dark mode dapat ditambahkan sebagai enhancement di versi post-MVP.

### 2.2 Palet Warna Resmi

Inspirasi: **Duolingo gamification clarity** + **VSCO photography aesthetic** + **Professional SIG branding context**.

```
╔══════════════════════════════════════════════════════════╗
║                   PRIMARY PALETTE                        ║
╠══════════════════════════════════════════════════════════╣
║  Brand Blue (Primary Action)    → #1A73E8  (Modern, trust)║
║  Lens Gold (Accent / Reward)    → #F4A622  (Warmth, premium)║
║  Forest Green (Success / XP)    → #34A853  (Achievement)  ║
║  Coral Red (Warning / Lives)    → #EA4335  (Urgency)      ║
╠══════════════════════════════════════════════════════════╣
║                   NEUTRAL PALETTE                        ║
╠══════════════════════════════════════════════════════════╣
║  Surface White                  → #FFFFFF                 ║
║  Background Gray                → #F8F9FA                 ║
║  Card Border                    → #E8EAED                 ║
║  Body Text                      → #202124                 ║
║  Secondary Text                 → #5F6368                 ║
║  Disabled / Placeholder         → #BDC1C6                 ║
╠══════════════════════════════════════════════════════════╣
║               GAMIFICATION PALETTE                       ║
╠══════════════════════════════════════════════════════════╣
║  XP Bar Fill                    → #34A853 (gradient ke #4CAF50)║
║  Streak Fire                    → #FF6D00 (gradient ke #FFA726)║
║  Badge Locked Overlay           → #9AA0A6 (grayscale)     ║
║  Leaderboard Gold               → #FFD700                 ║
║  Leaderboard Silver             → #C0C0C0                 ║
║  Leaderboard Bronze             → #CD7F32                 ║
╚══════════════════════════════════════════════════════════╝
```

**Catatan penting:** Warna `#1CB0F6` (Duolingo blue) yang sudah digunakan di beberapa view **dipertahankan** karena sudah embedded di codebase — cukup jadikan ini sebagai `brandBlue` alias untuk `#1A73E8` di `AppColors` constant.

### 2.3 Tipografi

```dart
// Gunakan Google Fonts: Nunito (rounded, friendly, readable)
// Tambahkan ke pubspec.yaml: google_fonts: ^6.x

class AppTextStyles {
  // Display — Nama level, reward screen
  static const display = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 32,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.5,
  );

  // Heading — Section title, screen title  
  static const heading = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 24,
    fontWeight: FontWeight.w800,
  );

  // Title — Card title, list item
  static const title = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  // Body — Deskripsi, konten misi
  static const body = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  // Caption — Timestamp, secondary info
  static const caption = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Color(0xFF5F6368),
  );

  // Button — CTA text
  static const button = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 16,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.8,
  );
}
```

### 2.4 Spacing & Radius System

```dart
class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

class AppRadius {
  static const sm = Radius.circular(8.0);
  static const md = Radius.circular(16.0);
  static const lg = Radius.circular(24.0);
  static const xl = Radius.circular(32.0);
  static const full = Radius.circular(999.0); // pill shape
}
```

### 2.5 Elevation & Shadow System

```dart
class AppShadows {
  // Card default
  static const card = [
    BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2))
  ];

  // Card elevated (hover/active)
  static const cardElevated = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 16, offset: Offset(0, 4))
  ];

  // Duolingo-style bottom shadow (untuk 3D button effect)
  static BoxShadow gamificationShadow(Color color) => BoxShadow(
    color: color,
    offset: const Offset(0, 4),
    blurRadius: 0,
  );
}
```

### 2.6 Camera View — Panduan Layout Fullscreen

Camera HUD harus memaksimalkan viewfinder tanpa menghalangi komposisi:

```
┌─────────────────────────────────┐
│ ← [X]          [⚡ AUTO]  [🔆] │  ← Safe Area Top — kontrol minimal
│                                 │
│                                 │
│     [Live Viewfinder Full]      │  ← 100% lebar, ~65% tinggi layar
│                                 │
│   [- - - SVG Overlay Guide - -] │  ← SVG dengan opacity 0.35, animasi fade-in
│                                 │
│                                 │
├─────────────────────────────────┤
│  Rule of Thirds                 │  ← Nama teknik yang sedang dipraktikkan
│  "Tempatkan subjek di titik..." │  ← Hint singkat max 1 baris
├─────────────────────────────────┤
│         ●  [SHUTTER]  ●         │  ← Tombol shutter center, besar (72dp)
│      [galeri]     [flip cam]    │  ← Secondary actions kiri-kanan
└─────────────────────────────────┘
  ↑ Safe Area Bottom
```

**Aturan:**
- Shutter button: `72dp`, warna putih dengan shadow, haptic feedback `HeavyImpact`
- SVG overlay: `opacity: 0.35`, fade in dengan durasi 600ms saat kamera siap
- Tidak ada AppBar — gunakan icon `✕` floating di top-left dengan background semi-transparan
- Status bar: `SystemUiOverlayStyle.light` (teks putih) untuk kontras dengan preview

---

## Bagian 3 — Interaction Design & Gamification Refinement

### 3.1 Standar Micro-Interaction

| Trigger | Animasi | Durasi | Easing | Haptic |
|---------|---------|--------|--------|--------|
| Tap tombol primer | Scale 0.97→1.0 + shadow press | 100ms | easeOut | lightImpact |
| Misi selesai | Scale 1.0→1.15→1.0 (bounce) | 400ms | elasticOut | heavyImpact |
| Badge unlock | Scale 0 → 1.2 → 1.0 + glow ring | 600ms | elasticOut | heavyImpact |
| Poin bertambah | Counter animate (rolling number) | 800ms | easeInOut | — |
| XP bar naik | Slide fill kiri ke kanan | 600ms | easeOut | — |
| Daily claim sukses | Bounce + konfetti particle | 800ms | elasticOut | mediumImpact |
| Level up | Full-screen overlay + Lottie | 1500ms | — | heavyImpact |
| Streak bertambah | Fire icon pulse + angka bounce | 500ms | elasticOut | lightImpact |
| Pull-to-refresh | Custom spinner bertema kamera | 300ms | easeOut | — |

**Implementasi Flutter:**
```dart
// Contoh: poin rolling counter
TweenAnimationBuilder<int>(
  tween: IntTween(begin: oldPoints, end: newPoints),
  duration: const Duration(milliseconds: 800),
  curve: Curves.easeInOut,
  builder: (context, value, child) => Text(
    '$value pts',
    style: AppTextStyles.display,
  ),
);
```

### 3.2 Transisi Antar Screen

```dart
// Transisi yang direkomendasikan per flow:

// Login → Home: Fade (bukan slide — menegaskan "mulai fresh")
CustomTransitionPage(transitionsBuilder: (_, anim, __, child) =>
  FadeTransition(opacity: anim, child: child))

// Home → Module List: Slide Up (memberi kesan "masuk ke dunia")
CustomTransitionPage(transitionsBuilder: (_, anim, __, child) =>
  SlideTransition(
    position: Tween(begin: Offset(0, 0.05), end: Offset.zero)
      .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
    child: FadeTransition(opacity: anim, child: child)))

// Challenge → Feedback: Hero transition pada foto yang diambil
// Gunakan Hero widget dengan tag 'capturedPhoto'

// Feedback → Home: Pop to root + slide down
```

### 3.3 Redesign: Home Dashboard

Home screen saat ini adalah list tombol tanpa hierarki. Proposal redesign:

```
┌─────────────────────────────────────┐
│  Selamat pagi, Hasan! 👋            │  ← Greeting dinamis (pagi/siang/malam)
│                                     │
│  ┌───────────────────────────────┐  │
│  │  Lv.12  ████████░░░  850/1000│  │  ← XP Progress bar dengan level
│  │  🔥 3 hari streak             │  │  ← Streak badge
│  └───────────────────────────────┘  │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  🎯 LANJUT BELAJAR          │    │  ← PRIMARY CTA — full width
│  │  Rule of Thirds · Misi 4/10 │    │  ← Subtitle: misi terakhir
│  └─────────────────────────────┘    │
│                                     │
│  ┌──────────┐    ┌──────────┐       │
│  │ 🏆       │    │ 🌉       │       │  ← Secondary CTAs: Leaderboard + Crafting
│  │ Papan    │    │ Jembatan │       │
│  │ Peringkat│    │ 2,400pts │       │
│  └──────────┘    └──────────┘       │
│                                     │
│  Pencapaian Terbaru                 │  ← Section terakhir
│  [Badge Starter] [Badge Rookie 🔒]  │
└─────────────────────────────────────┘
```

### 3.4 Redesign: Onboarding (3 Slide)

Dari 1 halaman placeholder menjadi 3 slide yang menjual value:

```
Slide 1 — "Belajar Kapan Saja"
  Visual: Ilustrasi orang memotret dengan overlay teknik
  Headline: "Kuasai Teknik Foto Profesional"
  Sub: "Pelajari Rule of Thirds, Golden Ratio, dan 30+ teknik lainnya"
  
Slide 2 — "Langsung Praktik"
  Visual: Mockup kamera dengan SVG overlay
  Headline: "Praktik Langsung, Dapat Feedback"
  Sub: "Setiap teori diikuti tantangan foto nyata yang bisa langsung kamu coba"
  
Slide 3 — "Naik Level Bersama"
  Visual: Leaderboard + badge animasi
  Headline: "Bersaing & Berkembang Bersama Rekan"
  Sub: "Kumpulkan poin, raih lencana, dan bangun jembatan kreativitasmu"
  
CTA Final: [Mulai Sekarang] + [Sudah punya akun? Masuk]
```

### 3.5 Redesign: Feedback / Reward Screen

Ini adalah screen terpenting dalam gamification loop — harus terasa seperti "perayaan":

```
┌─────────────────────────────────────┐
│           MISI SELESAI! 🎉          │  ← Heading besar
│                                     │
│   [Foto yang baru diambil — Hero]   │  ← Preview foto 16:9
│                                     │
│   ┌─────────────────────────────┐   │
│   │  +100 poin   +1 XP Level   │   │  ← Poin animasi rolling
│   └─────────────────────────────┘   │
│                                     │
│   [Badge Unlock - jika ada]         │  ← Kondisional, animasi bounce
│                                     │
│   Teknik yang kamu gunakan:         │
│   ✓ Rule of Thirds                  │  ← Recap singkat
│                                     │
│   ┌─────────────────────────────┐   │
│   │      MISI BERIKUTNYA →      │   │  ← PRIMARY CTA
│   └─────────────────────────────┘   │
│         Kembali ke Peta             │  ← Secondary link
└─────────────────────────────────────┘
```

### 3.6 Refinement Gamifikasi — Gap Analysis

| Mekanik | Status Saat Ini | Masalah | Rekomendasi |
|---------|----------------|---------|-------------|
| **Poin** | Ada, bertambah saat selesai misi | Tidak ada visual feedback poin bertambah | Rolling counter animasi di feedback screen |
| **Level** | Ada (setiap 100 poin) | Tidak ada level-up ceremony | Full-screen overlay "Level Up!" + Lottie |
| **Streak** | 7-hari, 50 poin/hari | Visual streak di home belum ada | Fire icon + angka di header home |
| **Badge** | 5 badge dengan kondisi | Badge unlock tidak ada notifikasi in-context | Bottom sheet "Badge Baru!" dengan animasi |
| **Leaderboard** | 15 mock user, highlight current | Tidak ada perubahan rank yang terasa | Tambahkan delta rank (+2 ↑) per user |
| **Crafting** | Milestone visual 2000/4000/5000 | Milestone tidak ada celebration | Lottie animasi saat milestone tercapai |
| **Progress bar** | Ada di challenge view | Tidak ada di home / module map | XP bar di home header, % complete di map |

---

## Bagian 4 — File Constants yang Harus Dibuat Developer

Sebelum mengimplementasikan redesign, buat file berikut di `lib/core/`:

### `lib/core/app_colors.dart`
```dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const brandBlue    = Color(0xFF1CB0F6); // tetap kompatibel dengan existing
  static const lensGold     = Color(0xFFF4A622);
  static const forestGreen  = Color(0xFF34A853);
  static const coralRed     = Color(0xFFEA4335);

  // Neutral
  static const surfaceWhite  = Color(0xFFFFFFFF);
  static const backgroundGray = Color(0xFFF8F9FA);
  static const cardBorder    = Color(0xFFE8EAED);
  static const bodyText      = Color(0xFF202124);
  static const secondaryText = Color(0xFF5F6368);
  static const disabled      = Color(0xFFBDC1C6);

  // Gamification
  static const xpBarFill    = Color(0xFF34A853);
  static const streakFire   = Color(0xFFFF6D00);
  static const badgeLocked  = Color(0xFF9AA0A6);
  static const goldMedal    = Color(0xFFFFD700);
  static const silverMedal  = Color(0xFFC0C0C0);
  static const bronzeMedal  = Color(0xFFCD7F32);
}
```

### `lib/core/app_theme.dart`
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // tambahkan ke pubspec
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.brandBlue,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.backgroundGray,
    textTheme: GoogleFonts.nunitoTextTheme(),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      color: AppColors.surfaceWhite,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brandBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surfaceWhite,
      elevation: 0,
      scrolledUnderElevation: 1,
      iconTheme: IconThemeData(color: AppColors.bodyText),
      titleTextStyle: TextStyle(
        color: AppColors.bodyText,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}
```

---

## Bagian 5 — Prioritas Implementasi

Urutan implementasi yang direkomendasikan berdasarkan dampak vs effort:

| Prioritas | Task | Effort | Dampak User |
|-----------|------|--------|-------------|
| 🔴 P0 | Buat `app_colors.dart` + `app_theme.dart`, terapkan ke `MaterialApp` | 30 menit | Seluruh app langsung konsisten |
| 🔴 P0 | Redesign `HomeView` → Dashboard dengan XP bar & streak | 2 jam | First impression setelah login |
| 🔴 P0 | Redesign `FeedbackView` → Reward screen dengan animasi poin | 1.5 jam | Loop gamifikasi terasa rewarding |
| 🟠 P1 | Redesign `OnboardingView` → 3 slide carousel dengan ilustrasi | 2 jam | First-time user experience |
| 🟠 P1 | Redesign Camera HUD di `CustomCameraView` | 1.5 jam | Core interaction loop |
| 🟠 P1 | Tambahkan level-up ceremony (Lottie overlay) | 1 jam | Progression feel |
| 🟡 P2 | Polish `LeaderboardView` — delta rank, avatar placeholder | 1 jam | Social motivation |
| 🟡 P2 | Animasi badge unlock (bottom sheet celebrate) | 45 menit | Achievement feel |
| 🟡 P2 | Transisi antar screen (go_router custom transition) | 1 jam | App polish |
| 🟢 P3 | Pull-to-refresh custom spinner | 30 menit | Microinteraction |
| 🟢 P3 | Rolling number counter untuk poin | 30 menit | Microinteraction |

**Total estimasi P0 + P1:** ~8 jam sprint penuh

---

## Catatan untuk Agent / Developer

1. **Jangan ubah model atau ViewModel** — semua perbaikan di sprint UI murni di layer `views/` dan penambahan `lib/core/`
2. **Gunakan `AppColors` dan `AppTheme`** untuk semua warna baru — tidak ada hardcoded `Color(0xFF...)` di widget
3. **Existing `Animated3DButton`** di `lib/views/widgets/` sudah bagus — gunakan sebagai referensi pola untuk semua CTA primer
4. **`lottie`** sudah ada di `pubspec.yaml` — gunakan untuk level-up ceremony dan misi selesai celebration
5. **`flutter_svg`** sudah ada — gunakan untuk ilustrasi onboarding (format SVG lebih ringan dari PNG)
6. Semua file baru di `lib/core/` **tidak perlu `build_runner`**
