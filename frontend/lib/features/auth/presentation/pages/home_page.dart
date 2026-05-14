import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../auth_notifier.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  bool _visivel = false;

  @override
  void initState() {
    super.initState();
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _visivel = true);
    });
  }

  Widget _fadeIn({required Widget child, required int ordem}) {
    return AnimatedOpacity(
      opacity: _visivel ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      // Cada item atrasa 120ms a mais que o anterior
      child: AnimatedSlide(
        offset: _visivel ? Offset.zero : const Offset(0, 0.08),
        duration: Duration(milliseconds: 500 + (ordem * 120)),
        curve: Curves.easeOut,
        child: child,
      ),
    );
  }
  // ---------------------------------------------------

  // Dados Fakes para preencher a tela
  final List<String> _nichos = [
    'Marketing',
    'Elétrica',
    'Conserto de aparelhos',
    'Limpeza',
    'Encanador',
    'Aulas',
  ];

  final List<Map<String, dynamic>> _servicos = [
    {
      'titulo': 'Copywrite para posts de instagram',
      'icon': Icons.edit_note_outlined,
      'nota': 4.8,
      'avaliacoes': 120,
    },
    {
      'titulo': 'Análise de dados avançada',
      'icon': Icons.analytics_outlined,
      'nota': 4.9,
      'avaliacoes': 85,
    },
    {
      'titulo': 'Design de Logo Profissional',
      'icon': Icons.brush_outlined,
      'nota': 4.7,
      'avaliacoes': 210,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
  
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[200]!)),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          currentIndex: 0, // Home selecionada por padrão
          onTap: (index) {
            if (index == 0) {
              context.go('/home'); // Vai para a própria landing page
            } else if (index == 1) {
              context.go('/service'); // Rota existente
            } else if (index == 2) {
              print('Ir para Perfil (Rota não criada)');
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.build_circle_outlined), label: 'Serviços'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline), label: 'Conta'),
          ],
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // 2. CABEÇALHO (Fixo no topo, animação rápida)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _fadeIn(
                ordem: 1, // Primeiro elemento a aparecer
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Esquerda: Localização
                    Row(
                      children: const [
                        Icon(Icons.location_on_outlined, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          'São Paulo - SP',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    // Centro (relativo): Nome do projeto
                    Text(
                      'ConectaServ',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.blueAccent),
                    ),
                    // Direita: Ícone de notificação
                    IconButton(
                      icon: const Icon(Icons.notifications_none_outlined),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),

            // 3. BODY (Conteúdo rolável)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // --- Barra de pesquisa ---
                    _fadeIn(
                      ordem: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.search, color: Colors.grey),
                              SizedBox(width: 8),
                              Text(
                                'Barra de pesquisa',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- Nichos famosos (Carrossel Horizontal) ---
                    _fadeIn(
                      ordem: 3,
                      child: SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _nichos.length,
                          separatorBuilder: (ctx, i) =>
                              const SizedBox(width: 10),
                          itemBuilder: (ctx, index) {
                            return Chip(
                              backgroundColor: Colors.white,
                              label: Text(_nichos[index]),
                              side: BorderSide(color: Colors.grey[300]!),
                              labelStyle: const TextStyle(color: Colors.black87),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- Mais procurados ---
                    _fadeIn(
                        ordem: 4,
                        child: const Center(
                            child: Text('Mais procurados',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)))),
                    const SizedBox(height: 16),
                    _fadeIn(ordem: 5, child: _buildServiceCarousel()),
                    const SizedBox(height: 32),

                    // --- Promoções / Destaques ---
                    _fadeIn(
                        ordem: 6,
                        child: const Center(
                            child: Text('Promoções / Destaques',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)))),
                    const SizedBox(height: 16),
                    _fadeIn(ordem: 7, child: _buildServiceCarousel()),

                    const SizedBox(height: 40), // Espaço no final para rolar
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper para criar os carrosséis de serviços
  Widget _buildServiceCarousel() {
    return SizedBox(
      height: 180, // Altura do card baseada no esboço
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.85), // Mostra um pedaço do próximo
        itemCount: _servicos.length,
        itemBuilder: (ctx, index) {
          final servico = _servicos[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Linha superior: Ícone e Nota
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(servico['icon'], size: 40, color: Colors.grey[700]),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text('${servico['nota']}'),
                            Text(' (${servico['avaliacoes']})',
                                style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Título do serviço específico
                    Text(
                      servico['titulo'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Botão Ver detalhes (como no esboço)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                        child: const Text('ver detalhes', style: TextStyle(color: Colors.blueAccent, fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}