// lib/view_models/level_view_model.dart
// TASK-07 (original) + TASK-M03 (Firestore migration)

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/level_model.dart';
import '../models/user_model.dart';
import '../services/level_service.dart';
import '../services/firestore_level_content_service.dart';
import '../providers/service_providers.dart';
import 'auth_view_model.dart';

// ── State ──────────────────────────────────────────────────────────────────

enum LevelStatus { locked, available, completedPass, completedFail }

class LevelEntry {
  final LevelConfig config;
  final LevelStatus status;
  final int? quizScore;
  /// Firestore level data — null jika belum dimuat atau fallback ke hardcoded
  final FirestoreLevel? firestoreLevel;

  const LevelEntry({
    required this.config,
    required this.status,
    this.quizScore,
    this.firestoreLevel,
  });
}

class LevelState {
  final List<LevelEntry> entries;
  final bool isLoading;
  /// Loading konten level dari Firestore (terpisah dari isLoading progress)
  final bool isContentLoading;
  final String? errorMessage;
  final bool showPretest;
  final bool showPosttest;
  /// Data konten level dari Firestore (kosong = belum dimuat / fallback)
  final List<FirestoreLevel> firestoreLevels;

  const LevelState({
    this.entries = const [],
    this.isLoading = false,
    this.isContentLoading = false,
    this.errorMessage,
    this.showPretest = false,
    this.showPosttest = false,
    this.firestoreLevels = const [],
  });

  LevelState copyWith({
    List<LevelEntry>? entries,
    bool? isLoading,
    bool? isContentLoading,
    String? errorMessage,
    bool? showPretest,
    bool? showPosttest,
    List<FirestoreLevel>? firestoreLevels,
  }) {
    return LevelState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      isContentLoading: isContentLoading ?? this.isContentLoading,
      errorMessage: errorMessage,
      showPretest: showPretest ?? this.showPretest,
      showPosttest: showPosttest ?? this.showPosttest,
      firestoreLevels: firestoreLevels ?? this.firestoreLevels,
    );
  }
}

// ── Provider ───────────────────────────────────────────────────────────────

final levelViewModelProvider =
    StateNotifierProvider<LevelViewModel, LevelState>(
  (ref) => LevelViewModel(
    ref,
    ref.read(levelServiceProvider),
    ref.read(firestoreLevelContentServiceProvider),
  ),
);

// ── ViewModel ──────────────────────────────────────────────────────────────

class LevelViewModel extends StateNotifier<LevelState> {
  final Ref _ref;
  final LevelService _levelService;
  final FirestoreLevelContentService _firestoreLevelContentService;

  LevelViewModel(this._ref, this._levelService, this._firestoreLevelContentService)
      : super(const LevelState());

  UserModel? get _user => _ref.read(authViewModelProvider).currentUser;

  // ── Content Loading ───────────────────────────────────────────────────────

  /// Muat konten level dari Firestore.
  /// Fallback otomatis ke LevelContentData hardcoded jika Firestore gagal/kosong.
  Future<void> loadLevelContent() async {
    state = state.copyWith(isContentLoading: true);
    try {
      final levels = await _firestoreLevelContentService.getAllActiveLevels();
      if (levels.isNotEmpty) {
        state = state.copyWith(
          firestoreLevels: levels,
          isContentLoading: false,
        );
        debugPrint('[LevelViewModel] Loaded ${levels.length} levels from Firestore');
      } else {
        // Firestore kosong — gunakan fallback hardcoded (zero downtime)
        debugPrint('[LevelViewModel] Firestore empty, using hardcoded fallback');
        state = state.copyWith(isContentLoading: false);
      }
    } catch (e) {
      debugPrint('[LevelViewModel] Firestore content error, fallback: $e');
      state = state.copyWith(isContentLoading: false);
    }
  }

  /// Ambil [FirestoreLevel] berdasarkan levelNumber dari state.
  /// Return null jika belum dimuat atau tidak ada di Firestore.
  FirestoreLevel? getLevelContent(int levelNumber) {
    try {
      return state.firestoreLevels
          .firstWhere((l) => l.levelNumber == levelNumber);
    } catch (_) {
      return null;
    }
  }

  // ── Progress Loading ──────────────────────────────────────────────────────

  /// Muat semua 25 level dengan status lock/unlock berdasarkan progress user.
  /// Menggunakan firestoreLevels jika tersedia, fallback ke LevelContentData.
  void loadLevels() {
    final user = _user;
    if (user == null) return;
    final entries = _buildEntries(user);
    state = state.copyWith(entries: entries, isLoading: false);
  }

