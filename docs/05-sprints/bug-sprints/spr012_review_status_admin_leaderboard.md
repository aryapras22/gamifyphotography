# SPR-012 — Mission "In Review" UX Indicator & Admin Leaderboard Exclusion
## Branch: `feat/review-status-ux-and-admin-leaderboard`

**Repo:** https://github.com/aryapras22/gamifyphotography
**Base branch:** `main`

```bash
git checkout main && git pull origin main
git checkout -b feat/review-status-ux-and-admin-leaderboard
```

Run `flutter analyze` after every task. Zero new warnings before committing.

---

## Context & Root Cause Analysis

### Feature 1 — "In Review" indicator di Home

**Problem:** Node misi di `home_view.dart` hanya mengenal 2 state visual:
- 🔵 Biru (`brandBlue`) → misi belum selesai
- 🟡 Emas (`lensGold`) → misi selesai (`isCompleted == true`)

State **"sudah submit foto, menunggu penilaian admin"** (`status == 'pending'`) tidak memiliki representasi visual sama sekali. User tidak tahu apakah misinya sedang ditinjau, atau belum ia kerjakan.

**Root cause di kode:**
- `BouncingNode` di `home_view.dart` menggunakan `module.isCompleted` saja untuk menentukan warna.
- `submissionStatusProvider` sudah ada di `submission_providers.dart` — **tinggal dipakai** di home.
- Node path painter (`PathPainter`) juga hanya tahu `isCompleted`.

### Feature 2 — Admin tidak masuk Papan Peringkat

**Problem:** `LeaderboardViewModel.loadLeaderboard()` mengambil **semua dokumen** dari koleksi `users` tanpa memfilter `role`. Akun admin (`role == 'admin'`) ikut muncul dan bisa menduduki posisi teratas secara tidak fair.

**Root cause di kode** (`leaderboard_view_model.dart`, baris 34–47):
```dart
final snapshot = await _db
    .collection('users')
    .orderBy('points', descending: true)
    .limit(50)
    .get();
// ❌ Tidak ada filter role — admin masuk ranking
```

`UserModel` **sudah memiliki field `role`** (default `'user'`). Cukup tambahkan `.where('role', isEqualTo: 'user')` pada query Firestore.

---

## Scope

| # | File | Yang Berubah |
|---|---|---|
| A | `lib/views/home/home_view.dart` | Tampilkan badge ⏳ "In Review" pada node misi |
| B | `lib/view_models/leaderboard_view_model.dart` | Filter `role == 'admin'` dari query Firestore |

**Do NOT modify:** `main.dart`, semua `*.freezed.dart`, `*.g.dart`, semua model, semua service, `app_colors.dart`, `submission_providers.dart`.

---

## TASK A — `home_view.dart` · In-Review State pada Mission Node

### A1. Konsep Visual

Tambahkan state ketiga pada node misi:

| State | Kondisi | Warna Node | Warna Shadow | Ikon/Badge |
|---|---|---|---|---|
| **Belum dikerjakan** | `!isCompleted && !isPending` | `brandBlue` | `0xFF1590C8` | nomor misi |
| **⏳ In Review** | `isPending == true` | `lensGold` dengan opacity 80% | `0xFFD6A600` | `⏳` (hourglass emoji) di tengah node, bukan nomor |
| **✅ Selesai** | `isCompleted == true` | `lensGold` penuh | `0xFFD6A600` | `✓` checkmark icon |

**Tambahan:** jika node sedang `isPending`, tampilkan label teks kecil di bawah node:
```
⏳ Sedang Ditinjau
```
dengan style `caption`, warna `lensGold`.

### A2. Cara mengambil data submission status di home

`submissionStatusProvider` adalah `StreamProvider.family<PhotoSubmissionModel?, String>`.
Di `_HomeViewState.build()`, untuk setiap modul kamu perlu watch provider-nya dengan `moduleId`.
**Penting:** jangan watch di dalam `SliverChildBuilderDelegate` — ekstrak ke widget terpisah agar rebuild minimal.

Buat widget baru `_MissionNode` sebagai `ConsumerWidget`:

