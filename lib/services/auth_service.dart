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
    final data = Map<String, dynamic>.from(doc.data()!);
    data['id'] = uid;

    // Firestore stores FieldValue.serverTimestamp() as a Timestamp object,
    // but the generated fromJson expects an ISO 8601 String.
    // Convert Timestamp → String, or remove if null (not yet resolved).
    if (data['createdAt'] is Timestamp) {
      data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
    } else if (data['createdAt'] != null && data['createdAt'] is! String) {
      // Unknown type — drop to avoid crash
      data.remove('createdAt');
    }

    return UserModel.fromJson(data);
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
