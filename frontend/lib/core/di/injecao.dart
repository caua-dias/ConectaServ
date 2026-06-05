import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';

// --- NOVAS IMPORTAÇÕES PARA A AUTENTICAÇÃO REAL ---
import '../../core/http_client.dart';
import '../../data/services/auth_service.dart';
// --------------------------------------------------

import '../../features/models/presentation/notifiers/cliente_notifier.dart';
import '../../features/models/presentation/notifiers/servico_notifier.dart';
import '../../features/models/presentation/notifiers/contratacao_notifier.dart';
import '../../features/models/presentation/notifiers/empresa_prestadora_notifier.dart';
import '../../features/models/presentation/notifiers/projeto_portfolio_notifier.dart';
import '../../features/models/presentation/notifiers/avaliacao_notifier.dart';
import '../../core/database/database_helper.dart';
import '../../infrastructure/repositories/sqflite_cliente_repository.dart';
import '../../infrastructure/repositories/sqflite_contratacao_repository.dart';
import '../../infrastructure/repositories/sqflite_empresa_prestadora_repository.dart';
import '../../infrastructure/repositories/sqflite_projeto_portfolio_repository.dart';
import '../../infrastructure/repositories/sqflite_servico_repository.dart';
import '../../infrastructure/repositories/sqflite_avaliacao_repository.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> setupDependencies() async {
  // --- CORE / HTTP ---
  // Registamos o HttpClient primeiro porque o AuthService precisa dele
  sl.registerLazySingleton<HttpClient>(() => HttpClient(baseUrl: 'http://10.0.2.2:8080'));

  // --- SERVIÇOS ---
  // Agora injetamos o HttpClient no AuthService real
  sl.registerLazySingleton<AuthService>(() => AuthService(sl<HttpClient>()));

  // Database - aguardar inicialização
  final db = await DatabaseHelper.instance.db;

  // --- REPOSITÓRIOS ---
  sl.registerLazySingleton<SqfliteClienteRepository>(
    () => SqfliteClienteRepository(db),
  );
  
  sl.registerLazySingleton<SqfliteContratacaoRepository>(
    () => SqfliteContratacaoRepository(db),
  );
  
  sl.registerLazySingleton<SqfliteEmpresaPrestadoraRepository>(
    () => SqfliteEmpresaPrestadoraRepository(db),
  );
  
  sl.registerLazySingleton<SqfliteProjetoPortfolioRepository>(
    () => SqfliteProjetoPortfolioRepository(db),
  );
  
  sl.registerLazySingleton<SqfliteServicoRepository>(
    () => SqfliteServicoRepository(db),
  );

  sl.registerLazySingleton<SqfliteAvaliacaoRepository>(
    () => SqfliteAvaliacaoRepository(db),
  );

  // --- NOTIFIERS ---
  sl.registerLazySingleton<ClienteNotifier>(
    () => ClienteNotifier(sl<SqfliteClienteRepository>()),
  );

  sl.registerLazySingleton<ServicoNotifier>(
    () => ServicoNotifier(sl<SqfliteServicoRepository>()),
  );

  sl.registerLazySingleton<ContratacaoNotifier>(
    () => ContratacaoNotifier(sl<SqfliteContratacaoRepository>()),
  );

  sl.registerLazySingleton<EmpresaPrestadoraNotifier>(
    () => EmpresaPrestadoraNotifier(sl<SqfliteEmpresaPrestadoraRepository>()),
  );

  sl.registerLazySingleton<ProjetoPortfolioNotifier>(
    () => ProjetoPortfolioNotifier(sl<SqfliteProjetoPortfolioRepository>()),
  );

  sl.registerLazySingleton<AvaliacaoNotifier>(
    () => AvaliacaoNotifier(sl<SqfliteAvaliacaoRepository>()),
  );
}