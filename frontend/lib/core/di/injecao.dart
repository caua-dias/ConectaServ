import 'package:get_it/get_it.dart';
import '../../features/auth/auth_service.dart'; // Ajuste o caminho para onde está o seu AuthService

final sl = GetIt.instance; // sl = Service Locator

void setupDependencies() {
  // Registramos o AuthService como um LazySingleton. 
  // Isso significa que ele será instanciado apenas quando necessário e a mesma instância será reutilizada em todo o app [2].
  sl.registerLazySingleton<AuthService>(() => AuthService());
}