  /// Muat konten Firestore + progress sekaligus (convenience method).
  Future<void> loadAll() async {
    await loadLevelContent();
    loadLevels();
  }

  // ── Entry Building ────────────────────────────────────────────────────────

  List<LevelEntry> _buildEntries(UserModel user) {
    final completed = user.completedLevels;
    final quizScores = user.quizScores;

    // Gunakan Firestore levels jika tersedia, fallback ke hardcoded
    final configs = _resolveConfigs();

    return configs.map((config) {
      final n = config.levelNumber;
      final isCompleted = completed.contains(n);
      final score = quizScores[n.toString()];
      final firestoreLevel = getLevelContent(n);

      LevelStatus status;

      if (isCompleted) {
        if (config.isQuiz) {
          final s = score ?? 0;
          status = s >= config.passingScore
              ? LevelStatus.completedPass
              : LevelStatus.completedFail;
        } else {
          status = LevelStatus.completedPass;
        }
      } else if (_isUnlocked(n, completed, quizScores)) {
        if (config.isQuiz && score != null && score < config.passingScore) {
          status = LevelStatus.completedFail;
        } else {
          status = LevelStatus.available;
        }
      } else {
        status = LevelStatus.locked;
      }

      return LevelEntry(
        config: config,
        status: status,
        quizScore: score,
        firestoreLevel: firestoreLevel,
      );
    }).toList();
  }

  /// Resolve konfigurasi level: merge Firestore data ke LevelConfig hardcoded.
  /// Firestore data digunakan untuk konten (page1/page2), hardcoded untuk struktur.
  List<LevelConfig> _resolveConfigs() {
    return state.firestoreLevels.map((fsLevel) {
      if (fsLevel.isMateri) {
        return LevelConfig(
          levelNumber: fsLevel.levelNumber,
          title: fsLevel.title,
          type: fsLevel.type,
          materiContent: fsLevel.toMateriContent(),
          passingScore: fsLevel.passingScore,
        );
      }
      return LevelConfig(
        levelNumber: fsLevel.levelNumber,
        title: fsLevel.title,
        type: fsLevel.type,
        questions: const [],
        passingScore: fsLevel.passingScore,
      );
    }).toList();
  }

  bool _isUnlocked(
    int levelNumber,
    List<int> completed,
    Map<String, int> quizScores,
  ) {
    if (levelNumber == 1) return true;

    final prev = levelNumber - 1;
    final prevCompleted = completed.contains(prev);

    if (levelNumber == 11 || levelNumber == 16 || levelNumber == 21) {
      final quizLevel = levelNumber - 1;
      final quizScore = quizScores[quizLevel.toString()] ?? 0;
      // Cek passingScore dari Firestore jika tersedia
      final fsLevel = getLevelContent(quizLevel);
      final passingScore = fsLevel?.passingScore ?? 70;
      return quizScore >= passingScore;
    }

    return prevCompleted;
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  Future<void> completeMaterialLevel(int levelNumber) async {
    final user = _user;
    if (user == null) return;

    state = state.copyWith(isLoading: true);
    try {
      await _levelService.completeMaterialLevel(
        userId: user.id,
        levelNumber: levelNumber,
      );

      final updatedCompleted = [...user.completedLevels, levelNumber];
      final updatedUser = user.copyWith(completedLevels: updatedCompleted);
      _ref.read(authViewModelProvider.notifier).updateUser(updatedUser);

      final entries = _buildEntries(updatedUser);
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

  Future<void> submitQuizResult({
    required int levelNumber,
    required int score,
    required List<int> answers,
  }) async {
    final user = _user;
    if (user == null) return;

    // Cek passingScore dari Firestore atau fallback hardcoded
    final fsLevel = getLevelContent(levelNumber);
    final passingScore = fsLevel?.passingScore ?? 70;
    final passed = score >= passingScore;

    state = state.copyWith(isLoading: true);
    try {
      await _levelService.saveQuizResult(
        userId: user.id,
        levelNumber: levelNumber,
        score: score,
        answers: answers,
        passed: passed,
      );

      await _levelService.completeQuizLevel(
        userId: user.id,
        levelNumber: levelNumber,
        score: score,
        passed: passed,
      );

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

  void clearShowPretest() => state = state.copyWith(showPretest: false);

  void triggerPosttest() {
    final user = _user;
    if (user == null || user.posttestDone) return;
    state = state.copyWith(showPosttest: true);
  }

  void clearShowPosttest() => state = state.copyWith(showPosttest: false);

  void clearError() => state = state.copyWith(errorMessage: null);
}
