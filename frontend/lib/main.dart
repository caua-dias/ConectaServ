import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

import 'router/app_router.dart';
import 'core/di/injecao.dart';
import 'features/models/presentation/notifiers/auth_notifier.dart';
import 'features/auth/auth_service.dart';
import 'features/models/presentation/notifiers/cliente_notifier.dart';
import 'features/models/presentation/notifiers/servico_notifier.dart';
import 'features/models/presentation/notifiers/contratacao_notifier.dart';
import 'features/models/presentation/notifiers/empresa_prestadora_notifier.dart';
import 'features/models/presentation/notifiers/projeto_portfolio_notifier.dart';
import 'features/models/presentation/notifiers/avaliacao_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  
  // 1. Inicializa o GetIt antes de iniciar a interface do app (aguardando Database)
  await setupDependencies(); 
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Envolvemos a aplicação inteira com o MultiProvider
    return MultiProvider(
      providers: [
        // Auth
        ChangeNotifierProvider(
          create: (_) => AuthNotifier(sl<AuthService>()),
        ),
        // Models
        ChangeNotifierProvider(
          create: (_) => ClienteNotifier(sl()),
        ),
        ChangeNotifierProvider(
          create: (_) => ServicoNotifier(sl()),
        ),
        ChangeNotifierProvider(
          create: (_) => ContratacaoNotifier(sl()),
        ),
        ChangeNotifierProvider(
          create: (_) => EmpresaPrestadoraNotifier(sl()),
        ),
        ChangeNotifierProvider(
          create: (_) => ProjetoPortfolioNotifier(sl()),
        ),
        ChangeNotifierProvider(
          create: (_) => AvaliacaoNotifier(sl()),
        ),
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