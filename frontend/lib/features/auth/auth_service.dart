import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  
  bool get isAuthenticated => _isAuthenticated;

  void login() {
    _isAuthenticated = true;
    notifyListeners(); // Avisa o GoRouter que o estado mudou
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners(); // Avisa o GoRouter que o estado mudou
  }
}

// Criamos uma instância global para facilitar o acesso no Router e no Login
final authService = AuthService();