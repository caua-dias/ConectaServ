import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/presentation/notifiers/avaliacao_notifier.dart';
import '../../../models/presentation/notifiers/contratacao_notifier.dart';
import '../../../models/presentation/notifiers/servico_notifier.dart';
import '../../../models/presentation/notifiers/empresa_prestadora_notifier.dart';

import '../../../../models/avaliacao.dart';
import '../../../../models/enums.dart';

class ReviewsPage extends StatefulWidget {
  const ReviewsPage({super.key});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _filtroEstrelas = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Carregar todas as dependências necessárias do SQLite no arranque
    Future.microtask(() {
      if (mounted) {
        context.read<AvaliacaoNotifier>().buscarTodas();
        context.read<ContratacaoNotifier>().buscarTodas();
        context.read<ServicoNotifier>().buscarTodos();
        context.read<EmpresaPrestadoraNotifier>().buscarTodas();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatarNomeCategoria(Categoria cat) {
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

  // --- LÓGICA DE CRUZAMENTO DE DADOS ---

  // 1. Obter Avaliações Já Recebidas (Publicadas)
  List<Map<String, dynamic>> _getRecebidas() {
    final avaliacoes = context.watch<AvaliacaoNotifier>().avaliacoes;
    final contratacoes = context.watch<ContratacaoNotifier>().contratacoes;
    final servicos = context.watch<ServicoNotifier>().servicos;
    final empresas = context.watch<EmpresaPrestadoraNotifier>().empresas;

    List<Map<String, dynamic>> result = [];

    for (var av in avaliacoes) {
      // Procurar a contratação associada
      final contrato =
          _findFirst(contratacoes, (c) => c.idContratacao == av.idContratacao);
      if (contrato == null) continue;

      // Procurar o serviço
      final servico =
          _findFirst(servicos, (s) => s.idServico == contrato.idServico);
      if (servico == null) continue;

      // Procurar a empresa
      final empresa =
          _findFirst(empresas, (e) => e.idEmpresa == servico.idEmpresa);

      result.add({
        'id': av.idAvaliacao,
        'company':
            empresa?.nomeFantasia ?? empresa?.cnpj ?? 'Empresa Desconhecida',
        'emoji': empresa?.emoji ?? '🏢',
        'category': _formatarNomeCategoria(servico.categoria),
        'rating': av.estrelas,
        'date':
            'Recente', // Como o SQLite não tem data por defeito, usamos um placeholder
        'comment': av.comentarios ?? 'Sem comentários adicionais.',
        'helpful': 0, // Mock visual mantido
        'status': 'recebida',
      });
    }

    // Aplicar filtro de estrelas
    if (_filtroEstrelas == 0) return result;
    return result.where((a) => a['rating'] == _filtroEstrelas).toList();
  }

  // 2. Obter Avaliações Pendentes (Contratações sem Avaliação)
  List<Map<String, dynamic>> _getPendentes() {
    final avaliacoes = context.watch<AvaliacaoNotifier>().avaliacoes;
    final contratacoes = context.watch<ContratacaoNotifier>().contratacoes;
    final servicos = context.watch<ServicoNotifier>().servicos;
    final empresas = context.watch<EmpresaPrestadoraNotifier>().empresas;

    List<Map<String, dynamic>> result = [];

    for (var contrato in contratacoes) {
      // Verificar se já existe uma avaliação para esta contratação
      bool hasReview =
          avaliacoes.any((av) => av.idContratacao == contrato.idContratacao);
      if (hasReview) continue; // Se já tiver, não é pendente

      // Procurar o serviço
      final servico =
          _findFirst(servicos, (s) => s.idServico == contrato.idServico);
      if (servico == null) continue;

      // Procurar a empresa
      final empresa =
          _findFirst(empresas, (e) => e.idEmpresa == servico.idEmpresa);

      result.add({
        'idContratacao': contrato.idContratacao,
        'company':
            empresa?.nomeFantasia ?? empresa?.cnpj ?? 'Empresa Desconhecida',
        'emoji': empresa?.emoji ?? '🏢',
        'category': _formatarNomeCategoria(servico.categoria),
        'date': 'Pendente',
        'service': servico.descricao,
      });
    }

    return result;
  }

  // Função auxiliar segura para procurar o primeiro elemento compatível
  T? _findFirst<T>(List<T> list, bool Function(T) test) {
    try {
      return list.firstWhere(test);
    } catch (_) {
      return null;
    }
  }

  void _abrirFormAvaliacao(Map<String, dynamic> pendente) {
    int _stars = 0;
    final _ctrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(pendente['emoji'] as String,
                      style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Avaliar Empresa',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(pendente['company'] as String,
                            style: const TextStyle(
                                color: Color(0xFF64748B), fontSize: 13)),
                      ]),
                ]),
                const SizedBox(height: 20),
                const Text('Sua nota',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(
                      5,
                      (i) => GestureDetector(
                            onTap: () => setModalState(() => _stars = i + 1),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Icon(
                                i < _stars ? Icons.star : Icons.star_border,
                                color: const Color(0xFFF59E0B),
                                size: 36,
                              ),
                            ),
                          )),
                ),
                const SizedBox(height: 16),
                const Text('Comentário',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: _ctrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Descreva a sua experiência com esta empresa...',
                    hintStyle:
                        const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Color(0xFF2563EB), width: 2),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _stars == 0 || _ctrl.text.trim().isEmpty
                        ? null
                        : () async {
                            // Criar e salvar a avaliação no banco de dados real
                            final novaAvaliacao = Avaliacao(
                              idContratacao: pendente['idContratacao'],
                              estrelas: _stars,
                              comentarios: _ctrl.text.trim(),
                            );

                            await context
                                .read<AvaliacaoNotifier>()
                                .salvar(novaAvaliacao);

                            if (!mounted) return;
                            Navigator.pop(ctx);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('✅ Avaliação enviada com sucesso!'),
                                backgroundColor: Color(0xFF16A34A),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFE2E8F0),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Enviar Avaliação',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Monitorizar o estado de carregamento de todos os notifiers
    final bool carregando = context.watch<AvaliacaoNotifier>().carregando ||
        context.watch<ContratacaoNotifier>().carregando ||
        context.watch<ServicoNotifier>().carregando ||
        context.watch<EmpresaPrestadoraNotifier>().carregando;

