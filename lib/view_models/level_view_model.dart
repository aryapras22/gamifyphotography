// lib/view_models/level_view_model.dart
// Module restructure — 3 types, no pretest/posttest flags

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
  final bool isContentLoading;
  final String? errorMessage;
  final List<FirestoreLevel> firestoreLevels;

  const LevelState({
    this.entries = const [],
    this.isLoading = false,
    this.isContentLoading = false,
    this.errorMessage,
    this.firestoreLevels = const [],
  });

  LevelState copyWith({
    List<LevelEntry>? entries,
    bool? isLoading,
    bool? isContentLoading,
    String? errorMessage,
    List<FirestoreLevel>? firestoreLevels,
  }) {
    return LevelState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      isContentLoading: isContentLoading ?? this.isContentLoading,
      errorMessage: errorMessage,
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

  Future<void> loadLevelContent() async {
    state = state.copyWith(isContentLoading: true);
    try {
      final levels = await _firestoreLevelContentService.getAllActiveLevels();
      state = state.copyWith(
        firestoreLevels: levels,
        isContentLoading: false,
      );
      debugPrint('[LevelViewModel] Loaded ${levels.length} levels from Firestore');
    } catch (e) {
      debugPrint('[LevelViewModel] Firestore content error: $e');
      state = state.copyWith(
        isContentLoading: false,
        errorMessage: 'Gagal memuat konten level. Periksa koneksi internet.',
      );
    }
  }

  FirestoreLevel? getLevelContent(int levelNumber) {
    try {
      return state.firestoreLevels
          .firstWhere((l) => l.levelNumber == levelNumber);
    } catch (_) {
      return null;
    }
  }

  // ── Progress Loading ──────────────────────────────────────────────────────

  void loadLevels() {
    final user = _user;
    if (user == null) return;
    final entries = _buildEntries(user);
    state = state.copyWith(entries: entries, isLoading: false);
  }

  Future<void> loadAll() async {
    await loadLevelContent();
    loadLevels();
  }

  // ── Entry Building ────────────────────────────────────────────────────────

  List<LevelEntry> _buildEntries(UserModel user) {
    final completed = user.completedLevels;
    final quizScores = user.quizScores;
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

  List<LevelConfig> _resolveConfigs() {
    if (state.firestoreLevels.isEmpty) return [];

    final result = <LevelConfig>[];
    for (final fs in state.firestoreLevels) {
      if (fs.isMateri) {
        result.add(LevelConfig(
          levelNumber: fs.levelNumber,
          title: fs.title,
          type: fs.type,
          materiContent: fs.toMateriContent(),
          passingScore: fs.passingScore,
        ));
      } else {
        result.add(LevelConfig(
          levelNumber: fs.levelNumber,
          title: fs.title,
          type: fs.type,
          questions: const [],
          passingScore: fs.passingScore,
          hasPreQuizMaterial: fs.hasPreQuizMaterial,
          preQuizContent: fs.preQuizContent,
          preQuizTitle: fs.preQuizTitle,
        ));
      }
    }

    result.sort((a, b) => a.levelNumber.compareTo(b.levelNumber));
    return result;
  }

  /// Level unlock logic:
  /// - Level 0 (pre-test): always available
  /// - Level 1: always available
  /// - Level N: available after level N-1 is completed
  /// - Quiz levels after gate (11, 16, 21): require passing score on previous quiz
  bool _isUnlocked(
    int levelNumber,
    List<int> completed,
    Map<String, int> quizScores,
  ) {
    // Level 0 (pre-test) and level 1 are always unlocked
    if (levelNumber == 0 || levelNumber == 1) return true;

    final prev = levelNumber - 1;

    // Gate levels after quiz checkpoints
    if (levelNumber == 11 || levelNumber == 16 || levelNumber == 21) {
      final quizLevel = levelNumber - 1;
      final quizScore = quizScores[quizLevel.toString()] ?? 0;
      final fsLevel = getLevelContent(quizLevel);
      final passingScore = fsLevel?.passingScore ?? 70;
      return quizScore >= passingScore;
    }

    return completed.contains(prev);
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

      // Auto-check badge after level completion
      final badgeService = _ref.read(badgeServiceProvider);
      await badgeService.checkAndAwardBadges(updatedUser);

      final entries = _buildEntries(updatedUser);
      state = state.copyWith(entries: entries, isLoading: false);
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

    final fsLevel = getLevelContent(levelNumber);
    final passingScore = fsLevel?.passingScore ?? 70;
    final passed = score >= passingScore;

    state = state.copyWith(isLoading: true);
    try {
      await _levelService.saveQuizResult(
        userId: user.id,
        userName: user.name,
        userEmail: user.email,
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

  void clearError() => state = state.copyWith(errorMessage: null);
}
