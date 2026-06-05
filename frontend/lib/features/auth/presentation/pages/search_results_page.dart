import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import '../../../models/presentation/notifiers/empresa_prestadora_notifier.dart';
import '../../../models/presentation/notifiers/servico_notifier.dart';
import '../../../../models/empresa_prestadora.dart';
import '../../../../models/servico.dart';
import '../../../../models/enums.dart';

class SearchResultsPage extends StatefulWidget {
  final String? query;
  final String? categoria;
  const SearchResultsPage({super.key, this.query, this.categoria});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  late TextEditingController _searchController;
  List<String> _selectedCategorias = [];
  List<String> _selectedLocais = [];
  double _minRating = 0;
  String _ordenacao = 'relevancia';

  final List<String> _categorias = Categoria.values.map((c) => _formatarNomeCategoria(c)).toList();
  final List<String> _locais = [
    'São Paulo', 'Rio de Janeiro', 'Belo Horizonte', 'Brasília', 'Curitiba',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.query ?? '');
    if (widget.categoria != null && widget.categoria!.isNotEmpty) {
      // Tenta formatar a categoria da URL caso venha direto do enum
      _selectedCategorias = [_formatarNomeCategoriaEnum(widget.categoria!)];
    }
    
    Future.microtask(() {
      if (mounted) {
        context.read<EmpresaPrestadoraNotifier>().buscarTodas();
        context.read<ServicoNotifier>().buscarTodos();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static String _formatarNomeCategoria(Categoria cat) {
    switch (cat) {
      case Categoria.consultoria: return 'Consultoria';
      case Categoria.desenvolvimento: return 'Desenvolvimento';
      case Categoria.design: return 'Design';
      case Categoria.suporte: return 'Suporte';
      case Categoria.marketing: return 'Marketing';
      case Categoria.outros: return 'Outros';
    }
  }

  static String _formatarNomeCategoriaEnum(String nomeEnum) {
    final cat = Categoria.values.firstWhere(
      (e) => e.name.toLowerCase() == nomeEnum.toLowerCase(), 
      orElse: () => Categoria.outros
    );
    return _formatarNomeCategoria(cat);
  }

  // --- LÓGICA DE CRUZAMENTO DE DADOS ---
  List<Map<String, dynamic>> get _resultadosMapeados {
    final empresas = context.read<EmpresaPrestadoraNotifier>().empresas;
    final servicos = context.read<ServicoNotifier>().servicos;

    List<Map<String, dynamic>> mapList = [];

    for (var emp in empresas) {
      // Encontra serviços desta empresa
      final servicosEmpresa = servicos.where((s) => s.idEmpresa == emp.idEmpresa).toList();
      
      // Categorias únicas baseadas nos serviços prestados
      final categoriasEmpresa = servicosEmpresa.map((s) => _formatarNomeCategoria(s.categoria)).toSet().toList();
      String categoriaPrincipal = categoriasEmpresa.isNotEmpty ? categoriasEmpresa.first : 'Diversos';

      // Calcula faixa de preço
      String priceRange = 'Sob consulta';
      if (servicosEmpresa.isNotEmpty) {
        final precos = servicosEmpresa.map((s) => s.preco).toList();
        final minPrice = precos.reduce(min);
        final maxPrice = precos.reduce(max);
        if (minPrice == maxPrice) {
          priceRange = 'R\$ ${minPrice.toStringAsFixed(2)}';
        } else {
          priceRange = 'R\$ ${minPrice.toStringAsFixed(0)} - R\$ ${maxPrice.toStringAsFixed(0)}';
        }
      }

      // Converte reputação para double (fallback 0.0)
      double rating = double.tryParse(emp.reputacao) ?? 0.0;

      // Monta o objeto visual
      mapList.add({
        'id': emp.idEmpresa,
        'name': emp.nomeFantasia ?? emp.cnpj,
        'category': categoriaPrincipal,
        'allCategories': categoriasEmpresa,
        'location': emp.localizacao ?? 'Online/Não informado',
        'rating': rating,
        'description': emp.descricao ?? 'Empresa prestadora de serviços cadastrada na plataforma.',
        'services': servicosEmpresa.map((s) => s.descricao).take(3).toList(), // Mostra no máximo 3 serviços na tag
        'priceRange': priceRange,
        'emoji': emp.emoji ?? '🏢',
      });
    }

    // --- APLICA OS FILTROS ---
    return mapList.where((emp) {
      final q = _searchController.text.toLowerCase();
      
      // Match de Texto (Nome, Descrição ou algum Serviço)
      bool matchSearch = q.isEmpty ||
          (emp['name'] as String).toLowerCase().contains(q) ||
          (emp['description'] as String).toLowerCase().contains(q) ||
          (emp['services'] as List<String>).any((s) => s.toLowerCase().contains(q));

      // Match de Categoria (Verifica se a empresa possui alguma das categorias selecionadas)
      bool matchCat = _selectedCategorias.isEmpty || 
          (emp['allCategories'] as List<String>).any((c) => _selectedCategorias.contains(c));
          
      // Match de Localização
      bool matchLocal = _selectedLocais.isEmpty || _selectedLocais.contains(emp['location']);
      
      // Match de Avaliação
      bool matchRating = (emp['rating'] as double) >= _minRating;

      return matchSearch && matchCat && matchLocal && matchRating;
    }).toList();
  }

  void _limparFiltros() {
    setState(() {
      _selectedCategorias = [];
      _selectedLocais = [];
      _minRating = 0;
      _searchController.clear();
    });
  }

  Widget _buildFilterPanel() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Categoria', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          ...(_categorias.map((cat) => CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(cat, style: const TextStyle(fontSize: 13)),
            value: _selectedCategorias.contains(cat),
            activeColor: const Color(0xFF2563EB),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (v) {
              setState(() {
                if (v == true) _selectedCategorias.add(cat);
                else _selectedCategorias.remove(cat);
              });
            },
          ))),
          const SizedBox(height: 16),
          const Text('Localização', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          ...(_locais.map((loc) => CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(loc, style: const TextStyle(fontSize: 13)),
            value: _selectedLocais.contains(loc),
            activeColor: const Color(0xFF2563EB),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (v) {
              setState(() {
                if (v == true) _selectedLocais.add(loc);
                else _selectedLocais.remove(loc);
              });
            },
          ))),
          const SizedBox(height: 16),
          Text(
            'Avaliação Mínima: ${_minRating == 0 ? "Todas" : _minRating.toStringAsFixed(1)} ⭐',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF0F172A)),
          ),
          Slider(
            value: _minRating,
            min: 0, max: 5, divisions: 10,
            activeColor: const Color(0xFF2563EB),
            onChanged: (v) => setState(() => _minRating = v),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _limparFiltros,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF2563EB)),
                foregroundColor: const Color(0xFF2563EB),
              ),
              child: const Text('Limpar Filtros'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Monitora o estado de carregamento
    final carregando = context.watch<EmpresaPrestadoraNotifier>().carregando || 
                       context.watch<ServicoNotifier>().carregando;
                       
    final resultados = carregando ? [] : _resultadosMapeados;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: const Text('Buscar Empresas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF0F172A))),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey[200]),
        ),
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.tune, color: Color(0xFF2563EB)),
                  if (_selectedCategorias.isNotEmpty || _selectedLocais.isNotEmpty || _minRating > 0)
                    Positioned(
                      right: -2, top: -2,
                      child: Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                      ),
                    ),
                ],
              ),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Filtros', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(child: _buildFilterPanel()),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                              hintText: 'Buscar empresas, serviços...',
                              hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 16, color: Color(0xFF94A3B8)),
                            onPressed: () => setState(() => _searchController.clear()),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: carregando ? 'Carregando...' : '${resultados.length}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 13),
                        ),
                        if (!carregando)
                          const TextSpan(
                            text: ' empresas encontradas',
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                          ),
                      ],
                    ),
                  ),
                ),
                DropdownButton<String>(
                  value: _ordenacao,
                  isDense: true,
                  underline: const SizedBox(),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF2563EB), fontWeight: FontWeight.w500),
                  items: const [
                    DropdownMenuItem(value: 'relevancia', child: Text('Mais Relevantes')),
                    DropdownMenuItem(value: 'rating', child: Text('Melhor Avaliadas')),
                    DropdownMenuItem(value: 'nome', child: Text('Nome A-Z')),
                  ],
                  onChanged: (v) => setState(() => _ordenacao = v ?? 'relevancia'),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[200]),

          Expanded(
            child: carregando
              ? const Center(child: CircularProgressIndicator())
              : resultados.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 56, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        const Text('Nenhuma empresa encontrada', style: TextStyle(color: Color(0xFF64748B), fontSize: 15)),
                        const SizedBox(height: 6),
                        TextButton(onPressed: _limparFiltros, child: const Text('Limpar filtros')),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: resultados.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) {
                      final emp = resultados[i];
                      return GestureDetector(
                        onTap: () => context.push('/empresa/${emp['id']}'),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 56, height: 56,
                                  decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(10)),
                                  child: Center(child: Text(emp['emoji'] as String, style: const TextStyle(fontSize: 28))),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(emp['name'] as String,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                                          ),
                                          Row(children: [
                                            const Icon(Icons.star, color: Color(0xFFF59E0B), size: 14),
                                            const SizedBox(width: 2),
                                            Text('${emp['rating']}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                          ]),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                            decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(4)),
                                            child: Text(emp['category'] as String, style: const TextStyle(fontSize: 10, color: Color(0xFF2563EB), fontWeight: FontWeight.w500)),
                                          ),
                                          const SizedBox(width: 6),
                                          const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF94A3B8)),
                                          const SizedBox(width: 2),
                                          Text(emp['location'] as String, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(emp['description'] as String,
                                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
                                          maxLines: 2, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 6),
                                      Wrap(
                                        spacing: 4, runSpacing: 4,
                                        children: (emp['services'] as List<String>).map((s) => Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: const Color(0xFFE2E8F0)),
                                          ),
                                          child: Text(s, style: const TextStyle(fontSize: 10, color: Color(0xFF475569))),
                                        )).toList(),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(emp['priceRange'] as String,
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}