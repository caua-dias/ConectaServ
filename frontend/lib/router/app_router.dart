import 'package:go_router/go_router.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_screen.dart';
import '../features/auth/presentation/pages/service_screen.dart';
import '../features/auth/presentation/pages/raiting_screen.dart';
import '../features/auth/presentation/pages/register_client_screen.dart';
import '../features/auth/presentation/pages/register_company_screen.dart';
import '../features/auth/presentation/pages/home_page.dart';
import '../features/auth/presentation/pages/recover_password_page.dart';

import '../features/auth/auth_service.dart'; 

final GoRouter router = GoRouter(
    initialLocation: '/', 
    refreshListenable: authService, // Ouve as mudanças de login/logout
    redirect: (context, state) {
      final isAuth = authService.isAuthenticated;
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToHome = state.matchedLocation == '/' || state.matchedLocation == '/home';
      final isGoingToRegister = state.matchedLocation.startsWith('/register');

      if (!isAuth && !isGoingToHome && !isGoingToLogin && !isGoingToRegister) {
        return '/login'; 
      }

      if (isAuth && isGoingToLogin) {
        return '/'; 
      }

      // Nenhuma ação necessária, segue o fluxo normal da rota
      return null; 
    },
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
            path: '/login', 
            builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
            path: '/register',
            builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
            path: '/service',
            builder: (context, state) => const ServiceScreen(),
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
            path: '/raiting',
            builder: (context, state) => const RaitingScreen(),
        ),
        GoRoute(
            path: '/recover_password',
            builder: (context, state) => const RecoverPasswordPage(),
        )
    ],
);