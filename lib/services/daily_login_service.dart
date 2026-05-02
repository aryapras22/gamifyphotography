// lib/services/daily_login_service.dart
// TASK-02 — Mock DailyLoginService (in-memory, no Firebase)

const int kDailyLoginPoints = 50;
const int kMaxStreakDays = 7;

/// Struktur data in-memory untuk menyimpan state login harian per user.
class _UserLoginData {
  int streak;
  DateTime? lastClaimedDate;
  List<DateTime?> weekHistory; // 7 slot, null = belum claim

  _UserLoginData()
      : streak = 0,
        lastClaimedDate = null,
        weekHistory = List.filled(kMaxStreakDays, null);
}

class DailyLoginService {
  // In-memory store — reset ketika app restart (by design, mock only)
  final Map<String, _UserLoginData> _store = {};

  _UserLoginData _getData(String userId) {
    return _store.putIfAbsent(userId, () => _UserLoginData());
  }

  bool _isToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isYesterday(DateTime? date) {
    if (date == null) return false;
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Cek apakah user sudah claim hari ini.
  Future<bool> hasClaimedToday(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _isToday(_getData(userId).lastClaimedDate);
  }

  /// Ambil streak saat ini (0–7).
  Future<int> getCurrentStreak(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final data = _getData(userId);
    // Jika tidak claim kemarin DAN tidak claim hari ini, streak = 0
    if (!_isToday(data.lastClaimedDate) && !_isYesterday(data.lastClaimedDate)) {
      data.streak = 0;
    }
    return data.streak;
  }

  /// Lakukan claim — return poin yang didapat (kDailyLoginPoints = 50).
  /// Throw Exception jika sudah claim hari ini.
  Future<int> claimDailyLogin(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final data = _getData(userId);

    if (_isToday(data.lastClaimedDate)) {
      throw Exception('Sudah claim hari ini.');
    }

    // Reset streak jika skip > 1 hari
    if (!_isYesterday(data.lastClaimedDate) && data.lastClaimedDate != null) {
      data.streak = 0;
      data.weekHistory = List.filled(kMaxStreakDays, null);
    }

    // Increment streak, reset ke 1 jika sudah mencapai maksimal
    if (data.streak >= kMaxStreakDays) {
      data.streak = 1;
      data.weekHistory = List.filled(kMaxStreakDays, null);
    } else {
      data.streak += 1;
    }

    final now = DateTime.now();
    data.lastClaimedDate = now;

    // Simpan ke slot history berdasarkan posisi streak (1-based)
    final slotIndex = data.streak - 1;
    data.weekHistory[slotIndex] = now;

    return kDailyLoginPoints;
  }

  /// Ambil history 7 hari: true = sudah claim, false = belum/skip.
  Future<List<bool>> getWeekHistory(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final data = _getData(userId);
    return data.weekHistory.map((d) => d != null).toList();
  }
}
