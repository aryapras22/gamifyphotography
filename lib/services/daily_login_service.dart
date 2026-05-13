import 'package:cloud_firestore/cloud_firestore.dart';

const int kDailyLoginPoints = 50;
const int kMaxStreakDays = 7;

class DailyLoginService {
  final _db = FirebaseFirestore.instance;

  DocumentReference _userRef(String userId) =>
      _db.collection('users').doc(userId);

  bool _isToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isYesterday(DateTime? date) {
    if (date == null) return false;
    final y = DateTime.now().subtract(const Duration(days: 1));
    return date.year == y.year && date.month == y.month && date.day == y.day;
  }

  Future<Map<String, dynamic>> _fetchFields(String userId) async {
    final doc = await _userRef(userId).get() as DocumentSnapshot<Map<String, dynamic>>;
    return doc.data() ?? {};
  }

  Future<bool> hasClaimedToday(String userId) async {
    final data = await _fetchFields(userId);
    final ts = data['lastLoginDate'];
    if (ts == null) return false;
    return _isToday((ts as Timestamp).toDate());
  }

  Future<int> getCurrentStreak(String userId) async {
    final data = await _fetchFields(userId);
    final ts = data['lastLoginDate'];
    int streak = data['streakCount'] ?? 0;
    if (ts == null) return 0;
    final last = (ts as Timestamp).toDate();
    if (!_isToday(last) && !_isYesterday(last)) {
      streak = 0;
      await _userRef(userId).update({'streakCount': 0});
    }
    return streak;
  }

  Future<int> claimDailyLogin(String userId) async {
    final data = await _fetchFields(userId);
    final ts = data['lastLoginDate'];
    int streak = data['streakCount'] ?? 0;
    List<bool> history = data['weekHistory'] != null
        ? List<bool>.from(data['weekHistory'])
        : List.filled(kMaxStreakDays, false);

    if (ts != null && _isToday((ts as Timestamp).toDate())) {
      throw Exception('Already claimed today.');
    }

    if (ts != null && !_isYesterday((ts as Timestamp).toDate())) {
      streak = 0;
      history = List.filled(kMaxStreakDays, false);
    }

    if (streak >= kMaxStreakDays) {
      streak = 1;
      history = List.filled(kMaxStreakDays, false);
    } else {
      streak += 1;
    }

    history[streak - 1] = true;

    await _userRef(userId).update({
      'streakCount': streak,
      'lastLoginDate': Timestamp.fromDate(DateTime.now()),
      'weekHistory': history,
    });

    return kDailyLoginPoints;
  }

  Future<List<bool>> getWeekHistory(String userId) async {
    final data = await _fetchFields(userId);
    if (data['weekHistory'] == null) return List.filled(kMaxStreakDays, false);
    return List<bool>.from(data['weekHistory']);
  }
}
