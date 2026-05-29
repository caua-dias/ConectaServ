import '../../core/http_client.dart';
import '../models/user_model.dart';

class ClientService {
  final HttpClient _httpClient;

  const ClientService(this._httpClient);

  Future<UserModel> registerClient({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    final response = await _httpClient.post(
      '/api/clients',
      {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      },
    );

    return UserModel.fromJson(response);
  }
}