import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../models/presentation/notifiers/empresa_prestadora_notifier.dart';
import '../../../../models/empresa_prestadora.dart';
import '../../../../models/enums.dart';

import '../../../models/presentation/notifiers/auth_notifier.dart';

class RegisterCompanyScreen extends StatefulWidget {
  const RegisterCompanyScreen({super.key});

  @override
  State<RegisterCompanyScreen> createState() => _RegisterCompanyScreenState();
}

class _RegisterCompanyScreenState extends State<RegisterCompanyScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _senhaVisivel = true;
  bool _visivel = false;
  bool _isLoading = false;

  final _cnpjController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _visivel = true);
    });
  }

  @override
  void dispose() {
    _cnpjController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _showSnackBar(String mensagem, {bool isError = false}) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Sucesso!'),
        content: const Text('Sua empresa foi cadastrada com êxito.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (mounted) context.pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // 1. Regista na API Real (Faz o utilizador existir para o Login)
        await context.read<AuthNotifier>().registerCompany(
              cnpj: _cnpjController.text,
              email: _emailController.text,
              senha: _senhaController.text,
            );

        // 2. Salva no SQLite local (Para a empresa aparecer nas listagens do app)
        final empresa = EmpresaPrestadora(
          cnpj: _cnpjController.text,
          statusCuradoria: StatusCuradoria.emAnalise,
          reputacao: '0',
        );
        await context.read<EmpresaPrestadoraNotifier>().salvar(empresa);

        if (mounted) {
          setState(() => _isLoading = false);
          _showSnackBar("Cadastro empresarial realizado!");
          _showSuccessDialog(); // Clicar "OK" aqui enviará o usuário para dentro do app autenticado
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showSnackBar("Erro na API ou Banco Local: $e", isError: true);
        }
      }
    } else {
      _showSnackBar("Verifique as informações do formulário", isError: true);
    }
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          // ── NAVBAR DA HOME ──────────────────────────────────────────────
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.white,
              elevation: 0,
              selectedItemColor: Colors.grey,
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
                BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.search), label: 'Buscar'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.settings_outlined), label: 'Config.'),
              ],
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── CABEÇALHO DA HOME (Com botão voltar acoplado) ────────
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _fadeIn(
                        ordem: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => context.pop(),
                                  child: const Icon(Icons.arrow_back,
                                      color: Colors.black),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.location_on_outlined,
                                    color: Colors.grey),
                                const SizedBox(width: 4),
                                const Text(
                                  'São Paulo - SP',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            Text(
                              'ConectaServ',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent),
                            ),
                            IconButton(
                              icon:
                                  const Icon(Icons.notifications_none_outlined),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── CONTEÚDO DO FORMULÁRIO ───────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _fadeIn(
                            ordem: 2,
                            child: Text(
                              'Criar Conta - Empresa',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _fadeIn(
                            ordem: 3,
                            child: Text(
                              'Cadastre sua empresa como prestadora.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _fadeIn(
                            ordem: 4,
                            child: TextFormField(
                              controller: _cnpjController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'CNPJ',
                                prefixIcon: Icon(Icons.domain),
                                border: OutlineInputBorder(),
                                helperText: 'Apenas os 14 dígitos numéricos',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'O CNPJ é obrigatório';
                                }
                                final cleanValue =
                                    value.replaceAll(RegExp(r'[^0-9]'), '');
                                if (cleanValue.length != 14) {
                                  return 'O CNPJ deve conter exatamente 14 dígitos';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          _fadeIn(
                            ordem: 5,
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'E-mail Corporativo',
                                prefixIcon: Icon(Icons.email_outlined),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'O e-mail é obrigatório';
                                }
                                if (!value.contains('@')) {
                                  return 'Insira um e-mail válido';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          _fadeIn(
                            ordem: 6,
                            child: TextFormField(
                              controller: _senhaController,
                              obscureText: _senhaVisivel,
                              decoration: InputDecoration(
                                labelText: 'Senha',
                                prefixIcon: const Icon(Icons.lock_outline),
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(_senhaVisivel
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () => setState(
                                      () => _senhaVisivel = !_senhaVisivel),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'A senha é obrigatória';
                                }
                                if (value.length < 8) {
                                  return 'A senha deve ter no mínimo 8 caracteres';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 32),
                          _fadeIn(
                            ordem: 7,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleRegister,
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Cadastrar Empresa',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
