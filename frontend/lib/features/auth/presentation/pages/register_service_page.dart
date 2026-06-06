import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../models/presentation/notifiers/servico_notifier.dart';
import '../../../models/presentation/notifiers/empresa_prestadora_notifier.dart';
import '../../../../models/servico.dart';
import '../../../../models/enums.dart';
import 'app_shell.dart'; // <-- Importação do AppShell adicionada

class RegisterServicePage extends StatefulWidget {
  const RegisterServicePage({super.key});

  @override
  State<RegisterServicePage> createState() => _RegisterServicePageState();
}

class _RegisterServicePageState extends State<RegisterServicePage> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _precoController = TextEditingController();
  Categoria _categoriaSelecionada = Categoria.outros;
  bool _isLoading = false;

  @override
  void dispose() {
    _descricaoController.dispose();
    _precoController.dispose();
    super.dispose();
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

  Future<void> _salvarServico() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Busca a empresa logada (ou a primeira do banco para teste)
      await context.read<EmpresaPrestadoraNotifier>().buscarTodas();
      final empresas = context.read<EmpresaPrestadoraNotifier>().empresas;

      if (empresas.isEmpty) {
        throw Exception('Cadastre uma empresa antes de adicionar serviços.');
      }

      final novoServico = Servico(
        idEmpresa: empresas.first.idEmpresa!, // Associa à sua empresa
        descricao: _descricaoController.text,
        preco: double.parse(_precoController.text.replaceAll(',', '.')),
        categoria: _categoriaSelecionada,
      );

      await context.read<ServicoNotifier>().salvar(novoServico);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('✅ Serviço cadastrado com sucesso!'),
              backgroundColor: Colors.green),
        );
        context.pop(); // Volta para a tela anterior
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erro: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ── Envolvemos o Scaffold da página com o AppShell ──
    return AppShell(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.white,
          title: const Text('Novo Serviço',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop()),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(height: 1, color: Colors.grey[200]),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'O que a sua empresa oferece?',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 8),
                const Text(
                    'Preencha os detalhes do serviço para atrair novos clientes.',
                    style: TextStyle(color: Color(0xFF64748B))),
                const SizedBox(height: 32),

                // Descrição
                TextFormField(
                  controller: _descricaoController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descrição do Serviço',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                    hintText:
                        'Ex: Desenvolvimento de aplicativos móveis com Flutter...',
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Informe a descrição'
                      : null,
                ),
                const SizedBox(height: 20),

                // Preço
                TextFormField(
                  controller: _precoController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Preço Estimado (R\$)',
                    prefixIcon: Icon(Icons.payments_outlined),
                    border: OutlineInputBorder(),
                    hintText: '0,00',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Informe o preço';
                    if (double.tryParse(v.replaceAll(',', '.')) == null)
                      return 'Preço inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Categoria
                DropdownButtonFormField<Categoria>(
                  value: _categoriaSelecionada,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    prefixIcon: Icon(Icons.category_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: Categoria.values
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(_categoriaLabel(cat)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _categoriaSelecionada = v!),
                ),
                const SizedBox(height: 40),

                ElevatedButton(
                  onPressed: _isLoading ? null : _salvarServico,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Cadastrar Serviço',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
