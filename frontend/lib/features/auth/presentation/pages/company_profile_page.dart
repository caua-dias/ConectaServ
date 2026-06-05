import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../models/presentation/notifiers/avaliacao_notifier.dart';
import '../../../models/presentation/notifiers/empresa_prestadora_notifier.dart';
import '../../../models/presentation/notifiers/servico_notifier.dart';
import '../../../models/presentation/notifiers/contratacao_notifier.dart';
import '../../../../models/empresa_prestadora.dart';
import '../../../../models/servico.dart';
import '../../../../models/avaliacao.dart';
import '../../../../models/contratacao.dart';
import '../../../../models/enums.dart';

class CompanyProfilePage extends StatefulWidget {
  final String companyId;
  const CompanyProfilePage({super.key, required this.companyId});

  @override
  State<CompanyProfilePage> createState() => _CompanyProfilePageState();
}

class _CompanyProfilePageState extends State<CompanyProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  EmpresaPrestadora? _empresa;
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregarDados());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    if (!mounted) return;
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final idEmpresa = int.tryParse(widget.companyId);
      if (idEmpresa == null) throw Exception('ID inválido');

      // Carrega empresa
      final empresa =
          await context.read<EmpresaPrestadoraNotifier>().buscarPorId(idEmpresa);
      // Carrega serviços da empresa
      await context.read<ServicoNotifier>().buscarPorEmpresa(idEmpresa);

      if (mounted) {
        setState(() {
          _empresa = empresa;
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _erro = 'Erro ao carregar dados da empresa.';
          _carregando = false;
        });
      }
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

  Color _tipoBg(Categoria cat) => _tipoColor(cat).withOpacity(0.1);

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

  String _statusLabel(StatusCuradoria status) {
    switch (status) {
      case StatusCuradoria.aprovada:
        return 'Aprovada';
      case StatusCuradoria.emAnalise:
        return 'Em análise';
      case StatusCuradoria.reprovada:
        return 'Reprovada';
    }
  }

  Color _statusColor(StatusCuradoria status) {
    switch (status) {
      case StatusCuradoria.aprovada:
        return const Color(0xFF16A34A);
      case StatusCuradoria.emAnalise:
        return const Color(0xFFD97706);
      case StatusCuradoria.reprovada:
        return const Color(0xFFDC2626);
    }
  }

  void _confirmarContratacao(Servico servico) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _tipoBg(servico.categoria),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.build_outlined,
                      color: _tipoColor(servico.categoria)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(servico.descricao,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      Text(
                        'R\$ ${servico.preco.toStringAsFixed(2).replaceAll('.', ',')}',
                        style: const TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Deseja confirmar a contratação deste serviço?',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      // Registra contratação no banco com status pendente
                      await context.read<ContratacaoNotifier>().salvar(
                            Contratacao(
                              idCliente: 1, // TODO: obter ID do usuário logado
                              idServico: servico.idServico!,
                              statusPagamento: StatusPagamento.pendente,
                            ),
                          );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '✅ Solicitação enviada para ${_empresa?.cnpj ?? 'empresa'}!'),
                            backgroundColor: const Color(0xFF16A34A),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Confirmar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── BUILD ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_erro != null || _empresa == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 56, color: Colors.grey),
              const SizedBox(height: 12),
              Text(_erro ?? 'Empresa não encontrada',
                  style: const TextStyle(color: Color(0xFF64748B))),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _carregarDados,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    final empresa = _empresa!;

    return Consumer3<ServicoNotifier, AvaliacaoNotifier,
        EmpresaPrestadoraNotifier>(
      builder: (context, servicoNotifier, avaliacaoNotifier, empresaNotifier,
          child) {
        final servicos = servicoNotifier.servicos;
        final avaliacoes = avaliacaoNotifier.avaliacoes;

        // Média das avaliações
        final double mediaAvaliacoes = avaliacoes.isEmpty
            ? 0.0
            : avaliacoes.map((a) => a.estrelas).reduce((a, b) => a + b) /
                avaliacoes.length;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: NestedScrollView(
            headerSliverBuilder: (ctx, innerBoxScrolled) => [
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go('/'),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20, 56, 20, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Center(
                                    child: Text('🏢',
                                        style: TextStyle(fontSize: 32)),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'CNPJ: ${empresa.cnpj}',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color:
                                              Colors.white.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          _statusLabel(
                                              empresa.statusCuradoria),
                                          style: TextStyle(
                                            color: _statusColor(
                                                empresa.statusCuradoria),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(children: [
                                        const Icon(Icons.star,
                                            color: Color(0xFFFBBF24),
                                            size: 14),
                                        const SizedBox(width: 2),
                                        Text(
                                          mediaAvaliacoes > 0
                                              ? mediaAvaliacoes
                                                  .toStringAsFixed(1)
                                              : empresa.reputacao,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13),
                                        ),
                                        Text(
                                          ' (${avaliacoes.length} avaliações)',
                                          style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 11),
                                        ),
                                      ]),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.mail_outline,
                                      size: 16),
                                  label: const Text('Contato',
                                      style: TextStyle(fontSize: 13)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor:
                                        const Color(0xFF2563EB),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.phone_outlined,
                                      size: 16, color: Colors.white),
                                  label: const Text('Ligar',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.white)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        color: Colors.white54),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                  ),
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: Container(
                    color: Colors.white,
                    child: TabBar(
                      controller: _tabController,
                      labelColor: const Color(0xFF2563EB),
                      unselectedLabelColor: const Color(0xFF64748B),
                      indicatorColor: const Color(0xFF2563EB),
                      indicatorWeight: 2,
                      labelStyle: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13),
                      tabs: [
                        Tab(
                            text:
                                'Serviços (${servicos.length})'),
                        const Tab(text: 'Sobre'),
                        Tab(text: 'Avaliações (${avaliacoes.length})'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                // ── ABA SERVIÇOS ─────────────────────────────────────────────
                servicoNotifier.carregando
                    ? const Center(child: CircularProgressIndicator())
                    : servicos.isEmpty
                        ? _emptyState(
                            'Nenhum serviço cadastrado',
                            Icons.build_circle_outlined)
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: servicos.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (ctx, i) {
                              final s = servicos[i];
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: const Color(0xFFE2E8F0)),
                                  boxShadow: [
                                    BoxShadow(
                                        color:
                                            Colors.black.withOpacity(0.04),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2)),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: _tipoBg(s.categoria),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      10),
                                            ),
                                            child: Icon(
                                                Icons.build_outlined,
                                                color: _tipoColor(
                                                    s.categoria),
                                                size: 22),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  s.descricao,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                      color: Color(
                                                          0xFF0F172A)),
                                                ),
                                                const SizedBox(height: 4),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 7,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        _tipoBg(s.categoria),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: Text(
                                                    _categoriaLabel(
                                                        s.categoria),
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        color: _tipoColor(
                                                            s.categoria),
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            'R\$ ${s.preco.toStringAsFixed(2).replaceAll('.', ',')}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: Color(0xFF2563EB)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () =>
                                              _confirmarContratacao(s),
                                          icon: const Icon(
                                              Icons.handshake_outlined,
                                              size: 16),
                                          label: const Text(
                                              'Contratar Serviço',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.w600)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF2563EB),
                                            foregroundColor: Colors.white,
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 12),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        8)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                // ── ABA SOBRE ────────────────────────────────────────────────
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _infoCard('Informações da Empresa', [
                        _infoRow(Icons.badge_outlined, 'CNPJ',
                            empresa.cnpj),
                        _infoRow(Icons.verified_outlined, 'Status de Curadoria',
                            _statusLabel(empresa.statusCuradoria)),
                        _infoRow(Icons.star_outline, 'Reputação',
                            empresa.reputacao),
                      ]),
                      const SizedBox(height: 12),
                      _infoCard('Serviços disponíveis', [
                        _infoRow(Icons.build_outlined, 'Total de serviços',
                            '${servicos.length}'),
                        if (servicos.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: servicos
                                .map((s) => s.categoria)
                                .toSet()
                                .map((cat) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: _tipoBg(cat),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                        border: Border.all(
                                            color: _tipoColor(cat)
                                                .withOpacity(0.4)),
                                      ),
                                      child: Text(
                                        _categoriaLabel(cat),
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: _tipoColor(cat),
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                      ]),
                    ],
                  ),
                ),

                // ── ABA AVALIAÇÕES ────────────────────────────────────────────
                avaliacaoNotifier.carregando
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Resumo
                            if (avaliacoes.isNotEmpty) ...[
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: const Color(0xFFE2E8F0)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            mediaAvaliacoes
                                                .toStringAsFixed(1),
                                            style: const TextStyle(
                                                fontSize: 40,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF0F172A)),
                                          ),
                                          Row(
                                              children: List.generate(
                                                  5,
                                                  (i) => Icon(
                                                        i <
                                                                mediaAvaliacoes
                                                                    .round()
                                                            ? Icons.star
                                                            : Icons
                                                                .star_outline,
                                                        color: const Color(
                                                            0xFFF59E0B),
                                                        size: 16,
                                                      ))),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${avaliacoes.length} avaliações',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF64748B)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: Column(
                                          children: [5, 4, 3, 2, 1].map((s) {
                                            final count = avaliacoes
                                                .where((a) =>
                                                    a.estrelas == s)
                                                .length;
                                            final pct = avaliacoes.isEmpty
                                                ? 0.0
                                                : count /
                                                    avaliacoes.length;
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 2),
                                              child: Row(children: [
                                                Icon(Icons.star,
                                                    color: const Color(
                                                        0xFFF59E0B),
                                                    size: 12),
                                                const SizedBox(width: 4),
                                                Text('$s',
                                                    style: const TextStyle(
                                                        fontSize: 11,
                                                        color: Color(
                                                            0xFF64748B))),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            2),
                                                    child:
                                                        LinearProgressIndicator(
                                                      value: pct,
                                                      minHeight: 6,
                                                      backgroundColor:
                                                          const Color(
                                                              0xFFE2E8F0),
                                                      valueColor:
                                                          const AlwaysStoppedAnimation(
                                                              Color(
                                                                  0xFFF59E0B)),
                                                    ),
                                                  ),
                                                ),
                                              ]),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Lista de avaliações
                            if (avaliacoes.isEmpty)
                              _emptyState(
                                  'Nenhuma avaliação ainda',
                                  Icons.rate_review_outlined)
                            else
                              ...avaliacoes.map((av) => Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 12),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        border: Border.all(
                                            color:
                                                const Color(0xFFE2E8F0)),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(14),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(children: [
                                              CircleAvatar(
                                                radius: 18,
                                                backgroundColor:
                                                    const Color(0xFFEFF6FF),
                                                child: Text(
                                                  'C${av.idContratacao}',
                                                  style: const TextStyle(
                                                      color:
                                                          Color(0xFF2563EB),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 11),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                  children: [
                                                    Text(
                                                      'Contratação #${av.idContratacao}',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 13),
                                                    ),
                                                    Text(
                                                      'Avaliação #${av.idAvaliacao ?? '—'}',
                                                      style: const TextStyle(
                                                          color: Color(
                                                              0xFF64748B),
                                                          fontSize: 11),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Row(
                                                    children: List.generate(
                                                      av.estrelas,
                                                      (_) => const Icon(
                                                          Icons.star,
                                                          color: Color(
                                                              0xFFF59E0B),
                                                          size: 13),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ]),
                                            if (av.comentarios != null &&
                                                av.comentarios!
                                                    .isNotEmpty) ...[
                                              const SizedBox(height: 8),
                                              Text(
                                                av.comentarios!,
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Color(0xFF475569),
                                                    height: 1.4),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  )),
                          ],
                        ),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoCard(String title, List<Widget> rows) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF0F172A))),
            const SizedBox(height: 12),
            ...rows,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF64748B)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF94A3B8))),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0F172A))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String msg, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            Icon(icon, size: 56, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(msg,
                style: const TextStyle(
                    color: Color(0xFF64748B), fontSize: 15)),
          ],
        ),
      ),
    );
  }
}