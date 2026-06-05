import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../models/presentation/notifiers/servico_notifier.dart';
import '../../../../models/servico.dart';
import '../../../../models/enums.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _visivel = false;
  late ScrollController _categoryScrollController;

  @override
  void initState() {
    super.initState();
    
    // Dispara a animação de fade-in gradual
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _visivel = true);
    });
    
    // Carrega os serviços reais do banco SQLite
    Future.microtask(
      () => context.read<ServicoNotifier>().buscarTodos(),
    );

    // Configuração para o carrossel infinito de categorias:
    // Define um tamanho virtual massivo e inicializa o scroll exatamente no meio.
    const int virtualCount = 10000;
    final int actualCount = Categoria.values.length;
    final int middleIndex = virtualCount ~/ 2;
    final int initialIndex = middleIndex - (middleIndex % actualCount);
    const double estimatedChipWidth = 130.0; // Largura média estimada de cada Chip

    _categoryScrollController = ScrollController(
      initialScrollOffset: initialIndex * estimatedChipWidth,
    );
  }

  @override
  void dispose() {
    _categoryScrollController.dispose();
    super.dispose();
  }

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

  IconData _tipoIcon(Categoria cat) {
    switch (cat) {
      case Categoria.consultoria:
        return Icons.pie_chart_outline;
      case Categoria.desenvolvimento:
        return Icons.code_outlined;
      case Categoria.design:
        return Icons.brush_outlined;
      case Categoria.suporte:
        return Icons.support_agent_outlined;
      case Categoria.marketing:
        return Icons.trending_up_outlined;
      case Categoria.outros:
        return Icons.miscellaneous_services_outlined;
    }
  }

  Color _tipoColor(Categoria cat) {
    switch (cat) {
      case Categoria.consultoria:
        return const Color(0xFF7C3AED);
      case Categoria.desenvolvimento:
        return const Color(0xFF2563EB);
      case Categoria.design:
        return const Color(0xFFDB2777);
      case Categoria.suporte:
        return const Color(0xFF0891B2);
      case Categoria.marketing:
        return const Color(0xFFD97706);
      case Categoria.outros:
        return const Color(0xFF16A34A);
    }
  }

  String _categoriaLabel(Categoria cat) {
    switch (cat) {
      case Categoria.consultoria:
        return 'Consultoria';
      case Categoria.desenvolvimento:
        return 'Desenvolvimento';
      case Categoria.design:
        return 'Design';
      case Categoria.suporte:
        return 'Suporte';
      case Categoria.marketing:
        return 'Marketing';
      case Categoria.outros:
        return 'Outros';
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicoNotifier = context.watch<ServicoNotifier>();
    final realServices = servicoNotifier.servicos;

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
          currentIndex: 0, 
          onTap: (index) {
            if (index == 0) {
              context.go('/home'); 
            } else if (index == 1) {
              context.go('/busca'); 
            } else if (index == 2) {
              context.go('/configuracoes');
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Config.'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // CABEÇALHO FIXO
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _fadeIn(
                ordem: 1, 
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                    Text(
                      'ConectaServ',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.blueAccent),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_none_outlined),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),

            // CONTEÚDO ROLÁVEL
            Expanded(
              child: servicoNotifier.carregando
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 16),

                          // Barra de pesquisa funcional direcionando para a busca
                          _fadeIn(
                            ordem: 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: GestureDetector(
                                onTap: () => context.go('/busca'),
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
                                        'Buscar empresas, serviços...',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Nichos Famosos (Carrossel Horizontal Infinito Real)
                          _fadeIn(
                            ordem: 3,
                            child: SizedBox(
                              height: 40,
                              child: ListView.builder(
                                controller: _categoryScrollController,
                                scrollDirection: Axis.horizontal,
                                itemCount: 10000,
                                itemBuilder: (ctx, index) {
                                  final categorias = Categoria.values;
                                  final cat = categorias[index % categorias.length];
                                  final label = _categoriaLabel(cat);
                                  
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                    child: GestureDetector(
                                      onTap: () => context.go('/busca?categoria=${cat.name}'),
                                      child: Chip(
                                        backgroundColor: Colors.white,
                                        label: Text(label),
                                        side: BorderSide(color: Colors.grey[300]!),
                                        labelStyle: const TextStyle(color: Colors.black87),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Seção: Mais procurados
                          _fadeIn(
                              ordem: 4,
                              child: const Center(
                                  child: Text('Mais procurados',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)))),
                          const SizedBox(height: 16),
                          _buildServiceCarousel(realServices),
                          const SizedBox(height: 32),

                          // Seção: Promoções / Destaques
                          _fadeIn(
                              ordem: 6,
                              child: const Center(
                                  child: Text('Promoções / Destaques',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)))),
                          const SizedBox(height: 16),
                          _buildServiceCarousel(realServices.reversed.toList()),

                          const SizedBox(height: 40), 
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCarousel(List<Servico> services) {
    if (services.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: Text(
            'Nenhum serviço disponível no momento.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      );
    }

    final int actualCount = services.length;
    const int virtualCount = 10000;
    // Centraliza o PageView para permitir rolagem infinita imediata para a esquerda ou direita
    final int initialPage = (virtualCount ~/ 2) - ((virtualCount ~/ 2) % actualCount);

    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.85, initialPage: initialPage),
        itemCount: virtualCount,
        itemBuilder: (ctx, index) {
          final servico = services[index % actualCount];
          final color = _tipoColor(servico.categoria);
          final icon = _tipoIcon(servico.categoria);
          final labelCategoria = _categoriaLabel(servico.categoria);

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(icon, size: 24, color: color),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            labelCategoria,
                            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      servico.descricao,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'R\$ ${servico.preco.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        TextButton(
                          onPressed: () => context.push('/service/${servico.idServico}'),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                          child: const Text('ver detalhes', style: TextStyle(color: Colors.blueAccent, fontSize: 12)),
                        ),
                      ],
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