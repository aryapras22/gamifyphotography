import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(), password: password,
      );
      return await fetchUser(cred.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapError(e));
    }
  }

  Future<UserModel> register(String name, String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password,
      );
      final uid = cred.user!.uid;
      final user = UserModel(
        id: uid, name: name.trim(),
        email: email.trim(), role: 'user',
        createdAt: DateTime.now(),
      );
      await _db.collection('users').doc(uid).set({
        ...user.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapError(e));
    }
  }

  Future<UserModel> fetchUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) throw Exception('User data not found.');
    final data = doc.data()!;

    DateTime? lastLoginDate;
    if (data['lastLoginDate'] is Timestamp) {
      lastLoginDate = (data['lastLoginDate'] as Timestamp).toDate();
    }

    return UserModel(
      id: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      points: data['points'] ?? 0,
      level: data['level'] ?? 1,
      bridgeProgress: data['bridgeProgress'] ?? 0,
      earnedBadgeIds: List<String>.from(data['earnedBadgeIds'] ?? []),
      completedPhotoUrls: List<String>.from(data['completedPhotoUrls'] ?? []),
      completedModuleIds: List<String>.from(data['completedModuleIds'] ?? []),
      streakCount: data['streakCount'] ?? 0,
      lastLoginDate: lastLoginDate,
      weekHistory: data['weekHistory'] != null
          ? List<bool>.from(data['weekHistory'])
          : List.filled(7, false),
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Persists mutable game progress fields to Firestore.
  /// Only updates the listed fields — never overwrites role, name, or email.
  Future<void> updateUserProgress(UserModel user) async {
    await _db.collection('users').doc(user.id).update({
      'points': user.points,
      'level': user.level,
      'bridgeProgress': user.bridgeProgress,
      'earnedBadgeIds': user.earnedBadgeIds,
      'completedPhotoUrls': user.completedPhotoUrls,
      'completedModuleIds': user.completedModuleIds,
      'streakCount': user.streakCount,
      'lastLoginDate': user.lastLoginDate != null
          ? Timestamp.fromDate(user.lastLoginDate!)
          : null,
      'weekHistory': user.weekHistory,
    });
  }

  Future<void> logout() async => _auth.signOut();

  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':     return 'Email is not registered.';
      case 'wrong-password':
      case 'invalid-credential': return 'Incorrect password.';
      case 'email-already-in-use': return 'Email already in use.';
      case 'weak-password':      return 'Password too weak (min 6 chars).';
      case 'invalid-email':      return 'Invalid email format.';
      case 'network-request-failed': return 'No internet connection.';
      default: return 'Authentication failed. Please try again.';
    }
  }
}