```dart
class _MissionNode extends ConsumerWidget {
  final dynamic module;       // ModuleModel
  final int index;
  final int totalModules;
  final double currentOffset;
  final double prevOffset;
  final double nextOffset;
  final double screenWidth;
  final VoidCallback onTap;

  const _MissionNode({
    required this.module,
    required this.index,
    required this.totalModules,
    required this.currentOffset,
    required this.prevOffset,
    required this.nextOffset,
    required this.screenWidth,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch submission status untuk modul ini saja
    final submissionAsync = ref.watch(submissionStatusProvider(module.id));
    final submissionStatus = submissionAsync.valueOrNull?.status;
    final isPending = submissionStatus == 'pending' && !module.isCompleted;

    // Tentukan visual berdasarkan state
    final Color nodeColor;
    final Color shadowColor;
    final Widget nodeChild;

    if (module.isCompleted) {
      nodeColor = AppColors.lensGold;
      shadowColor = const Color(0xFFD6A600);
      nodeChild = const Icon(Icons.check_rounded, color: Colors.white, size: 32);
    } else if (isPending) {
      nodeColor = AppColors.lensGold.withOpacity(0.8);
      shadowColor = const Color(0xFFD6A600);
      nodeChild = const Text('⏳', style: TextStyle(fontSize: 28));
    } else {
      nodeColor = AppColors.brandBlue;
      shadowColor = const Color(0xFF1590C8);
      nodeChild = Text(
        '${index + 1}',
        style: AppTextStyles.display.copyWith(
          color: AppColors.surfaceWhite,
          fontSize: 28,
        ),
      );
    }

    final isPulsing = !module.isCompleted &&
        !isPending &&
        (index == 0 ||
            (index > 0));
    // Pulsing hanya untuk node aktif yang belum dikerjakan — tetap gunakan
    // logika lama: node pertama yang belum selesai.

    return SizedBox(
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Path painter tetap sama
          Positioned.fill(
            child: CustomPaint(
              painter: PathPainter(
                currentOffset: currentOffset,
                prevOffset: prevOffset,
                nextOffset: nextOffset,
                isFirst: index == 0,
                isLast: index == totalModules - 1,
                isCompleted: module.isCompleted || isPending,
              ),
            ),
          ),

          Positioned(
            left: (screenWidth / 2) - 40 + currentOffset,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BouncingNode(
                  isPulsing: isPulsing,
                  onTap: onTap,
                  child: Container(
                    width: 80,
                    height: 80,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: nodeColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: shadowColor,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: nodeChild,
                  ),
                ),

                // Label "Sedang Ditinjau" di bawah node
                if (isPending) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.lensGold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.lensGold.withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      '⏳ Ditinjau',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.lensGold,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### A3. Ganti SliverList di `_HomeViewState.build()`

Temukan blok `SliverList` yang menggunakan `SliverChildBuilderDelegate` dan **ganti seluruh itemBuilder lambda** untuk memanggil `_MissionNode`:

```dart
SliverList(
  delegate: SliverChildBuilderDelegate(
    (context, index) {
      final module = missionState.modules[index];
      final screenWidth = MediaQuery.of(context).size.width;

      double currentOffset = _getOffset(index, screenWidth);
      double prevOffset = index > 0
          ? _getOffset(index - 1, screenWidth)
          : currentOffset;
      double nextOffset = index < missionState.modules.length - 1
          ? _getOffset(index + 1, screenWidth)
          : currentOffset;

      return _MissionNode(
        module: module,
        index: index,
        totalModules: missionState.modules.length,
        currentOffset: currentOffset,
        prevOffset: prevOffset,
        nextOffset: nextOffset,
        screenWidth: screenWidth,
        onTap: () => _showMissionBottomSheet(context, module),
      );
    },
    childCount: missionState.modules.length,
  ),
),
```

### A4. Tambahkan import `submission_providers.dart`

Di bagian atas `home_view.dart`, tambahkan:

```dart
import '../../providers/submission_providers.dart';
```

### A5. Update `PathPainter` — warna path "in review"

`PathPainter` saat ini hanya punya 2 warna: emas (completed) atau abu (incomplete). Tambahkan parameter `isPending` agar path berwarna emas pudar ketika status pending:

Temukan class `PathPainter` dan tambahkan field:

```dart
final bool isPending;

PathPainter({
  required this.currentOffset,
  required this.prevOffset,
  required this.nextOffset,
  required this.isFirst,
  required this.isLast,
  required this.isCompleted,
  this.isPending = false,   // ← tambahkan ini
});
```

Di method `paint`, ubah baris pemilihan warna:

```dart
// SEBELUM:
..color = isCompleted ? AppColors.lensGold : AppColors.cardBorder

// SESUDAH:
..color = isCompleted
    ? AppColors.lensGold
    : isPending
        ? AppColors.lensGold.withOpacity(0.4)
        : AppColors.cardBorder
```

Di `shouldRepaint`, tambahkan:

```dart
return oldDelegate.isCompleted != isCompleted ||
       oldDelegate.isPending != isPending ||
       oldDelegate.currentOffset != currentOffset;
```

Di `_MissionNode.build()`, update panggilan `PathPainter`:

```dart
painter: PathPainter(
  currentOffset: currentOffset,
  prevOffset: prevOffset,
  nextOffset: nextOffset,
  isFirst: index == 0,
  isLast: index == totalModules - 1,
  isCompleted: module.isCompleted,
  isPending: isPending,   // ← tambahkan ini
),
```

---

## TASK B — `leaderboard_view_model.dart` · Filter Admin dari Ranking

### B1. Ubah query Firestore di `loadLeaderboard`

Temukan blok:

```dart
final snapshot = await _db
    .collection('users')
    .orderBy('points', descending: true)
    .limit(50)
    .get();
