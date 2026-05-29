import '../../core/http_client.dart';
import '../models/user_model.dart';

class CompanyService {
  final HttpClient _httpClient;

  const CompanyService(this._httpClient);

  Future<UserModel> registerCompany({
    required String companyName,
    required String cnpj,
    required String email,
    required String password,
    required String phone,
  }) async {
    final response = await _httpClient.post(
      '/api/companies',
      {
        'companyName': companyName,
        'cnpj': cnpj,
        'email': email,
        'password': password,
        'phone': phone,
      },
    );

    return UserModel.fromJson(response);
  }
}