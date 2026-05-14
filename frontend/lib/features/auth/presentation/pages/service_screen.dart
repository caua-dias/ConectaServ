import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../auth_notifier.dart';

class ServiceScreen extends StatefulWidget {
  const ServiceScreen({super.key});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  bool _visivel = false;

  @override
  void initState() {
    super.initState();
    // Dispara a animação após o primeiro frame
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _visivel = true);
    });
  }

  /// Widget helper para fade-in escalonado, exatamente como na LoginPage
  Widget _fadeIn({required Widget child, required int ordem}) {
    return AnimatedOpacity(
      opacity: _visivel ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _visivel ? Offset.zero : const Offset(0, 0.08),
        duration: Duration(milliseconds: 500 + (ordem * 120)),
        curve: Curves.easeOut,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Serviços',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _fadeIn(
                  ordem: 1,
                  child: Text(
                    'Gestão de marketing digital',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 32),

                // Imagem com Scale igual ao logo do Login
                AnimatedScale(
                  scale: _visivel ? 1.0 : 0.6,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  child: AnimatedOpacity(
                    opacity: _visivel ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 400),
                    child: Container(
                      height: 160,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTOHNDctaIc4YYGBgh55wsNSkZogf9RYmaVkA&s',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                _fadeIn(
                  ordem: 2,
                  child: Text(
                    'Descrição',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 8),
                _fadeIn(
                  ordem: 3,
                  child: Container(
                    height: 140, // Aumentado um pouco para caber melhor o texto
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300), // Estética alinhada aos TextFields
                      color: Colors.grey.shade50,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Text(
                        'Somos uma empresa especializada em gestão de marketing digital, oferecendo soluções personalizadas para impulsionar a presença online de nossos clientes. Com uma equipe experiente e dedicada, trabalhamos para criar estratégias eficazes que aumentam a visibilidade, engajamento e conversões. Nossos serviços incluem gerenciamento de redes sociais, criação de conteúdo, campanhas publicitárias e análise de desempenho, tudo com o objetivo de ajudar nossos clientes a alcançar seus objetivos de negócios.',
                        textAlign: TextAlign.justify,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                _fadeIn(
                  ordem: 4,
                  child: Text(
                    'Preço do serviço',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 8),
                _fadeIn(
                  ordem: 5,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                      color: Colors.grey.shade50,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'R\$ 150,00',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                _fadeIn(
                  ordem: 6,
                  child: ElevatedButton(
                    onPressed: () {}, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Mantido verde vibrante como pedido
                      foregroundColor: Colors.white, 
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), 
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Comprar',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Home selecionada por padrão
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            context.go('/home'); // Vai para a própria landing page
          } else if (index == 1) {
            context.go('/raiting'); // rota para a pagina de avaliação
          } else if (index == 2) {
            print('Ir para Perfil (Rota não criada)');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_outline), // Ícone alterado conforme pedido
            label: 'Avaliações',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Conta',
          ),
        ],
      ),
    );
  }
}