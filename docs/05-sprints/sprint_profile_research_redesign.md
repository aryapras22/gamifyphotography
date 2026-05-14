# Sprint: Profile UI — Research-Based Redesign
**Branch:** `feature/profile-redesign`
**Base:** `fix/color-consistency` (merge dulu sprint warna) atau `main`
**Repo:** https://github.com/aryapras22/gamifyphotography

---

## RESEARCH FINDINGS — Apa Saja yang Harus Ada di Profile Screen?

Berdasarkan riset dari:
- **Eleken.co** — 20 profile page design examples & UX best practices
- **Duolingo Profile** — benchmark gamification profile terbaik
- **LinkedIn Profile** — hierarchy: identity → stats → achievement
- **Gamification UX research** — badge, point, streak, progress bar sebagai motivator intrinsik
- **Proposal skripsi GFD** — elemen gamifikasi yang disepakati: poin, level, badge, progress, feedback

### Komponen Wajib (Must-Have)

| # | Komponen | Referensi | Alasan |
|---|---|---|---|
| 1 | **Hero Identity** (avatar, nama, email) | Semua top apps | First thing user lihat — harus prominent |
| 2 | **Stat Cards** (Poin & Level) | Duolingo, LinkedIn | Motivasi utama — tunjukkan progres nyata |
| 3 | **XP Progress Bar** menuju level berikutnya | Duolingo, proposal GFD | "Incompleteness effect" — user terdorong melengkapi |
| 4 | **Badge/Lencana** earned vs locked | Proposal GFD, gamification research | Identitas visual atas pencapaian |
| 5 | **Foto Karya Saya** (galeri misi selesai) | Instagram, Behance | Portfolio — bukti nyata kemampuan |
| 6 | **Ringkasan Aktivitas** (misi selesai, streak) | GitHub activity, Duolingo streak | Dorong konsistensi latihan |

### Komponen Nice-to-Have (sprint ini)

| # | Komponen | Referensi | Alasan |
|---|---|---|---|
| 7 | **Modul yang sedang berjalan** (in-progress) | Learning apps | Shortcut balik ke misi — reduce friction |
| 8 | **Counter pencapaian** (total misi selesai) | LinkedIn stats | Rasa bangga & identitas |
| 9 | **Logout button** yang mudah ditemukan | NWORX case study — bottom or top-right | Hindari "where's logout?" frustration |
| 10 | **Pull-to-refresh** untuk update data | Standard mobile UX | Data profile harus bisa di-refresh manual |

### Komponen yang TIDAK perlu (hindari scope creep)

- Edit profile (nama, foto avatar) — fitur terpisah, tidak dalam sprint ini
- Settings/pengaturan notifikasi — bukan prioritas prototype skripsi
- Social features (follow, share) — app ini bukan sosial, tapi personal training

---

## ANATOMY HASIL RISET — Layout Profile Optimal

Berdasarkan analisis Duolingo (gamification profile terbaik) dan Eleken best practices:

```
┌─────────────────────────────────────────────┐
│  [SliverAppBar - brandBlue - expandedH:220] │
│  ┌─────────────────────────────────────────┐│
│  │  🔵 Avatar (initials)                   ││
│  │  Nama Pengguna                          ││
│  │  email@gmail.com                        ││
│  └─────────────────────────────────────────┘│
│  [Collapsed → sticky blue bar + "PROFIL"]   │
├─────────────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐                 │
│  │  💎 200  │  │  🏆 Lv.3│   ← StatCards   │
│  │  Poin    │  │  Level   │   (Expanded)    │
│  └──────────┘  └──────────┘                 │
│                                             │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━░░░░░  Lv.4      │
│  XP: 200 / 350  (Progress Bar ke level up) │
│                                             │
├─────────────────────────────────────────────┤
│  📊 RINGKASAN AKTIVITAS                    │
│  ┌────────┐ ┌────────┐ ┌────────┐          │
│  │  🎯 5  │ │  🔥 3  │ │ 📸 8  │          │
│  │ Misi   │ │ Streak │ │ Foto  │          │
│  └────────┘ └────────┘ └────────┘          │
├─────────────────────────────────────────────┤
│  🏅 LENCANA SAYA                    3/8    │
│  ┌──────────────────────────────────────┐   │
│  │ [Badge] [Badge] [Badge] [🔒] [🔒]  │   │
│  │  nama    nama    nama                │   │
│  └──────────────────────────────────────┘   │
├─────────────────────────────────────────────┤
│  📸 FOTO SAYA                       8 foto │
│  ┌────┐ ┌────┐ ┌────┐                       │
│  │foto│ │foto│ │foto│  ← Grid 3 kolom       │
│  └────┘ └────┘ └────┘  Network-aware load   │
└─────────────────────────────────────────────┘
```

