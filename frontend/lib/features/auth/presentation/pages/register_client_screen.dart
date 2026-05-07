import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterClientScreen extends StatefulWidget {
  const RegisterClientScreen({super.key});

  @override
  State<RegisterClientScreen> createState() => _RegisterClientScreenState();
}

class _RegisterClientScreenState extends State<RegisterClientScreen> {
  bool _senhaVisivel = true;
  bool _visivel = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _visivel = true);
    });
  }

  void _handleRegister() {
    print("Cadastro de Cliente clicado");
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _fadeIn(
                  ordem: 1,
                  child: Text(
                    'Criar Conta - Cliente',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                _fadeIn(
                  ordem: 2,
                  child: Text(
                    'Preencha os dados para se cadastrar.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 32),
                _fadeIn(
                  ordem: 3,
                  child: const TextField(
                    decoration: InputDecoration(
                      labelText: 'CPF ou CNPJ',
                      prefixIcon: Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _fadeIn(
                  ordem: 4,
                  child: const TextField(
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _fadeIn(
                  ordem: 5,
                  child: TextField(
                    obscureText: _senhaVisivel,
                    decoration: InputDecoration(
                      labelText: 'Senha',
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
                        onPressed: () {
                          setState(() => _senhaVisivel = !_senhaVisivel);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _fadeIn(
                  ordem: 6,
                  child: ElevatedButton(
                    onPressed: _handleRegister,
                    child: const Text('Cadastrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}