    final listaRecebidas = carregando ? [] : _getRecebidas();
    final listaPendentes = carregando ? [] : _getPendentes();

    // Cálculo estatístico real para as métricas visuais
    double media = 0;
    int positivas = 0;
    if (listaRecebidas.isNotEmpty) {
      int totalEstrelas =
          listaRecebidas.fold(0, (sum, item) => sum + (item['rating'] as int));
      media = totalEstrelas / listaRecebidas.length;
      positivas =
          listaRecebidas.where((item) => (item['rating'] as int) >= 4).length;
    }
    String percentagemPositiva = listaRecebidas.isEmpty
        ? "0%"
        : "${((positivas / listaRecebidas.length) * 100).toStringAsFixed(0)}%";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: const Text('Avaliações',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Color(0xFF0F172A))),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(49),
          child: Column(
            children: [
              Divider(height: 1, color: Colors.grey[200]),
              TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF2563EB),
                unselectedLabelColor: const Color(0xFF64748B),
                indicatorColor: const Color(0xFF2563EB),
                indicatorWeight: 2,
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                tabs: [
                  Tab(text: 'Recebidas (${listaRecebidas.length})'),
                  Tab(text: 'Pendentes (${listaPendentes.length})'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // ── ABA RECEBIDAS ─────────────────────────────────
                Column(
                  children: [
                    // Filtro por estrelas
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _filtroChip(label: 'Todas', value: 0),
                            const SizedBox(width: 8),
                            ...List.generate(
                                5,
                                (i) => Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: _filtroChip(
                                          label: '${5 - i} ⭐', value: 5 - i),
                                    )),
                          ],
                        ),
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey[200]),

                    // Resumo rápido dinâmico
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _statCol(
                              listaRecebidas.isEmpty
                                  ? '-'
                                  : media.toStringAsFixed(1),
                              'Nota Média',
                              const Color(0xFFF59E0B)),
                          _dividerVertical(),
                          _statCol('${listaRecebidas.length}', 'Total',
                              const Color(0xFF2563EB)),
                          _dividerVertical(),
                          _statCol(percentagemPositiva, 'Positivas',
                              const Color(0xFF16A34A)),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey[200]),

                    Expanded(
                      child: listaRecebidas.isEmpty
                          ? _emptyState('Nenhuma avaliação encontrada',
                              Icons.star_outline)
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: listaRecebidas.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (ctx, i) {
                                final av = listaRecebidas[i];
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: const Color(0xFFE2E8F0)),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2))
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                                color: const Color(0xFFEFF6FF),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Center(
                                                child: Text(
                                                    av['emoji'] as String,
                                                    style: const TextStyle(
                                                        fontSize: 22))),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(av['company'] as String,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                          color: Color(
                                                              0xFF0F172A))),
                                                  Text(av['category'] as String,
                                                      style: const TextStyle(
                                                          color:
                                                              Color(0xFF64748B),
                                                          fontSize: 11)),
                                                ]),
                                          ),
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Row(
                                                    children: List.generate(
                                                        av['rating'] as int,
                                                        (_) => const Icon(
                                                            Icons.star,
                                                            color: Color(
                                                                0xFFF59E0B),
                                                            size: 13))),
                                                Text(av['date'] as String,
                                                    style: const TextStyle(
                                                        fontSize: 10,
                                                        color:
                                                            Color(0xFF94A3B8))),
                                              ]),
                                        ]),
                                        const SizedBox(height: 10),
                                        Text(av['comment'] as String,
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF475569),
                                                height: 1.4)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),

                // ── ABA PENDENTES ─────────────────────────────────
                listaPendentes.isEmpty
                    ? _emptyState('Nenhuma avaliação pendente',
                        Icons.check_circle_outline)
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: listaPendentes.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (ctx, i) {
                          final p = listaPendentes[i];
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0xFFFBBF24)),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2))
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                          color: const Color(0xFFFFFBEB),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Center(
                                          child: Text(p['emoji'] as String,
                                              style: const TextStyle(
                                                  fontSize: 22))),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(p['company'] as String,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: Color(0xFF0F172A))),
                                            Text(p['category'] as String,
                                                style: const TextStyle(
                                                    color: Color(0xFF64748B),
                                                    fontSize: 11)),
                                          ]),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFFBEB),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                            color: const Color(0xFFFBBF24)),
                                      ),
                                      child: const Text('Pendente',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFFD97706),
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  ]),
                                  const SizedBox(height: 8),
                                  Text('Serviço: ${p['service']}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF64748B))),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () => _abrirFormAvaliacao(p),
                                      icon: const Icon(
                                          Icons.rate_review_outlined,
                                          size: 16),
                                      label: const Text('Avaliar Agora',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF2563EB),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 11),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
    );
  }

  Widget _filtroChip({required String label, required int value}) {
    final selected = _filtroEstrelas == value;
    return GestureDetector(
      onTap: () => setState(() => _filtroEstrelas = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color:
                  selected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : const Color(0xFF475569))),
      ),
    );
  }

  Widget _statCol(String value, String label, Color color) {
    return Column(children: [
      Text(value,
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: color)),
      const SizedBox(height: 2),
      Text(label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
    ]);
  }

  Widget _dividerVertical() {
    return Container(height: 32, width: 1, color: const Color(0xFFE2E8F0));
  }

  Widget _emptyState(String msg, IconData icon) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 56, color: Colors.grey[300]),
        const SizedBox(height: 12),
        Text(msg,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 15)),
      ]),
    );
  }
}
