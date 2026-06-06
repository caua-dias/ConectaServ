import 'package:flutter/material.dart';
import '../../../../data/models/user_model.dart';

class AuthNotifier extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  bool _carregando = false;
  bool get carregando => _carregando;

  UserModel? _user;
  UserModel? get user => _user;

  // Não precisamos mais receber os serviços HTTP pelo construtor
  AuthNotifier();

  Future<void> login(String email, String senha) async {
    _carregando = true;
    notifyListeners();

    // Simula um tempo de carregamento para parecer real
    await Future.delayed(const Duration(seconds: 1));

    // Cria um utilizador local fictício apenas para manter a sessão ativa
    _user = UserModel(
        id: "1",
        name: 'Utilizador',
        email: email,
        token: 'token_local_123',
        userType: "client");
    _isAuthenticated = true;

    _carregando = false;
    notifyListeners();
  }

  Future<void> recoverPassword(String email) async {
    _carregando = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _carregando = false;
    notifyListeners();
  }

  Future<void> registerClient(
      {required String documento,
      required String email,
      required String senha}) async {
    _carregando = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));
    _user = UserModel(
        id: "2",
        name: 'Cliente Local',
        email: email,
        token: 'token_local_456',
        userType: "client");
    _isAuthenticated = true; // Entra automaticamente após o registo

    _carregando = false;
    notifyListeners();
  }

  Future<void> registerCompany(
      {required String cnpj,
      required String email,
      required String senha}) async {
    _carregando = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));
    _user = UserModel(
        id: "3",
        name: 'Empresa Local',
        email: email,
        token: 'token_local_789',
        userType: "company");
    _isAuthenticated = true; // Entra automaticamente após o registo

    _carregando = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _carregando = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));
    _isAuthenticated = false;
    _user = null;

    _carregando = false;
    notifyListeners();
  }
}
