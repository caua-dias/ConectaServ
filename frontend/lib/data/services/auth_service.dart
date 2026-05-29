import '../../core/http_client.dart';
import '../models/user_model.dart';

class AuthService {
  final HttpClient _httpClient;

  const AuthService(this._httpClient);

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _httpClient.post(
      '/api/auth/login',
      {
        'email': email,
        'password': password,
      },
    );

    final user = UserModel.fromJson(response);

    _httpClient.setAuthToken(user.token);

    return user;
  }

  Future<void> recoverPassword({required String email}) async {
    await _httpClient.post(
      '/api/auth/recover-password',
      {'email': email},
    );
  
  }

  void logout() {
    _httpClient.clearAuthToken();
  }
}
