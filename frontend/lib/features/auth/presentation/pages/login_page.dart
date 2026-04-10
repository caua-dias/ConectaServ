import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _senhaVisivel = true;
  bool _visivel = false;

  @override
  void initState() {
    super.initState();
    // Dispara a animação após o primeiro frame
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _visivel = true);
    });
  }

  void _handleLogin() {
    print("Login clicado");
  }

  /// Widget helper para fade-in escalonado
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 64),

                // Logo com scale
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
                    'Acesse sua conta para continuar',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),

                const SizedBox(height: 32),

                _fadeIn(
                  ordem: 3,
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
                  ordem: 4,
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

                const SizedBox(height: 8),

                _fadeIn(
                  ordem: 5,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Esqueci minha senha'),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                _fadeIn(
                  ordem: 6,
                  child: ElevatedButton(
                    onPressed: _handleLogin,
                    child: const Text('Entrar'),
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
                        onPressed: () {},
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
    );
  }
}
