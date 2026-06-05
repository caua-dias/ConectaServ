import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

import '../../../models/presentation/notifiers/auth_notifier.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _senhaVisivel = true;
  bool _visivel = false;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _senhaFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _visivel = true);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _senhaFocus.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    try {
      await context.read<AuthNotifier>().login(
            _emailController.text.trim(),
            _senhaController.text,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bem-vindo! Login realizado com sucesso.'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/home'); // Corrigido para garantir a rota base correta
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Credenciais inválidas ou erro no servidor. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _mostrarDialogoEsqueciSenha() async {
    final emailAtual = _emailController.text.trim();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Recuperar Senha'),
          content: Text(emailAtual.isNotEmpty
              ? 'Enviaremos um link de recuperação para:\n\n$emailAtual'
              : 'Por favor, preencha o seu e-mail no formulário antes de solicitar a recuperação.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(emailAtual.isNotEmpty ? 'Cancelar' : 'OK, entendi'),
            ),
            if (emailAtual.isNotEmpty)
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop(); // Fecha o dialog
                  
                  try {
                    // Chama o Notifier com a rota da API real
                    await context.read<AuthNotifier>().recoverPassword(emailAtual);
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Link de recuperação enviado com sucesso!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Erro ao enviar o link. Verifique o seu e-mail.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Enviar Link'),
              ),
          ],
        );
      },
    );
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
    final authNotifier = context.watch<AuthNotifier>();
    final colorScheme = Theme.of(context).colorScheme;

    return LoadingOverlay(
      isLoading: authNotifier.carregando,
      color: Colors.black.withOpacity(0.5),
      progressIndicator: const CircularProgressIndicator(color: Colors.blueAccent),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),

                    // ── Logo ─────────────────────────────────────────────────
                    AnimatedScale(
                      scale: _visivel ? 1.0 : 0.6,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      child: AnimatedOpacity(
                        opacity: _visivel ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 400),
                        child: Center(
                          child: Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.lock_person_outlined, size: 60, color: Colors.blueAccent),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Títulos ───────────────────────────────────────────────
                    _fadeIn(
                      ordem: 1,
                      child: Text(
                        'Bem-vindo de volta',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _fadeIn(
                      ordem: 2,
                      child: Text(
                        'Inicie a sua sessão para continuar',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Email ─────────────────────────────────────────────────
                    _fadeIn(
                      ordem: 3,
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_senhaFocus),
                        decoration: const InputDecoration(
                          labelText: 'E-mail',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (valor) {
                          if (valor == null || valor.trim().isEmpty) {
                            return 'O e-mail é obrigatório';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                              .hasMatch(valor.trim())) {
                            return 'Informe um e-mail válido';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Senha ─────────────────────────────────────────────────
                    _fadeIn(
                      ordem: 4,
                      child: TextFormField(
                        controller: _senhaController,
                        focusNode: _senhaFocus,
                        obscureText: _senhaVisivel,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleLogin(),
                        decoration: InputDecoration(
                          labelText: 'Palavra-passe',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (child, anim) =>
                                  ScaleTransition(scale: anim, child: child),
                              child: Icon(
                                _senhaVisivel
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                key: ValueKey(_senhaVisivel),
                              ),
                            ),
                            onPressed: () => setState(
                                () => _senhaVisivel = !_senhaVisivel),
                          ),
                        ),
                        validator: (valor) {
                          if (valor == null || valor.isEmpty) {
                            return 'A palavra-passe é obrigatória';
                          }
                          if (valor.length < 6) {
                            return 'A palavra-passe deve ter no mínimo 6 caracteres';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 4),

                    // ── Esqueci minha senha ───────────────────────────────────
                    _fadeIn(
                      ordem: 5,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            _mostrarDialogoEsqueciSenha();
                          },
                          child: const Text('Esqueci a minha palavra-passe'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Botão Entrar ──────────────────────────────────────────
                    _fadeIn(
                      ordem: 6,
                      child: ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Entrar',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Divisor ───────────────────────────────────────────────
                    _fadeIn(
                      ordem: 7,
                      child: Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'Não tem conta?',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Cadastro Cliente ──────────────────────────────────────
                    _fadeIn(
                      ordem: 8,
                      child: OutlinedButton.icon(
                        onPressed: () => context.go('/register_client'),
                        icon: const Icon(Icons.person_add_outlined),
                        label: const Text(
                          'Registar como Cliente',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: colorScheme.primary, width: 1.5),
                          foregroundColor: colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Cadastro Empresa ──────────────────────────────────────
                    _fadeIn(
                      ordem: 9,
                      child: ElevatedButton.icon(
                        onPressed: () => context.go('/register_company'),
                        icon: const Icon(Icons.business_outlined),
                        label: const Text(
                          'Registar a minha Empresa',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}