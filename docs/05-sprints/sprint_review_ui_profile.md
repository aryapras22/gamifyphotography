# Sprint: Submission Review, Auth UI, Profile-Progress Merge, Photo Fix, Leaderboard Fix
**Branch:** `feature/sprint-review-ui-profile`
**Base:** `main`
**Repo:** https://github.com/aryapras22/gamifyphotography

---

## SETUP

```bash
git checkout main && git pull origin main
git checkout -b feature/sprint-review-ui-profile
```

---

## OVERVIEW TASK

| # | Task | File(s) |
|---|------|---------|
| T1 | Fix foto tidak load (Image.file → Image.network) | `challenge_view.dart`, `feedback_view.dart`, `profile_view.dart` |
| T2 | Fix leaderboard error (hapus mock, pakai Firestore) | `leaderboard_view_model.dart`, `leaderboard_view.dart` |
| T3 | Sistem review admin: state pending/accepted, tampilkan skor & komentar | `photo_submission_model.dart`, `submission_view.dart` (baru), `challenge_view_model.dart`, `module_detail_view.dart` |
| T4 | Improve UI autentikasi (login & register) | `login_view.dart`, `register_view.dart` |
| T5 | Gabung halaman profil & progress ke satu halaman dengan TabBar | `profile_view.dart`, `progress_view.dart` → `profile_progress_view.dart` (baru), router update |

---

## STRICT RULES

1. Jangan ubah nama route `/profile` dan `/progress` yang sudah ada di router — cukup arahkan keduanya ke widget baru yang sama.
2. `Image.file()` HANYA boleh dipakai untuk path lokal (tidak ada `http`/`https`). Untuk Firebase Storage URL wajib `Image.network()`.
3. Jangan ubah `AppColors`, `AppTextStyles`, atau file model `.freezed.dart` / `.g.dart`.
4. `PhotoSubmissionModel.status` sudah ada field: `pending`, tambahkan `accepted` dan `rejected` — jangan ubah field lain.
5. `flutter analyze` harus lulus zero errors setelah semua task.
6. Jangan ubah logika upload foto atau `ChallengeViewModel.uploadPhoto()`.

---

## T1 — Fix Foto Tidak Load (Image.file → smart loader)

### Root Cause
Setelah Firebase Auth di-merge, `uploadedPhotoUrl` dan `completedChallengePhotoUrls` sekarang berisi
HTTPS URL dari Firebase Storage. Tapi ketiga file masih memakai `Image.file(File(url))` atau
`File(url).existsSync()` yang selalu gagal untuk URL `https://`.

---

### T1-A: `lib/views/mission/challenge_view.dart`

**Tambahkan helper di bawah file (di luar class):**
```dart
bool _isNetworkUrl(String? url) =>
    url != null && (url.startsWith('http://') || url.startsWith('https://'));
```

**Ganti blok `if (hasPhoto)` yang menampilkan foto (baris ~118):**
```dart
if (hasPhoto)
  ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: _isNetworkUrl(challenge.uploadedPhotoUrl)
        ? Image.network(
            challenge.uploadedPhotoUrl!,
            height: 300,
            width: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return SizedBox(
                height: 300,
                child: Center(
                  child: CircularProgressIndicator(
                    value: progress.expectedTotalBytes != null
                        ? progress.cumulativeBytesLoaded /
                            progress.expectedTotalBytes!
                        : null,
                    color: AppColors.brandBlue,
                  ),
                ),
              );
            },
            errorBuilder: (_, __, ___) => _PhotoErrorPlaceholder(height: 300),
          )
        : Image.file(
            File(challenge.uploadedPhotoUrl!),
            height: 300,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _PhotoErrorPlaceholder(height: 300),
          ),
  )
```

**Tambahkan error placeholder widget di bawah file:**
```dart
class _PhotoErrorPlaceholder extends StatelessWidget {
  final double height;
  const _PhotoErrorPlaceholder({this.height = 300});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.backgroundGray,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.broken_image_rounded, size: 64, color: AppColors.disabled),
          const SizedBox(height: 12),
          Text('Gagal memuat foto',
              style: TextStyle(color: AppColors.secondaryText, fontSize: 14)),
        ],
      ),
    );
  }
}
```