---

## STRICT RULES

1. Jangan ubah `AppColors`, `AppTextStyles`, ViewModel, Router, atau file lain selain yang disebutkan.
2. Tidak ada package baru. Gunakan yang sudah ada di `pubspec.yaml`.
3. `flutter analyze` zero errors setelah selesai.
4. Semua data diambil dari `profileViewModelProvider` — jangan buat provider baru.
5. Jika data tidak tersedia di ViewModel (misal: `completedMissionsCount`, `currentStreak`), gunakan fallback dari data yang ada: `earnedBadgeIds.length` untuk misi selesai, default 0 untuk streak sampai VM diupdate.
6. Perubahan utama hanya di `lib/views/profile/profile_view.dart`.

---

## TASK 1 — Fix Critical Bug: Foto menampilkan warna blok

**Root cause:** `Image.file(File("https://..."))` dipakai untuk URL Firebase Storage.

Di `_PhotoSection`, **ganti seluruh `itemBuilder`**:

```dart
itemBuilder: (context, index) {
  final url = photoUrls[index];
  final isNetwork = url.startsWith('http://') || url.startsWith('https://');

  return ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: isNetwork
        ? Image.network(
            url,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                color: AppColors.backgroundGray,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.brandBlue,
                    strokeWidth: 2,
                  ),
                ),
              );
            },
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.backgroundGray,
              child: const Icon(Icons.broken_image_rounded, color: AppColors.disabled),
            ),
          )
        : Image.file(
            File(url),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.backgroundGray,
              child: const Icon(Icons.broken_image_rounded, color: AppColors.disabled),
            ),
          ),
  );
},
```

