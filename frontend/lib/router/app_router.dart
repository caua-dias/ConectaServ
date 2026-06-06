import 'package:go_router/go_router.dart';

import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_screen.dart';
import '../features/auth/presentation/pages/service_screen.dart';
import '../features/auth/presentation/pages/raiting_screen.dart';
import '../features/auth/presentation/pages/register_client_screen.dart';
import '../features/auth/presentation/pages/register_company_screen.dart';
import '../features/auth/presentation/pages/home_page.dart';
import '../features/auth/presentation/pages/recover_password_page.dart';
import '../features/auth/presentation/pages/app_shell.dart';
import '../features/auth/presentation/pages/search_results_page.dart';
import '../features/auth/presentation/pages/company_profile_page.dart';
import '../features/auth/presentation/pages/reviews_page.dart';
import '../features/auth/presentation/pages/settings_page.dart';
import '../features/auth/presentation/pages/register_service_page.dart';

import '../features/models/presentation/notifiers/auth_notifier.dart';

GoRouter criarRouter(AuthNotifier authNotifier) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final isAuth = authNotifier.isAuthenticated;
      final loc = state.matchedLocation;
      final isGoingToLogin = loc == '/login';
      final isGoingToHome = loc == '/' || loc == '/home';
      final isGoingToRegister = loc.startsWith('/register');
      final isGoingToRecover = loc == '/recover_password';

      if (!isAuth &&
          !isGoingToHome &&
          !isGoingToLogin &&
          !isGoingToRegister &&
          !isGoingToRecover) {
        return '/login';
      }

      if (isAuth && isGoingToLogin) {
        return '/';
      }

      return null;
    },
    routes: [
      // ── Shell com BottomNavigationBar ──────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/busca',
            builder: (context, state) {
              final q = state.uri.queryParameters['q'];
              final cat = state.uri.queryParameters['categoria'];
              return SearchResultsPage(query: q, categoria: cat);
            },
          ),
          GoRoute(
            path: '/avaliacoes',
            builder: (context, state) => const ReviewsPage(),
          ),
          GoRoute(
            path: '/configuracoes',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),

      // ── Rotas sem BottomNavigationBar ──────────────────────────────────────
      GoRoute(
        path: '/empresa/:id',
        builder: (context, state) => CompanyProfilePage(
          companyId: state.pathParameters['id'] ?? '1',
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/register_client',
        builder: (context, state) => const RegisterClientScreen(),
      ),
      GoRoute(
        path: '/register_company',
        builder: (context, state) => const RegisterCompanyScreen(),
      ),
      GoRoute(
        path: '/service/:id',
        builder: (context, state) {
          final serviceId = state.pathParameters['id'] ?? '';
          return ServiceScreen(id: serviceId);
        },
      ),
      GoRoute(
        path: '/raiting',
        builder: (context, state) => const RaitingScreen(),
      ),
      GoRoute(
        path: '/recover_password',
        builder: (context, state) => const RecoverPasswordPage(),
      ),
      GoRoute(
        path: '/novo_servico',
        builder: (context, state) => const RegisterServicePage(),
      ),
    ],
  );
}