**Tambahkan SnackBar listener di `build()` sebelum `return Scaffold`:**
```dart
ref.listen<ChallengeState>(challengeViewModelProvider, (prev, next) {
  if (next.errorMessage != null &&
      next.errorMessage != prev?.errorMessage &&
      mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(next.errorMessage!),
        backgroundColor: AppColors.coralRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
});
```

---

### T1-B: `lib/views/mission/feedback_view.dart`

**Ganti seluruh `_PhotoPreview` widget:**
```dart
class _PhotoPreview extends StatelessWidget {
  final String? photoUrl;
  const _PhotoPreview({this.photoUrl});

  bool get _isNetwork =>
      photoUrl != null &&
      (photoUrl!.startsWith('http://') || photoUrl!.startsWith('https://'));

  bool get _isLocalFile =>
      photoUrl != null &&
      photoUrl!.isNotEmpty &&
      !_isNetwork &&
      File(photoUrl!).existsSync();

  bool get _hasPhoto => _isNetwork || _isLocalFile;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: _hasPhoto
          ? (_isNetwork
              ? Image.network(
                  photoUrl!,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return SizedBox(
                      height: 220,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes!
                              : null,
                          color: AppColors.brandBlue,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => _buildEmpty(),
                )
              : Image.file(
                  File(photoUrl!),
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildEmpty(),
                ))
          : _buildEmpty(),
    );
  }

  Widget _buildEmpty() {
    return Container(
      height: 220,
      width: double.infinity,
      color: AppColors.backgroundGray,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt_outlined, size: 56, color: AppColors.disabled),
          const SizedBox(height: 8),
          Text('Tidak ada foto',
              style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
        ],
      ),
    );
  }
}
```

---

### T1-C: `lib/views/profile/profile_view.dart` — `_PhotoSection`

**Ganti `Image.file(...)` di dalam `GridView.builder` `itemBuilder`:**
```dart
itemBuilder: (context, index) {
  final url = photoUrls[index];
  final isNetwork =
      url.startsWith('http://') || url.startsWith('https://');
  return ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: isNetwork
        ? Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.backgroundGray,
              child: const Icon(Icons.broken_image_rounded,
                  color: AppColors.disabled),
            ),
          )
        : Image.file(
            File(url),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.backgroundGray,
              child: const Icon(Icons.broken_image_rounded,
                  color: AppColors.disabled),
            ),
          ),
  );
},
```

---

## T2 — Fix Leaderboard (Mock → Firestore)

### T2-A: Ganti seluruh `lib/view_models/leaderboard_view_model.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leaderboard_model.dart';

class LeaderboardState {
  final List<LeaderboardEntry> entries;
  final bool isLoading;
  final int currentUserRank;
  final String? errorMessage;

  const LeaderboardState({
    this.entries = const [],
    this.isLoading = true,
    this.currentUserRank = 0,
    this.errorMessage,
  });

  LeaderboardState copyWith({
    List<LeaderboardEntry>? entries,
    bool? isLoading,
    int? currentUserRank,
    String? errorMessage,
  }) =>
      LeaderboardState(
        entries: entries ?? this.entries,
        isLoading: isLoading ?? this.isLoading,
        currentUserRank: currentUserRank ?? this.currentUserRank,
        errorMessage: errorMessage,
      );
}

final leaderboardViewModelProvider =
    StateNotifierProvider<LeaderboardViewModel, LeaderboardState>(
        (ref) => LeaderboardViewModel());

class LeaderboardViewModel extends StateNotifier<LeaderboardState> {
  final _db = FirebaseFirestore.instance;

  LeaderboardViewModel() : super(const LeaderboardState());