**DoD Task 1:**
- [ ] Foto dari Firebase Storage (https://...) tampil sebagai gambar nyata
- [ ] Loading spinner tampil saat gambar diunduh
- [ ] Placeholder broken_image tampil jika gagal, tidak crash
- [ ] File lokal tetap pakai Image.file()

---

## TASK 2 — Redesign Layout: Hero AppBar

**Root cause:** AppBar flat putih, avatar ganda, tidak ada visual identitas.

Ganti `Scaffold.appBar` biasa dengan `CustomScrollView` + `SliverAppBar`:

```dart
@override
Widget build(BuildContext context) {
  final state = ref.watch(profileViewModelProvider);

  return Scaffold(
    backgroundColor: AppColors.backgroundGray,
    body: state.isLoading
        ? const Center(child: CircularProgressIndicator(color: AppColors.brandBlue))
        : state.user == null
            ? _buildErrorState(state.errorMessage)
            : RefreshIndicator(
                color: AppColors.brandBlue,
                onRefresh: () =>
                    ref.read(profileViewModelProvider.notifier).refreshProfile(),
                child: CustomScrollView(
                  slivers: [
                    // Hero SliverAppBar
                    SliverAppBar(
                      pinned: true,
                      expandedHeight: 220,
                      backgroundColor: AppColors.brandBlue,
                      elevation: 0,
                      automaticallyImplyLeading: false,
                      title: const Text(
                        'PROFIL',
                        style: TextStyle(
                          color: AppColors.surfaceWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      centerTitle: true,
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.logout_rounded, color: AppColors.surfaceWhite),
                          tooltip: 'Keluar',
                          onPressed: () {
                            ref.read(authViewModelProvider.notifier).logout();
                            context.go('/login');
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        collapseMode: CollapseMode.pin,
                        background: _HeroHeader(user: state.user!),
                      ),
                    ),

                    // Body content
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _StatRow(user: state.user!),
                          const SizedBox(height: 16),
                          _XpProgressBar(user: state.user!),
                          const SizedBox(height: 24),
                          _ActivitySummary(
                            completedMissions: state.earnedBadgeIds.length, // fallback
                            photoCount: state.completedChallengePhotoUrls.length,
                          ),
                          const SizedBox(height: 24),
                          _BadgeSection(
                            allBadges: state.allBadges,
                            earnedBadgeIds: state.earnedBadgeIds,
                          ),
                          const SizedBox(height: 24),
                          _PhotoSection(photoUrls: state.completedChallengePhotoUrls),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
  );
}
```

**DoD Task 2:**
- [ ] SliverAppBar expand ke 220px saat di atas, collapse ke 56px (sticky biru) saat scroll
- [ ] Title "PROFIL" tampil saat collapsed, tersembunyi saat expanded
- [ ] Logout icon di kanan atas, selalu terlihat
- [ ] Tidak ada AppBar biasa / TabBar yang tersisa
- [ ] Pull-to-refresh bekerja

---

## TASK 3 — Hero Header Widget

Buat widget baru `_HeroHeader` di bawah class utama:

```dart
class _HeroHeader extends StatelessWidget {
  final dynamic user;
  const _HeroHeader({required this.user});

  String get _initials {
    final name = (user.name as String).trim();
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    return parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.brandBlue,
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Avatar ring
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceWhite.withValues(alpha: 0.3),
            ),
            child: CircleAvatar(
              radius: 38,
              backgroundColor: AppColors.surfaceWhite,
              child: Text(
                _initials,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.brandBlue,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            user.name as String,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.surfaceWhite,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            user.email as String,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.surfaceWhite.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
```

**DoD Task 3:**
- [ ] Avatar tunggal (tidak duplikat dari AppBar)
- [ ] Ring putih transparan mengelilingi avatar — identitas visual yang jelas
- [ ] Nama bold putih, email semi-transparan di bawahnya
- [ ] Background biru solid `AppColors.brandBlue`

---

## TASK 4 — Stat Cards (Responsif)

Ganti `_StatCard` lama (hardcoded `width: 120`) dengan layout `Expanded`:

```dart
class _StatRow extends StatelessWidget {
  final dynamic user;
  const _StatRow({required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.diamond_rounded,
            iconColor: AppColors.brandBlue,
            label: 'Poin',
            valueWidget: TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: user.points as int),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.brandBlue,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.workspace_premium_rounded,
            iconColor: AppColors.lensGold,
            label: 'Level',
            valueWidget: Text(
              'Lv.${user.level}',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppColors.lensGold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Widget valueWidget;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 2),
        boxShadow: const [
          BoxShadow(color: AppColors.cardBorder, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          valueWidget,
        ],
      ),
    );
  }
}
```

**DoD Task 4:**
- [ ] Stat card responsif ke lebar layar (pakai Expanded, bukan width hardcode)
- [ ] Poin card: biru, dengan animasi count-up dari 0
- [ ] Level card: gold/amber
- [ ] Ikon kecil di kiri label (diamond untuk poin, premium untuk level)

---

## TASK 5 — XP Progress Bar (BARU — belum ada)

Komponen baru berdasarkan riset Duolingo & proposal GFD (elemen "Progress Bar"):

```dart
class _XpProgressBar extends StatelessWidget {
  final dynamic user;
  const _XpProgressBar({required this.user});

  // Kalkulasi XP yang dibutuhkan per level
  // Formula sederhana: setiap level butuh 100 * level XP
  // Contoh: Lv1→Lv2 = 100 XP, Lv2→Lv3 = 200 XP, dst
  int get _xpForCurrentLevel => (user.level as int) * 100;
  int get _xpProgress => (user.points as int) % _xpForCurrentLevel;
  double get _progressPercent =>
      (_xpProgress / _xpForCurrentLevel).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 2),
        boxShadow: const [
          BoxShadow(color: AppColors.cardBorder, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.bolt_rounded,
                      color: AppColors.xpAmber, size: 18),
                  const SizedBox(width: 6),
                  const Text(
                    'XP menuju Level berikutnya',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.bodyText,
                    ),
                  ),
                ],
              ),
              Text(
                '$_xpProgress / $_xpForCurrentLevel XP',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar dengan animasi
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: _progressPercent),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return Stack(
                children: [
                  // Background track
                  Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundGray,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  // Fill
                  FractionallySizedBox(
                    widthFactor: value,
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.brandBlue, AppColors.xpAmber],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          // Label level
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lv.${user.level}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandBlue,
                ),
              ),
              Text(
                'Lv.${(user.level as int) + 1}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

**DoD Task 5:**
- [ ] Progress bar tampil dengan animasi fill dari 0% ke nilai aktual
- [ ] Gradient biru→amber pada bar
- [ ] Label "Lv.X" di kiri dan "Lv.X+1" di kanan
- [ ] Counter "X / Y XP" tampil di kanan atas
- [ ] Formula XP sederhana: `points % (level * 100)`

---

## TASK 6 — Activity Summary (BARU — belum ada)

Komponen baru berdasarkan riset GitHub activity summary dan Duolingo streak:

```dart
class _ActivitySummary extends StatelessWidget {
  final int completedMissions;
  final int photoCount;

  const _ActivitySummary({
    required this.completedMissions,
    required this.photoCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(icon: Icons.bar_chart_rounded, label: 'RINGKASAN'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActivityCard(
                icon: Icons.task_alt_rounded,
                iconColor: AppColors.forestGreen,
                count: completedMissions,
                label: 'Misi Selesai',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActivityCard(
                icon: Icons.photo_library_rounded,
                iconColor: AppColors.brandBlue,
                count: photoCount,
                label: 'Foto Diupload',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final int count;
  final String label;

  const _ActivityCard({
    required this.icon,
    required this.iconColor,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 2),
        boxShadow: const [
          BoxShadow(color: AppColors.cardBorder, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: iconColor,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

**DoD Task 6:**
- [ ] 2 activity card tampil dalam satu baris: "Misi Selesai" dan "Foto Diupload"
- [ ] Ikon berwarna di dalam rounded container berwarna muted
- [ ] Count tampil besar, label kecil di bawahnya
- [ ] Angka menggunakan data real dari ViewModel

---

## TASK 7 — Badge Section Redesign (4 kolom + label)

Ganti `_BadgeSection` dengan versi baru (4 kolom, ada label, ada counter, ada checkmark):

```dart
class _BadgeSection extends StatelessWidget {
  final List<BadgeModel> allBadges;
  final List<String> earnedBadgeIds;

  const _BadgeSection({required this.allBadges, required this.earnedBadgeIds});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.military_tech_rounded, size: 20, color: AppColors.brandBlue),
            const SizedBox(width: 8),
            Text(
              'LENCANA SAYA',
              style: AppTextStyles.title.copyWith(fontSize: 15, letterSpacing: 1.2),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.brandBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${earnedBadgeIds.length} / ${allBadges.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.brandBlue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder, width: 2),
            boxShadow: const [
              BoxShadow(color: AppColors.cardBorder, offset: Offset(0, 4)),
            ],
          ),
          child: allBadges.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Memuat badge...', style: TextStyle(color: AppColors.disabled)),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,           // 4 kolom — lebih besar dari 5
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,      // lebih tinggi untuk muat label
                  ),
                  itemCount: allBadges.length,
                  itemBuilder: (context, index) {
                    final badge = allBadges[index];
                    final isEarned = earnedBadgeIds.contains(badge.id);
                    return _BadgeItem(
                      badge: badge,
                      isEarned: isEarned,
                      onTap: isEarned ? () => _showBadgeDetail(context, badge) : null,
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showBadgeDetail(BuildContext context, BadgeModel badge) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _BadgeDetailSheet(badge: badge),
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final BadgeModel badge;
  final bool isEarned;
  final VoidCallback? onTap;

  const _BadgeItem({required this.badge, required this.isEarned, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(
                  badge.iconPath,
                  colorFilter: isEarned
                      ? null
                      : const ColorFilter.matrix(<double>[
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0,      0,      0,      0.35, 0,
                        ]),
                ),
                if (!isEarned)
                  Icon(
                    Icons.lock_rounded,
                    color: AppColors.surfaceWhite.withValues(alpha: 0.8),
                    size: 20,
                  ),
                if (isEarned)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppColors.forestGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, size: 10, color: AppColors.surfaceWhite),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            badge.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isEarned ? AppColors.bodyText : AppColors.disabled,
            ),
          ),
        ],
      ),
    );
  }
}
```

**DoD Task 7:**
- [ ] 4 kolom badge (tidak 5)
- [ ] Label nama badge di bawah setiap badge (truncated jika terlalu panjang)
- [ ] Counter "X / Y" tampil di header section
- [ ] Badge earned: checkmark hijau di sudut kanan atas
- [ ] Badge locked: grayscale + ikon lock
- [ ] Tap badge earned → bottom sheet detail

---

## TASK 8 — Photo Section (Network-Aware)

Ganti `_PhotoSection` dengan versi network-aware + counter foto:

```dart
class _PhotoSection extends StatelessWidget {
  final List<String> photoUrls;
  const _PhotoSection({required this.photoUrls});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.camera_alt_rounded, size: 20, color: AppColors.brandBlue),
            const SizedBox(width: 8),
            Text(
              'FOTO SAYA',
              style: AppTextStyles.title.copyWith(fontSize: 15, letterSpacing: 1.2),
            ),
            const Spacer(),
            if (photoUrls.isNotEmpty)
              Text(
                '${photoUrls.length} foto',
                style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          constraints: const BoxConstraints(minHeight: 120),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder, width: 2),
            boxShadow: const [
              BoxShadow(color: AppColors.cardBorder, offset: Offset(0, 4)),
            ],
          ),
          child: photoUrls.isEmpty
              ? _buildEmpty()
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: photoUrls.length,
                  itemBuilder: (context, index) {
                    final url = photoUrls[index];
                    final isNetwork = url.startsWith('http://') || url.startsWith('https://');
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: isNetwork
                          ? Image.network(
                              url,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  color: AppColors.backgroundGray,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.brandBlue,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.backgroundGray,
                                child: const Icon(
                                  Icons.broken_image_rounded,
                                  color: AppColors.disabled,
                                ),
                              ),
                            )
                          : Image.file(
                              File(url),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.backgroundGray,
                                child: const Icon(
                                  Icons.broken_image_rounded,
                                  color: AppColors.disabled,
                                ),
                              ),
                            ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        SizedBox(height: 16),
        Icon(Icons.camera_alt_outlined, size: 48, color: AppColors.disabled),
        SizedBox(height: 12),
        Text(
          'Belum ada foto. Mulai misi!',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.disabled, fontSize: 14),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
```

---

## TASK 9 — Helper Widget: _SectionHeader

Buat helper reusable yang dipakai oleh semua section:

```dart
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.brandBlue),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.title.copyWith(fontSize: 15, letterSpacing: 1.2),
        ),
      ],
    );
  }
}
```

---

## DEFINITION OF DONE — Full Sprint

### Bug Fix
- [ ] Foto Firebase Storage (https) tampil sebagai gambar nyata (bukan warna blok)
- [ ] Tidak ada crash saat foto gagal load

### Layout
- [ ] SliverAppBar hero brandBlue (expandedHeight: 220), pinned saat scroll
- [ ] Saat expanded: avatar + nama + email tampil di hero area
- [ ] Saat collapsed: hanya title "PROFIL" + logout icon
- [ ] Pull-to-refresh bekerja
- [ ] Tidak ada AppBar biasa, TabBar, atau duplikat entry point Progress

### Stat Cards
- [ ] Dua card (Poin & Level) responsif dengan Expanded, tidak hardcoded width
- [ ] Poin: animasi count-up, biru
- [ ] Level: gold, tanpa animasi

### XP Progress Bar (BARU)
- [ ] Progress bar gradient (biru → amber) dengan animasi fill
- [ ] Label level kiri dan level+1 kanan
- [ ] Counter "X / Y XP" di kanan atas card

### Activity Summary (BARU)
- [ ] 2 metric card: Misi Selesai dan Foto Diupload
- [ ] Data real dari ViewModel

### Badge
- [ ] 4 kolom (bukan 5)
- [ ] Label nama badge tiap item (truncated jika panjang)
- [ ] Counter "X / Y" di header section
- [ ] Checkmark hijau untuk earned, grayscale + lock untuk locked
- [ ] Tap → bottom sheet detail (dipertahankan dari versi lama)

### Foto
- [ ] Grid 3 kolom, network-aware
- [ ] Counter "X foto" di header section
- [ ] Empty state dengan icon dan teks motivasi

### General
- [ ] `flutter analyze` zero errors
- [ ] Semua warna dari AppColors (tidak ada hardcode hex)
- [ ] Semua text style dari AppTextStyles atau TextStyle dengan warna dari AppColors

---

## PR REQUIREMENTS

- **Branch:** `feature/profile-redesign`
- **Base:** `main` (atau `fix/color-consistency` jika sprint warna sudah di-merge)
- **Title:** `feat: profile UI redesign — hero SliverAppBar, XP progress bar, activity summary, network photo grid`
- **PR body mencakup:**
  - Research basis (Duolingo, Eleken, Proposal GFD)
  - Screenshot before & after
  - Daftar komponen baru yang ditambahkan
  - Notes: completedMissions menggunakan `earnedBadgeIds.length` sebagai fallback sampai VM diupdate
