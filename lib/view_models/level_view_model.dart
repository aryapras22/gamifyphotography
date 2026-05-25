// lib/view_models/level_view_model.dart
// TASK-07 — Logic Gate: Level Lock/Unlock

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/level_model.dart';
import '../models/user_model.dart';
import '../services/level_service.dart';
import '../core/level_content_data.dart';
import '../providers/service_providers.dart';
import 'auth_view_model.dart';

// ── State ──────────────────────────────────────────────────────────────────

enum LevelStatus { locked, available, completedPass, completedFail }

class LevelEntry {
  final LevelConfig config;
  final LevelStatus status;
  final int? quizScore; // null jika belum pernah dikerjakan

  const LevelEntry({
    required this.config,
    required this.status,
    this.quizScore,
  });
}

class LevelState {
  final List<LevelEntry> entries;
  final bool isLoading;
  final String? errorMessage;
  /// Apakah pretest perlu ditampilkan (setelah Level 1 selesai, belum pernah pretest)
  final bool showPretest;
  /// Apakah posttest perlu ditampilkan (setelah crafting selesai, belum pernah posttest)
  final bool showPosttest;

  const LevelState({
    this.entries = const [],
    this.isLoading = false,
    this.errorMessage,
    this.showPretest = false,
    this.showPosttest = false,
  });

  LevelState copyWith({
    List<LevelEntry>? entries,
    bool? isLoading,
    String? errorMessage,
    bool? showPretest,
    bool? showPosttest,
  }) {
    return LevelState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      showPretest: showPretest ?? this.showPretest,
      showPosttest: showPosttest ?? this.showPosttest,
    );
  }
}

// ── Provider ───────────────────────────────────────────────────────────────

final levelViewModelProvider =
    StateNotifierProvider<LevelViewModel, LevelState>(
  (ref) => LevelViewModel(ref, ref.read(levelServiceProvider)),
);

// ── ViewModel ──────────────────────────────────────────────────────────────

class LevelViewModel extends StateNotifier<LevelState> {
  final Ref _ref;
  final LevelService _levelService;

  LevelViewModel(this._ref, this._levelService) : super(const LevelState());

  UserModel? get _user => _ref.read(authViewModelProvider).currentUser;

  /// Muat semua 25 level dengan status lock/unlock berdasarkan progress user.
  void loadLevels() {
    final user = _user;
    if (user == null) return;

    final entries = _buildEntries(user);
    state = state.copyWith(entries: entries, isLoading: false);
  }

  /// Bangun daftar LevelEntry dengan status yang tepat berdasarkan progress user.
  List<LevelEntry> _buildEntries(UserModel user) {
    final completed = user.completedLevels;
    final quizScores = user.quizScores;

    return LevelContentData.levels.map((config) {
      final n = config.levelNumber;
      final isCompleted = completed.contains(n);
      final score = quizScores[n.toString()];

      LevelStatus status;

      if (isCompleted) {
        // Level sudah selesai
        if (config.isQuiz) {
          final s = score ?? 0;
          status = s >= config.passingScore
              ? LevelStatus.completedPass
              : LevelStatus.completedFail;
        } else {
          status = LevelStatus.completedPass;
        }
      } else if (_isUnlocked(n, completed, quizScores)) {
        // Level tersedia
        // Untuk quiz yang pernah dikerjakan tapi gagal, tetap available (bisa retry)
        if (config.isQuiz && score != null && score < config.passingScore) {
          status = LevelStatus.completedFail;
        } else {
          status = LevelStatus.available;
        }
      } else {
        status = LevelStatus.locked;
      }

      return LevelEntry(config: config, status: status, quizScore: score);
    }).toList();
  }

