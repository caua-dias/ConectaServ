class AuthService {
  // Aqui futuramente você conectará com seu backend ou Firebase
  Future<bool> fazerLogin(String email, String senha) async {
    // Simulando um tempo de processamento de rede
    await Future.delayed(const Duration(seconds: 2));
    return true; // Simula que o login deu certo
  }

  Future<void> fazerLogout() async {
    await Future.delayed(const Duration(seconds: 1));
  }
}