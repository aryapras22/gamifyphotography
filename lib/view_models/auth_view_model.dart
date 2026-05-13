import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../providers/service_providers.dart';

const _unset = Object();

class AuthState {
  final bool isLoading;
  final bool isCheckingSession;
  final String? errorMessage;
  final UserModel? currentUser;

  AuthState({
    this.isLoading = false,
    this.isCheckingSession = true,
    this.errorMessage,
    this.currentUser,
  });

  bool get isLoggedIn => currentUser != null;

  AuthState copyWith({
    bool? isLoading,
    bool? isCheckingSession,
    Object? errorMessage = _unset,
    Object? currentUser = _unset,
  }) => AuthState(
    isLoading: isLoading ?? this.isLoading,
    isCheckingSession: isCheckingSession ?? this.isCheckingSession,
    errorMessage: errorMessage == _unset ? this.errorMessage : errorMessage as String?,
    currentUser: currentUser == _unset ? this.currentUser : currentUser as UserModel?,
  );
}

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>(
  (ref) => AuthViewModel(ref.read(authServiceProvider)),
);

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthService _authService;
  StreamSubscription? _sub;

  AuthViewModel(this._authService) : super(AuthState(isCheckingSession: true)) {
    _sub = _authService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser == null) {
        debugPrint('[Auth] No Firebase user → logged out');
        state = AuthState(isCheckingSession: false);
      } else {
        try {
          debugPrint('[Auth] Firebase user found: ${firebaseUser.uid}, fetching profile…');
          final user = await _authService.fetchUser(firebaseUser.uid);
          debugPrint('[Auth] Profile loaded: ${user.name}');
          state = AuthState(isCheckingSession: false, currentUser: user);
        } catch (e, st) {
          debugPrint('[Auth] fetchUser failed: $e\n$st');
          state = AuthState(isCheckingSession: false);
        }
      }
    });
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _authService.login(email, password);
      state = state.copyWith(isLoading: false, currentUser: user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _authService.register(name, email, password);
      state = state.copyWith(isLoading: false, currentUser: user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = AuthState(isCheckingSession: false);
  }

  void updateUser(UserModel u) => state = state.copyWith(currentUser: u);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
