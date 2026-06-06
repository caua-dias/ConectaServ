import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

import 'router/app_router.dart';
import 'core/di/injecao.dart';

import 'features/models/presentation/notifiers/auth_notifier.dart';
import 'features/models/presentation/notifiers/cliente_notifier.dart';
import 'features/models/presentation/notifiers/servico_notifier.dart';
import 'features/models/presentation/notifiers/contratacao_notifier.dart';
import 'features/models/presentation/notifiers/empresa_prestadora_notifier.dart';
import 'features/models/presentation/notifiers/projeto_portfolio_notifier.dart';
import 'features/models/presentation/notifiers/avaliacao_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  await setupDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // AuthNotifier agora é inicializado vazio (sem serviços HTTP injetados)
        ChangeNotifierProvider(create: (_) => AuthNotifier()),

        ChangeNotifierProvider(create: (_) => ClienteNotifier(sl())),
        ChangeNotifierProvider(create: (_) => ServicoNotifier(sl())),
        ChangeNotifierProvider(create: (_) => ContratacaoNotifier(sl())),
        ChangeNotifierProvider(create: (_) => EmpresaPrestadoraNotifier(sl())),
        ChangeNotifierProvider(create: (_) => ProjetoPortfolioNotifier(sl())),
        ChangeNotifierProvider(create: (_) => AvaliacaoNotifier(sl())),
      ],
      child: Builder(builder: (appContext) {
        final authNotifier = appContext.read<AuthNotifier>();
        final routerConfigurado = criarRouter(authNotifier);

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'ConectaServ',
          routerConfig: routerConfigurado,
        );
      }),
    );
  }
}
