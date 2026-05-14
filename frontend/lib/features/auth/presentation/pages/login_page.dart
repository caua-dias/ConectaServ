import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart'; // NOVO: Import do Provider

// IMPORTANTE: Ajuste o caminho de acordo com a sua estrutura de pastas
import '../../auth_notifier.dart'; 

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _senhaVisivel = true;
  bool _visivel = false;
  
  // REMOVIDO: bool _carregando = false; 
  // O estado de carregamento agora é gerenciado pelo ViewModel (AuthNotifier)

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
      // NOVO: Usando context.read() para despachar a intenção para o ViewModel
      // O AuthNotifier irá internamente alterar o estado de "carregando" e notificar a View
      await context.read<AuthNotifier>().login(
        _emailController.text,
        _senhaController.text,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bem-vindo! Login realizado com sucesso.'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/');
      }
    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao tentar entrar. Verifique seus dados.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _mostrarDialogoEsqueciSenha() async {
    final emailAtual = _emailController.text;

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
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(emailAtual.isNotEmpty ? 'Cancelar' : 'OK, entendi'),
            ),
            if (emailAtual.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link de recuperação enviado!')),
                  );
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
    // NOVO: Escutando ativamente as mudanças de estado do ViewModel
    final authNotifier = context.watch<AuthNotifier>();

    return LoadingOverlay(
      // NOVO: Consumindo a variável _carregando gerenciada pelo AuthNotifier
      isLoading: authNotifier.carregando, 
      color: Colors.black.withOpacity(0.5),
      progressIndicator: const CircularProgressIndicator(color: Colors.orange),
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
                    const SizedBox(height: 64),
                    AnimatedScale(
                      scale: _visivel ? 1.0 : 0.6,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      child: AnimatedOpacity(
                        opacity: _visivel ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 400),
                        child: Center(
                          child: Image.asset('assets/login.jpg', height: 250),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    _fadeIn(
                      ordem: 1,
                      child: Text(
                        'Bem-vindo de volta',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _fadeIn(
                      ordem: 2,
                      child: Text(
                        'Acesse sua conta para continuar',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _fadeIn(
                      ordem: 3,
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_senhaFocus),
                        decoration: const InputDecoration(
                          labelText: 'E-mail',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (valor) {
                          if (valor == null || valor.trim().isEmpty) return 'O e-mail é obrigatório';
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(valor.trim())) return 'Informe um e-mail válido';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _fadeIn(
                      ordem: 4,
                      child: TextFormField(
                        controller: _senhaController,
                        focusNode: _senhaFocus,
                        obscureText: _senhaVisivel,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleLogin(),
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                              child: Icon(
                                _senhaVisivel ? Icons.visibility_off : Icons.visibility,
                                key: ValueKey(_senhaVisivel),
                              ),
                            ),
                            onPressed: () => setState(() => _senhaVisivel = !_senhaVisivel),
                          ),
                        ),
                        validator: (valor) {
                          if (valor == null || valor.isEmpty) return 'A senha é obrigatória';
                          if (valor.length < 8) return 'A senha deve ter no mínimo 8 caracteres';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    _fadeIn(
                      ordem: 5,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            _mostrarDialogoEsqueciSenha(); 
                            context.go('/recover_password');
                          },
                          child: const Text('Esqueci minha senha'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _fadeIn(
                      ordem: 6,
                      child: ElevatedButton(
                        onPressed: _handleLogin, 
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Entrar', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _fadeIn(
                      ordem: 7,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Não tem conta? '),
                          TextButton(
                            onPressed: () => context.go('/register'),
                            child: const Text('Cadastre-se'),
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
      ),
    );
  }
}