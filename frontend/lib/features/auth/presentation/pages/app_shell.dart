import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shell que envolve as páginas principais e exibe o [BottomNavigationBar].
///
/// Rotas gerenciadas por este shell:
/// - `/`            → HomePage
/// - `/busca`       → SearchResultsPage
/// - `/avaliacoes`  → ReviewsPage
/// - `/configuracoes` → SettingsPage
class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/busca')) return 1;
    if (location.startsWith('/avaliacoes')) return 2;
    if (location.startsWith('/configuracoes')) return 3;
    return 0; // home e qualquer outra rota dentro do shell
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[200]!)),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: const Color(0xFF2563EB),
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          currentIndex: index,
          onTap: (i) {
            switch (i) {
              case 0:
                context.go('/');
                break;
              case 1:
                context.go('/busca');
                break;
              case 2:
                context.go('/avaliacoes');
                break;
              case 3:
                context.go('/configuracoes');
                break;
              case 4:
                context.go('/novo_servico');
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Início',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: 'Buscar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star_outline),
              activeIcon: Icon(Icons.star),
              label: 'Avaliações',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Config.',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_outlined),
              activeIcon: Icon(Icons.add),
              label: 'Novo Serviço',
            ),
          ],
        ),
      ),
    );
  }
}
