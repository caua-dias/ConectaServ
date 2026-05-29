import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  const AuthRepository(this._authService);

  Future<UserModel> login({
    required String email,
    required String password,
  }) =>
      _authService.login(email: email, password: password);

  Future<void> recoverPassword({required String email}) =>
      _authService.recoverPassword(email: email);

  void logout() => _authService.logout();
}