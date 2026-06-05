import 'package:flutter/material.dart';

// Importa o serviço REAL e o modelo da camada de dados
import '../../../../data/services/auth_service.dart';
import '../../../../data/models/user_model.dart';

class AuthNotifier extends ChangeNotifier {
  final AuthService _authService;
  
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  bool _carregando = false; 
  bool get carregando => _carregando;

  UserModel? _user;
  UserModel? get user => _user;

  // Recebe o serviço real via injeção de dependência (GetIt)
  AuthNotifier(this._authService);

  Future<void> login(String email, String senha) async {
    _carregando = true;
    notifyListeners(); 

    try {
      // Chama o serviço HTTP real
      _user = await _authService.login(email: email, password: senha);
      _isAuthenticated = true;
    } catch (e) {
      _isAuthenticated = false;
      _user = null;
      rethrow; // Lança o erro para a UI (LoginPage) poder mostrar a SnackBar
    } finally {
      _carregando = false;
      notifyListeners(); 
    }
  }

  Future<void> recoverPassword(String email) async {
    _carregando = true;
    notifyListeners();

    try {
      await _authService.recoverPassword(email: email);
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _carregando = true;
    notifyListeners();

    _authService.logout();
    _isAuthenticated = false;
    _user = null;
    
    _carregando = false;
    notifyListeners(); 
  }
}