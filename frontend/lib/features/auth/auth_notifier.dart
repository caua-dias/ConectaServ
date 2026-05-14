import 'package:flutter/material.dart';
import 'auth_service.dart';

class AuthNotifier extends ChangeNotifier {
  final AuthService _authService;
  
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  // Estado adicional recomendado para mostrar "loading_overlay"
  bool _carregando = false; 
  bool get carregando => _carregando;

  // Recebemos o serviço via injeção de dependência (que o GetIt fará)
  AuthNotifier(this._authService);

  Future<void> login(String email, String senha) async {
    _carregando = true;
    notifyListeners(); // Avisa a tela para mostrar o "carregando"

    try {
      // Chama o serviço puro
      _isAuthenticated = await _authService.fazerLogin(email, senha);
    } catch (e) {
      _isAuthenticated = false;
    } finally {
      _carregando = false;
      notifyListeners(); // Avisa o GoRouter e a tela que a requisição terminou
    }
  }

  Future<void> logout() async {
    _carregando = true;
    notifyListeners();

    await _authService.fazerLogout();
    _isAuthenticated = false;
    
    _carregando = false;
    notifyListeners(); // Avisa o GoRouter para redirecionar pro Login
  }
}