  Future<void> loadLeaderboard(String currentUserId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final snapshot = await _db
          .collection('users')
          .orderBy('points', descending: true)
          .limit(50)
          .get();

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

      final myRank = ranked.indexWhere((e) => e.userId == currentUserId);

      state = state.copyWith(
        isLoading: false,
        entries: ranked,
        currentUserRank: myRank >= 0 ? myRank + 1 : 0,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat peringkat. Periksa koneksi internet.',
      );
    }
  }
}
```

### T2-B: `lib/views/leaderboard/leaderboard_view.dart`

**Hapus baris hardcode:**
```dart
// HAPUS baris ini:
const String _kFallbackUserId = 'user_1';
```

**Ganti `initState()`:**
```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final userId = ref.read(authViewModelProvider).currentUser?.id ?? '';
    if (userId.isEmpty) return;
    ref.read(leaderboardViewModelProvider.notifier).loadLeaderboard(userId);
  });
}
```

**Ganti referensi `_kFallbackUserId` di `build()`:**
```dart
final currentUserId = authUser?.id ?? '';
```

**Pindahkan `_buildError()` ke dalam state class dan tambahkan retry button:**
```dart
Widget _buildError(String message) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 56, color: AppColors.disabled),
          const SizedBox(height: 16),
          Text(message,
              style: const TextStyle(color: AppColors.secondaryText, fontSize: 14),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandBlue,
              foregroundColor: AppColors.surfaceWhite,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              final userId =
                  ref.read(authViewModelProvider).currentUser?.id ?? '';
              if (userId.isEmpty) return;
              ref
                  .read(leaderboardViewModelProvider.notifier)
                  .loadLeaderboard(userId);
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    ),
  );
}
```

**Tambahkan guard empty state di `_buildList()`:**
```dart
Widget _buildList(List<LeaderboardEntry> entries, String currentUserId) {
  if (entries.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.leaderboard_outlined, size: 56, color: AppColors.disabled),
          const SizedBox(height: 16),
          const Text('Belum ada pemain di papan peringkat.',
              style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
  // ListView.builder yang sudah ada, tidak berubah
  ...
}
```

---

## T3 — Sistem Review Admin: State Submission & Tampilan Skor/Komentar

### Latar Belakang Alur
```
User foto → upload ke Storage → simpan ke Firestore (status: "pending")
                                        ↓
                              Admin review di admin panel
                                        ↓
                    status: "accepted" (adminScore, adminNote)
                    status: "rejected" (adminNote)
                                        ↓
User buka modul → lihat status → jika accepted: tampil skor & komentar
                              → jika pending: tampil "Menunggu penilaian"
                              → jika rejected: tampil alasan & retry
```

**User tetap bisa lanjut ke modul lain** karena `isCompleted` di `module_model.dart` cukup ditandai
saat foto berhasil di-upload (bukan saat accepted). Review admin hanya memberikan feedback & skor,
bukan gate progress.

---

### T3-A: Update `lib/models/photo_submission_model.dart`

Tambahkan field `adminScore` (nullable int) di bawah `adminNote`:
```dart
@freezed
class PhotoSubmissionModel with _$PhotoSubmissionModel {
  factory PhotoSubmissionModel({
    required String id,
    required String userId,
    required String userName,
    required String moduleId,
    required String moduleTitle,
    required String photoUrl,
    @Default('pending') String status,   // 'pending' | 'accepted' | 'rejected'
    String? adminNote,
    int? adminScore,                      // 0-100, diisi admin saat accepted
    required DateTime submittedAt,
    DateTime? reviewedAt,
  }) = _PhotoSubmissionModel;

  factory PhotoSubmissionModel.fromJson(Map<String, dynamic> json) =>
      _$PhotoSubmissionModelFromJson(json);
}
```

Setelah mengubah model ini, jalankan:
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

### T3-B: Buat `lib/view_models/submission_view_model.dart`

File baru untuk mengelola pengambilan submission milik user:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/photo_submission_model.dart';

class SubmissionState {
  final Map<String, PhotoSubmissionModel> byModuleId; // key: moduleId
  final bool isLoading;
  final String? errorMessage;

  const SubmissionState({
    this.byModuleId = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  SubmissionState copyWith({
    Map<String, PhotoSubmissionModel>? byModuleId,
    bool? isLoading,
    String? errorMessage,
  }) =>
      SubmissionState(
        byModuleId: byModuleId ?? this.byModuleId,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,
      );
}

final submissionViewModelProvider =
    StateNotifierProvider<SubmissionViewModel, SubmissionState>(
        (ref) => SubmissionViewModel());

class SubmissionViewModel extends StateNotifier<SubmissionState> {
  final _db = FirebaseFirestore.instance;

  SubmissionViewModel() : super(const SubmissionState());

  Future<void> loadUserSubmissions(String userId) async {
    if (userId.isEmpty) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final snapshot = await _db
          .collection('photo_submissions')
          .where('userId', isEqualTo: userId)
          .orderBy('submittedAt', descending: true)
          .get();

      final map = <String, PhotoSubmissionModel>{};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        // Normalize Timestamp → ISO String
        if (data['submittedAt'] is Timestamp) {
          data['submittedAt'] =
              (data['submittedAt'] as Timestamp).toDate().toIso8601String();
        }
        if (data['reviewedAt'] is Timestamp) {
          data['reviewedAt'] =
              (data['reviewedAt'] as Timestamp).toDate().toIso8601String();
        }
        final model = PhotoSubmissionModel.fromJson(data);
        // Simpan hanya submission terbaru per modul
        if (!map.containsKey(model.moduleId)) {
          map[model.moduleId] = model;
        }
      }
      state = state.copyWith(isLoading: false, byModuleId: map);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat data submission.',
      );
    }
  }

  PhotoSubmissionModel? forModule(String moduleId) =>
      state.byModuleId[moduleId];
}
```

---

### T3-C: Buat `lib/views/mission/submission_status_view.dart`

Halaman yang ditampilkan setelah user tap modul yang sudah pernah difoto.
Menampilkan status: pending / accepted (skor+komentar) / rejected (komentar+retry).

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../models/photo_submission_model.dart';
import '../../view_models/submission_view_model.dart';
import '../../view_models/auth_view_model.dart';
import '../widgets/animated_3d_button.dart';

class SubmissionStatusView extends ConsumerStatefulWidget {
  final String moduleId;
  final String moduleTitle;

  const SubmissionStatusView({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
  });

  @override
  ConsumerState<SubmissionStatusView> createState() =>
      _SubmissionStatusViewState();
}

class _SubmissionStatusViewState extends ConsumerState<SubmissionStatusView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId =
          ref.read(authViewModelProvider).currentUser?.id ?? '';
      ref
          .read(submissionViewModelProvider.notifier)
          .loadUserSubmissions(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(submissionViewModelProvider);
    final submission = state.forModule(widget.moduleId);

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0,
        title: Text(widget.moduleTitle, style: AppTextStyles.heading),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.bodyText),
          onPressed: () => context.pop(),
        ),
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.brandBlue))
          : submission == null
              ? _buildNoSubmission()
              : _buildStatusCard(submission),
    );
  }

  Widget _buildNoSubmission() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt_outlined,
              size: 64, color: AppColors.disabled),
          const SizedBox(height: 16),
          Text('Belum ada foto untuk modul ini.',
              style: AppTextStyles.body
                  .copyWith(color: AppColors.secondaryText)),
          const SizedBox(height: 24),
          Animated3DButton(
            color: AppColors.brandBlue,
            shadowColor: const Color(0xFF1590C8),
            onPressed: () => context.pop(),
            child: Text('Ambil Foto', style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(PhotoSubmissionModel submission) {
    final status = submission.status;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Foto submission
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              submission.photoUrl,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 220,
                color: AppColors.backgroundGray,
                child: const Icon(Icons.broken_image_rounded,
                    size: 56, color: AppColors.disabled),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Status banner
          _StatusBanner(status: status),
          const SizedBox(height: 24),

          // Skor (hanya jika accepted)
          if (status == 'accepted' && submission.adminScore != null)
            _ScoreCard(score: submission.adminScore!),

          // Komentar admin
          if (submission.adminNote != null && submission.adminNote!.isNotEmpty)
            _AdminNoteCard(
                note: submission.adminNote!, isRejected: status == 'rejected'),

          const SizedBox(height: 32),

          // Tombol aksi
          if (status == 'rejected')
            Animated3DButton(
              color: AppColors.brandBlue,
              shadowColor: const Color(0xFF1590C8),
              onPressed: () {
                // Kembali ke challenge view untuk foto ulang
                context.pop();
              },
              child: Text('Foto Ulang', style: AppTextStyles.button),
            ),
          if (status != 'rejected')
            Animated3DButton(
              color: AppColors.forestGreen,
              shadowColor: const Color(0xFF2D8A00),
              onPressed: () => context.go('/home'),
              child: Text('Ke Beranda', style: AppTextStyles.button),
            ),

          const SizedBox(height: 12),
          Text(
            'Dikirim: ${_formatDate(submission.submittedAt)}',
            style: AppTextStyles.caption
                .copyWith(color: AppColors.secondaryText),
            textAlign: TextAlign.center,
          ),
          if (submission.reviewedAt != null)
            Text(
              'Dinilai: ${_formatDate(submission.reviewedAt!)}',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.secondaryText),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  final String status;
  const _StatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    final config = switch (status) {
      'accepted' => (
          icon: Icons.check_circle_rounded,
          color: AppColors.forestGreen,
          label: 'FOTO DISETUJUI ✅',
          sub: 'Admin sudah menilai fotomu.',
        ),
      'rejected' => (
          icon: Icons.cancel_rounded,
          color: AppColors.coralRed,
          label: 'FOTO DITOLAK',
          sub: 'Silakan ambil foto ulang.',
        ),
      _ => (
          icon: Icons.hourglass_top_rounded,
          color: AppColors.lensGold,
          label: 'MENUNGGU PENILAIAN ⏳',
          sub: 'Admin sedang memeriksa fotomu. Kamu tetap bisa lanjut ke misi lain.',
        ),
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.color, width: 2),
      ),
      child: Row(
        children: [
          Icon(config.icon, color: config.color, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(config.label,
                    style: AppTextStyles.title
                        .copyWith(color: config.color)),
                const SizedBox(height: 4),
                Text(config.sub,
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.secondaryText)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final int score;
  const _ScoreCard({required this.score});

  Color get _scoreColor {
    if (score >= 80) return AppColors.forestGreen;
    if (score >= 60) return AppColors.lensGold;
    return AppColors.coralRed;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 2),
        boxShadow: const [
          BoxShadow(color: AppColors.cardBorder, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.lensGold, size: 32),
          const SizedBox(width: 12),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: score),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => Text(
              '$value / 100',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: _scoreColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminNoteCard extends StatelessWidget {
  final String note;
  final bool isRejected;
  const _AdminNoteCard({required this.note, required this.isRejected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.comment_rounded,
                size: 18,
                color: isRejected ? AppColors.coralRed : AppColors.brandBlue,
              ),
              const SizedBox(width: 8),
              Text('Komentar Admin',
                  style: AppTextStyles.title.copyWith(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Text(note,
              style: AppTextStyles.body
                  .copyWith(color: AppColors.secondaryText)),
        ],
      ),
    );
  }
}
```

---

### T3-D: Update `lib/views/mission/module_detail_view.dart` — Tombol aksi

Pada `module_detail_view.dart`, saat modul sudah `isCompleted`, tombol "Mulai Misi" harus berubah
menjadi "Lihat Status Foto" dan navigate ke `SubmissionStatusView`.

Cari tombol aksi di bawah `module_detail_view.dart` (biasanya bagian `Animated3DButton` atau
`ElevatedButton` yang navigate ke `/mission/challenge`) dan tambahkan kondisi:

```dart
// Tambahkan import di atas file:
import 'package:go_router/go_router.dart';
import '../../view_models/submission_view_model.dart';
import '../../view_models/auth_view_model.dart';

// Di dalam build method, setelah mendapat module:
final isCompleted = module.isCompleted; // atau kondisi yang sudah ada

// Ganti tombol:
Animated3DButton(
  color: isCompleted ? AppColors.secondaryText.withValues(alpha: 0.5) : AppColors.brandBlue,
  shadowColor: isCompleted
      ? const Color(0xFFC4C4C4)
      : const Color(0xFF1590C8),
  onPressed: () {
    if (isCompleted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SubmissionStatusView(
            moduleId: module.id,
            moduleTitle: module.title,
          ),
        ),
      );
    } else {
      context.push('/mission/challenge');
    }
  },
  child: Text(
    isCompleted ? 'LIHAT STATUS FOTO →' : 'MULAI MISI →',
    style: AppTextStyles.button,
  ),
),
```

---

## T4 — Improve UI Autentikasi

### T4-A: `lib/views/auth/login_view.dart` — Desain ulang

Ganti seluruh isi file dengan versi improved berikut:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/validators.dart';
import '../../view_models/auth_view_model.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});
  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authViewModelProvider.notifier)
        .login(_emailCtrl.text.trim(), _passCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authViewModelProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundGray,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ── Hero Header ──────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(32, 56, 32, 40),
                  decoration: const BoxDecoration(
                    color: AppColors.brandBlue,
                    borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(36)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.camera_alt_rounded,
                          size: 48, color: AppColors.surfaceWhite),
                      const SizedBox(height: 16),
                      Text(
                        'GamifyPhoto',
                        style: AppTextStyles.display.copyWith(
                          color: AppColors.surfaceWhite,
                          fontSize: 32,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Masuk dan lanjutkan belajar fotografi',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.surfaceWhite
                              .withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Form Card ───────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: AppColors.cardBorder, width: 2),
                      boxShadow: const [
                        BoxShadow(
                            color: AppColors.cardBorder,
                            offset: Offset(0, 6)),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Login',
                              style: AppTextStyles.heading),
                          const SizedBox(height: 24),

                          // Email field
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: const Icon(
                                  Icons.email_outlined,
                                  color: AppColors.brandBlue),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                    color: AppColors.brandBlue, width: 2),
                              ),
                            ),
                            validator: Validators.email,
                          ),
                          const SizedBox(height: 16),

                          // Password field
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                  color: AppColors.brandBlue),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppColors.secondaryText,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                    color: AppColors.brandBlue, width: 2),
                              ),
                            ),
                            validator: Validators.password,
                          ),

                          // Error message
                          if (state.errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.coralRed
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: AppColors.coralRed
                                        .withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: AppColors.coralRed,
                                      size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      state.errorMessage!,
                                      style: AppTextStyles.body.copyWith(
                                          color: AppColors.coralRed,
                                          fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Login button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: state.isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.brandBlue,
                                foregroundColor: AppColors.surfaceWhite,
                                disabledBackgroundColor:
                                    AppColors.brandBlue.withValues(alpha: 0.5),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                              child: state.isLoading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                          color: AppColors.surfaceWhite,
                                          strokeWidth: 2.5),
                                    )
                                  : Text('MASUK',
                                      style: AppTextStyles.button),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Footer ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: TextButton(
                    onPressed: () => context.push('/register'),
                    child: RichText(
                      text: TextSpan(
                        text: 'Belum punya akun? ',
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.secondaryText),
                        children: [
                          TextSpan(
                            text: 'Daftar',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.brandBlue,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

### T4-B: `lib/views/auth/register_view.dart` — Desain ulang

Ganti seluruh isi file — struktur sama dengan login (hero header biru, form card putih),
tapi judul "Daftar Akun Baru" dan field lengkap (name, email, password, confirm password):

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../core/validators.dart';
import '../../view_models/auth_view_model.dart';

class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});
  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authViewModelProvider.notifier).register(
          _nameCtrl.text.trim(),
          _emailCtrl.text.trim(),
          _passCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authViewModelProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundGray,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ── Hero Header ──────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(32, 48, 32, 36),
                  decoration: const BoxDecoration(
                    color: AppColors.brandBlue,
                    borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(36)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: AppColors.surfaceWhite, size: 28),
                      ),
                      const SizedBox(height: 20),
                      const Icon(Icons.camera_alt_rounded,
                          size: 44, color: AppColors.surfaceWhite),
                      const SizedBox(height: 12),
                      Text(
                        'Daftar Akun Baru',
                        style: AppTextStyles.display.copyWith(
                          color: AppColors.surfaceWhite,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Bergabung dan mulai perjalanan fotografi',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.surfaceWhite
                              .withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Form Card ───────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: AppColors.cardBorder, width: 2),
                      boxShadow: const [
                        BoxShadow(
                            color: AppColors.cardBorder,
                            offset: Offset(0, 6)),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Isi Data Diri',
                              style: AppTextStyles.heading),
                          const SizedBox(height: 20),

                          _buildField(
                            controller: _nameCtrl,
                            label: 'Nama Lengkap',
                            icon: Icons.person_outline_rounded,
                            keyboardType: TextInputType.name,
                            validator: Validators.name,
                          ),
                          const SizedBox(height: 14),
                          _buildField(
                            controller: _emailCtrl,
                            label: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.email,
                          ),
                          const SizedBox(height: 14),
                          _buildField(
                            controller: _passCtrl,
                            label: 'Password',
                            icon: Icons.lock_outline_rounded,
                            obscure: _obscurePass,
                            onToggleObscure: () =>
                                setState(() => _obscurePass = !_obscurePass),
                            validator: Validators.password,
                          ),
                          const SizedBox(height: 14),
                          _buildField(
                            controller: _confirmPassCtrl,
                            label: 'Konfirmasi Password',
                            icon: Icons.lock_outline_rounded,
                            obscure: _obscureConfirm,
                            onToggleObscure: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
                            validator: (v) =>
                                Validators.confirmPassword(v, _passCtrl.text),
                          ),

                          if (state.errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.coralRed
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: AppColors.coralRed
                                        .withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: AppColors.coralRed, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      state.errorMessage!,
                                      style: AppTextStyles.body.copyWith(
                                          color: AppColors.coralRed,
                                          fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: state.isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.brandBlue,
                                foregroundColor: AppColors.surfaceWhite,
                                disabledBackgroundColor:
                                    AppColors.brandBlue.withValues(alpha: 0.5),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                              child: state.isLoading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                          color: AppColors.surfaceWhite,
                                          strokeWidth: 2.5),
                                    )
                                  : Text('DAFTAR',
                                      style: AppTextStyles.button),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: TextButton(
                    onPressed: () => context.pop(),
                    child: RichText(
                      text: TextSpan(
                        text: 'Sudah punya akun? ',
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.secondaryText),
                        children: [
                          TextSpan(
                            text: 'Masuk',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.brandBlue,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool? obscure,
    VoidCallback? onToggleObscure,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure ?? false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.brandBlue),
        suffixIcon: obscure != null
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.secondaryText,
                ),
                onPressed: onToggleObscure,
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.brandBlue, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}
```

---

## T5 — Gabungkan Profil & Progress ke Satu Halaman (TabBar)

### T5-A: Buat `lib/views/profile/profile_progress_view.dart`

File baru ini menggabungkan konten `ProfileView` dan `ProgressView` dalam satu
`DefaultTabController` dengan 2 tab: **Profil** dan **Progress**.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../view_models/profile_view_model.dart';
import '../../view_models/auth_view_model.dart';
// Re-import konten internal dari file lama — tidak copy-paste, cukup impor widget
// yang sudah ada. Lihat catatan di bawah.

class ProfileProgressView extends ConsumerStatefulWidget {
  const ProfileProgressView({super.key});

  @override
  ConsumerState<ProfileProgressView> createState() =>
      _ProfileProgressViewState();
}

class _ProfileProgressViewState extends ConsumerState<ProfileProgressView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileViewModelProvider.notifier).loadProfile();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authViewModelProvider).currentUser;

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            pinned: true,
            floating: false,
            expandedHeight: 180,
            backgroundColor: AppColors.surfaceWhite,
            elevation: 0,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded,
                    color: AppColors.secondaryText),
                onPressed: () {
                  ref.read(authViewModelProvider.notifier).logout();
                  context.go('/login');
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  color: AppColors.brandBlue,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(0)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 56, 24, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor:
                              AppColors.surfaceWhite.withValues(alpha: 0.3),
                          child: Text(
                            _getInitials(authUser?.name ?? ''),
                            style: AppTextStyles.heading.copyWith(
                                color: AppColors.surfaceWhite),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authUser?.name ?? '-',
                                style: AppTextStyles.title.copyWith(
                                    color: AppColors.surfaceWhite),
                              ),
                              Text(
                                authUser?.email ?? '',
                                style: AppTextStyles.caption.copyWith(
                                    color: AppColors.surfaceWhite
                                        .withValues(alpha: 0.75)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.brandBlue,
              indicatorWeight: 3,
              labelColor: AppColors.brandBlue,
              unselectedLabelColor: AppColors.secondaryText,
              labelStyle: AppTextStyles.title
                  .copyWith(fontSize: 14),
              tabs: const [
                Tab(icon: Icon(Icons.person_rounded), text: 'Profil'),
                Tab(icon: Icon(Icons.bar_chart_rounded), text: 'Progress'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: const [
            _ProfileTab(),
            _ProgressTab(),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.isEmpty ? '?' : parts[0][0].toUpperCase();
  }
}
```

**Catatan penting — `_ProfileTab` dan `_ProgressTab`:**

Alih-alih menduplikasi kode, ekstrak body content dari `profile_view.dart` dan `progress_view.dart`
menjadi widget yang bisa dipakai ulang:

- Dari `profile_view.dart`: Pindahkan `_ProfileHeader`, `_BadgeSection`, `_PhotoSection` (setelah fix T1-C) ke dalam `_ProfileTab` sebagai `ListView`.
- Dari `progress_view.dart`: Wrap body content utama menjadi `_ProgressTab` sebagai widget `ListView` atau `SingleChildScrollView`.

Kedua tab ini tetap menggunakan ViewModel mereka masing-masing:
- `_ProfileTab` → `profileViewModelProvider`
- `_ProgressTab` → `progressViewModelProvider` (atau nama yang ada di progress_view.dart)

---

### T5-B: Update Router

**File:** `lib/core/router.dart` (atau file router yang dipakai)

Temukan route `/profile` dan `/progress`. Arahkan keduanya ke `ProfileProgressView`:

```dart
// Sebelum:
GoRoute(path: '/profile', builder: (_, __) => const ProfileView()),
GoRoute(path: '/progress', builder: (_, __) => const ProgressView()),

// Sesudah:
GoRoute(path: '/profile', builder: (_, __) => const ProfileProgressView()),
GoRoute(path: '/progress', builder: (_, __) => const ProfileProgressView()),
```

> Kedua route `/profile` dan `/progress` tetap berfungsi — tapi keduanya membuka halaman yang sama
> (`ProfileProgressView`). Ini memastikan navigasi dari BottomNavBar dan `context.go('/profile')`
> maupun `context.go('/progress')` tetap bekerja tanpa ubah nama route.

---

## FIRESTORE SCHEMA REQUIREMENTS

### Collection: `photo_submissions`

```
photo_submissions/{submissionId}
  userId:       string   (required)
  userName:     string   (required)
  moduleId:     string   (required)
  moduleTitle:  string   (required)
  photoUrl:     string   (HTTPS URL dari Firebase Storage)
  status:       string   'pending' | 'accepted' | 'rejected'
  adminNote:    string?  (diisi admin)
  adminScore:   number?  0–100 (diisi admin hanya jika accepted)
  submittedAt:  Timestamp
  reviewedAt:   Timestamp?
```

### Collection: `users`

```
users/{userId}
  name:    string
  email:   string
  points:  number
  level:   number
  role:    string  'user' | 'admin'
```

---

## DEFINITION OF DONE

### T1 — Foto Load
- [ ] Foto yang diambil tampil di `ChallengeView` menggunakan `Image.network()` untuk HTTPS URL
- [ ] Foto tampil di `FeedbackView` setelah misi selesai
- [ ] Foto tampil di grid "FOTO SAYA" di halaman Profil
- [ ] Jika gagal load, tampil placeholder "Gagal memuat foto" bukan crash
- [ ] SnackBar merah tampil jika upload gagal

### T2 — Leaderboard
- [ ] Tidak ada `user_1` hardcode di mana pun
- [ ] Data leaderboard diambil dari Firestore `/users` collection
- [ ] Rank chip AppBar menampilkan rank user yang login
- [ ] Error state tampilkan "Coba Lagi" button
- [ ] Empty state tampil jika tidak ada data

### T3 — Submission Review
- [ ] Setelah foto di-upload, status "Menunggu penilaian" tampil di `SubmissionStatusView`
- [ ] User bisa kembali ke home dan lanjut ke modul lain (progress tidak terblokir)
- [ ] Saat admin set `status: 'accepted'`, user buka modul → tampil skor animasi + komentar admin
- [ ] Saat admin set `status: 'rejected'`, tampil komentar + tombol "Foto Ulang"
- [ ] Tombol di `module_detail_view` berubah menjadi "LIHAT STATUS FOTO" untuk modul yang sudah selesai
- [ ] `dart run build_runner build` berhasil setelah update model

### T4 — UI Autentikasi
- [ ] LoginView memiliki hero header biru dengan branding GamifyPhoto
- [ ] RegisterView memiliki hero header biru dan field dalam card putih
- [ ] Error message tampil dengan border merah + icon (bukan text plain)
- [ ] Loading state tombol menggunakan spinner, bukan disabled tanpa feedback
- [ ] Teks navigasi ("Belum punya akun?") menggunakan bahasa Indonesia

### T5 — Profile + Progress Merge
- [ ] Route `/profile` dan `/progress` keduanya membuka `ProfileProgressView`
- [ ] Tab "Profil" menampilkan avatar, poin, level, badge, foto
- [ ] Tab "Progress" menampilkan konten dari ProgressView sebelumnya
- [ ] Header expandable menampilkan nama dan email user yang login
- [ ] Tombol logout tersedia di AppBar

### General
- [ ] `flutter analyze` zero errors
- [ ] Tidak ada `.freezed.dart` atau `.g.dart` yang diubah manual

---

## PR REQUIREMENTS

- **Branch:** `feature/sprint-review-ui-profile`
- **Base:** `main`
- **Title:** `feat: submission review status, improved auth UI, merged profile+progress, photo network fix`
- **PR body:** checklist DoD di atas + note schema Firestore yang dibutuhkan
