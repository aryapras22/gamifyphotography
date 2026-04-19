import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final UserModel? currentUser;

  AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.currentUser,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    UserModel? currentUser,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      currentUser: currentUser ?? this.currentUser,
    );
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>(
  (ref) => AuthViewModel(ref.read(authServiceProvider)),
);

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthViewModel(this._authService) : super(AuthState(
    // BYPASS LOGIN: Auto-mock a user
    currentUser: UserModel(
      id: 'mock_1',
      name: 'Player One',
      email: 'player@mock.com',
      points: 50,
      level: 1,
      earnedBadgeIds: [],
    )
  ));

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _authService.login(email, password);
      state = state.copyWith(isLoading: false, currentUser: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _authService.register(name, email, password);
      state = state.copyWith(isLoading: false, currentUser: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void logout() {
    state = AuthState(); // clear state
  }
}