```

**Ganti dengan:**

```dart
// Filter role != 'admin' menggunakan whereNotEqualTo.
// Firestore tidak mendukung != secara langsung bersama orderBy field lain,
// jadi kita filter di sisi client setelah query — lebih aman dan tetap
// konsisten dengan Firestore security rules yang sudah ada.
final snapshot = await _db
    .collection('users')
    .orderBy('points', descending: true)
    .limit(100)   // ambil lebih banyak agar setelah filter admin tetap ada cukup data
    .get();
```

Ubah loop pembuatan `ranked` untuk menyaring admin:

```dart
// SEBELUM:
final ranked = <LeaderboardEntry>[];
for (var i = 0; i < snapshot.docs.length; i++) {
  final doc = snapshot.docs[i];
  final data = doc.data();
  ranked.add(LeaderboardEntry(
    userId: doc.id,
    userName: (data['name'] as String?) ?? 'Unknown',
    points: (data['points'] as int?) ?? 0,
    rank: i + 1,
  ));
}

// SESUDAH:
final ranked = <LeaderboardEntry>[];
int rankCounter = 1;
for (final doc in snapshot.docs) {
  final data = doc.data();
  final role = (data['role'] as String?) ?? 'user';

  // ── Admin Exclusion (SPR-012) ─────────────────────────────────────────
  // Admin tidak masuk papan peringkat. Mereka menilai foto user —
  // memasukkan admin ke ranking akan distorsi kompetisi.
  // Field 'role' ada di UserModel dengan default 'user'.
  // ─────────────────────────────────────────────────────────────────────
  if (role == 'admin') continue;

  ranked.add(LeaderboardEntry(
    userId: doc.id,
    userName: (data['name'] as String?) ?? 'Unknown',
    points: (data['points'] as int?) ?? 0,
    rank: rankCounter,
  ));
  rankCounter++;

  if (rankCounter > 50) break; // batasi tampilan 50 user non-admin
}
```

---

## Verification Checklist

Run `flutter analyze` — zero new issues.

**Feature 1 — In Review indicator:**
- [ ] Node misi yang sudah disubmit tapi belum dinilai → tampil warna emas pudar + ikon ⏳
- [ ] Label "⏳ Ditinjau" muncul di bawah node tersebut
- [ ] Node yang belum dikerjakan sama sekali → tetap biru dengan nomor
- [ ] Node yang sudah approved dan selesai → emas penuh dengan ✓
- [ ] Perubahan state real-time (submit foto → node langsung berubah warna tanpa refresh)
- [ ] Hot restart bersih, tidak ada exception dari `ConsumerWidget` baru

**Feature 2 — Admin exclusion:**
- [ ] Login sebagai akun `role: 'admin'` → nama admin tidak muncul di leaderboard
- [ ] Ranking user biasa tidak berubah urutan setelah admin dikeluarkan
- [ ] Chip "Kamu: #X" di AppBar tidak muncul jika yang login adalah admin (rank akan 0)
- [ ] Leaderboard kosong tetap menampilkan empty state yang benar

---

## Files Changed

| File | Perubahan Utama |
|---|---|
| `lib/views/home/home_view.dart` | Ekstrak `_MissionNode` sbg `ConsumerWidget`; watch `submissionStatusProvider`; visual 3 state pada node; label "⏳ Ditinjau"; update `PathPainter` dengan parameter `isPending` |
| `lib/view_models/leaderboard_view_model.dart` | Filter `role == 'admin'` di loop; naikkan limit ke 100; `rankCounter` terpisah dari index |

---

## PR

**Title:** `feat(SPR-012): mission in-review UX indicator & admin leaderboard exclusion`

**Body:**
```
## Summary

### Feature 1 — In Review UX
Mission node di halaman Home kini menampilkan 3 state visual yang jelas:
- 🔵 Biru: misi belum dikerjakan
- 🟡 Emas pudar + ⏳: foto sudah disubmit, sedang ditinjau admin
- 🟡 Emas penuh + ✓: misi selesai dan diapprove

Implementasi: ekstrak _MissionNode sebagai ConsumerWidget yang watch
submissionStatusProvider(module.id) secara independen per node.

### Feature 2 — Admin Leaderboard Exclusion
Akun dengan role == 'admin' tidak lagi muncul di papan peringkat.
Filter dilakukan di sisi client setelah query Firestore (client-side filter
lebih aman karena kompatibel dengan security rules yang ada).

## Files Changed
- lib/views/home/home_view.dart
- lib/view_models/leaderboard_view_model.dart

Closes SPR-012
```
