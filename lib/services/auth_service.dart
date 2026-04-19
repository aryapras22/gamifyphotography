import '../models/user_model.dart';

class AuthService {
  Future<UserModel> login(String email, String password) async {
    // Mock login
    await Future.delayed(const Duration(seconds: 1));
    if (email == 'test@test.com' && password == 'password') {
      return UserModel(
        id: 'user_1',
        name: 'Test User',
        email: email,
      );
    }
    throw Exception('Invalid credentials');
  }

  Future<UserModel> register(String name, String email, String password) async {
    // Mock register
    await Future.delayed(const Duration(seconds: 1));
    return UserModel(
      id: 'user_2',
      name: name,
      email: email,
    );
  }
}
