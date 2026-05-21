import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart'; // Pacote do Provider

import 'router/app_router.dart';
import 'core/di/injecao.dart'; // Importe o arquivo de injeção que acabamos de criar
import 'features/auth/auth_notifier.dart'; // Importe o ViewModel (Notifier)
import 'features/auth/auth_service.dart'; // Importe o Serviço para o sl<AuthService>() funcionar

void main() {
  usePathUrlStrategy();
  
  // 1. Inicializa o GetIt antes de iniciar a interface do app
  setupDependencies(); 
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Envolvemos a aplicação inteira com o MultiProvider
    return MultiProvider(
      providers: [
        // 3. Registramos o AuthNotifier na árvore de widgets.
        // Ele pede o AuthService para o GetIt (sl) e o injeta no Notifier.
        ChangeNotifierProvider(
          create: (_) => AuthNotifier(sl<AuthService>()),
        ),
        // Futuramente, outros estados (como Notifier de Serviços ou Perfil) entrarão aqui.
      ],
      // 4. NOVO: Usamos o Builder para obter um contexto ABAIXO do MultiProvider
      child: Builder(
        builder: (appContext) {
          // 5. Lemos o AuthNotifier que acabou de ser provido acima
          final authNotifier = appContext.read<AuthNotifier>();
          
          // 6. Criamos as rotas injetando a dependência de autenticação
          final routerConfigurado = criarRouter(authNotifier);

          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'ConectaServ',
            // 7. Usamos o router que foi configurado com o ViewModel
            routerConfig: routerConfigurado, 
          );
        }
      ),
    );
  }
}