  /// Logika unlock level:
  /// - Level 1 selalu tersedia
  /// - Level 2–9: unlock jika level sebelumnya selesai
  /// - Level 10 (quiz): unlock jika level 9 selesai
  /// - Level 11: unlock jika level 10 quiz LULUS (≥70)
  /// - Level 12–14: unlock berurutan
  /// - Level 15 (quiz): unlock jika level 14 selesai
  /// - Level 16: unlock jika level 15 quiz LULUS
  /// - Level 17–19: unlock berurutan
  /// - Level 20 (quiz): unlock jika level 19 selesai
  /// - Level 21: unlock jika level 20 quiz LULUS
  /// - Level 22–24: unlock berurutan
  /// - Level 25 (quiz): unlock jika level 24 selesai
  bool _isUnlocked(
    int levelNumber,
    List<int> completed,
    Map<String, int> quizScores,
  ) {
    if (levelNumber == 1) return true;

    final prev = levelNumber - 1;
    final prevCompleted = completed.contains(prev);

    // Level setelah quiz checkpoint memerlukan quiz lulus
    if (levelNumber == 11 || levelNumber == 16 || levelNumber == 21) {
      final quizLevel = levelNumber - 1; // 10, 15, 20
      final quizScore = quizScores[quizLevel.toString()] ?? 0;
      final quizConfig = LevelContentData.getLevel(quizLevel);
      final passingScore = quizConfig?.passingScore ?? 70;
      return quizScore >= passingScore;
    }

    // Level setelah quiz 25 (jembatan) — tidak ada level 26, tapi posttest trigger
    // Level normal: unlock jika level sebelumnya selesai
    return prevCompleted;
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  /// Selesaikan level materi. Unlock level berikutnya.
  /// Jika level 1 selesai dan pretest belum dikerjakan, set showPretest = true.
  Future<void> completeMaterialLevel(int levelNumber) async {
    final user = _user;
    if (user == null) return;

    state = state.copyWith(isLoading: true);
    try {
      await _levelService.completeMaterialLevel(
        userId: user.id,
        levelNumber: levelNumber,
      );

      // Update local user state
      final updatedCompleted = [...user.completedLevels, levelNumber];
      final updatedUser = user.copyWith(completedLevels: updatedCompleted);
      _ref.read(authViewModelProvider.notifier).updateUser(updatedUser);

      final entries = _buildEntries(updatedUser);

      // Cek apakah perlu tampilkan pretest (setelah Level 1)
      final showPretest = levelNumber == 1 && !user.pretestDone;

      state = state.copyWith(
        entries: entries,
        isLoading: false,
        showPretest: showPretest,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal menyimpan progress. Coba lagi.',
      );
    }
  }

  /// Submit hasil quiz evaluasi (level 10/15/20/25).
  Future<void> submitQuizResult({
    required int levelNumber,
    required int score,
    required List<int> answers,
  }) async {
    final user = _user;
    if (user == null) return;

    final config = LevelContentData.getLevel(levelNumber);
    if (config == null) return;

    final passed = score >= config.passingScore;

    state = state.copyWith(isLoading: true);
    try {
      // Simpan ke quiz_results collection
      await _levelService.saveQuizResult(
        userId: user.id,
        levelNumber: levelNumber,
        score: score,
        answers: answers,
        passed: passed,
      );

      // Update level completion jika lulus
      await _levelService.completeQuizLevel(
        userId: user.id,
        levelNumber: levelNumber,
        score: score,
        passed: passed,
      );

      // Update local user state
      final updatedScores = Map<String, int>.from(user.quizScores);
      final existingScore = updatedScores[levelNumber.toString()] ?? 0;
      if (score > existingScore) {
        updatedScores[levelNumber.toString()] = score;
      }

      List<int> updatedCompleted = List.from(user.completedLevels);
      if (passed && !updatedCompleted.contains(levelNumber)) {
        updatedCompleted.add(levelNumber);
      }

      final updatedUser = user.copyWith(
        completedLevels: updatedCompleted,
        quizScores: updatedScores,
      );
      _ref.read(authViewModelProvider.notifier).updateUser(updatedUser);

      final entries = _buildEntries(updatedUser);
      state = state.copyWith(entries: entries, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal menyimpan hasil quiz. Coba lagi.',
      );
    }
  }

  /// Submit hasil pretest. Level 2 di-unlock setelah ini.
  Future<void> submitPretest({
    required int score,
    required List<int> answers,
  }) async {
    final user = _user;
    if (user == null) return;

    state = state.copyWith(isLoading: true);
    try {
      await _levelService.savePretest(
        userId: user.id,
        score: score,
        answers: answers,
      );

      final updatedUser = user.copyWith(pretestDone: true);
      _ref.read(authViewModelProvider.notifier).updateUser(updatedUser);

      final entries = _buildEntries(updatedUser);
      state = state.copyWith(
        entries: entries,
        isLoading: false,
        showPretest: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal menyimpan hasil pretest.',
      );
    }
  }

  /// Submit hasil posttest. Dipanggil setelah crafting selesai.
  Future<void> submitPosttest({
    required int score,
    required List<int> answers,
  }) async {
    final user = _user;
    if (user == null) return;

    state = state.copyWith(isLoading: true);
    try {
      await _levelService.savePosttest(
        userId: user.id,
        score: score,
        answers: answers,
      );

      final updatedUser = user.copyWith(posttestDone: true);
      _ref.read(authViewModelProvider.notifier).updateUser(updatedUser);

      state = state.copyWith(
        isLoading: false,
        showPosttest: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal menyimpan hasil posttest.',
      );
    }
  }

  /// Dismiss pretest flag (jika user sudah selesai pretest)
  void clearShowPretest() => state = state.copyWith(showPretest: false);

  /// Set showPosttest = true (dipanggil dari CraftingViewModel saat crafting selesai)
  void triggerPosttest() {
    final user = _user;
    if (user == null || user.posttestDone) return;
    state = state.copyWith(showPosttest: true);
  }

  void clearShowPosttest() => state = state.copyWith(showPosttest: false);

  void clearError() => state = state.copyWith(errorMessage: null);
}
