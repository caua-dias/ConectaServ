import 'package:go_router/go_router.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_screen.dart';

final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
        // GoRoute define uma rota com um path (URL) e um builder (widget a exibir).
        GoRoute(
            path: '/',
            builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
            path: '/register',
            builder: (context, state) => const RegisterScreen(),
        ),
    ],
);