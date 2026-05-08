import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterClientScreen extends StatefulWidget {
  const RegisterClientScreen({super.key});

  @override
  State<RegisterClientScreen> createState() => _RegisterClientScreenState();
}

class _RegisterClientScreenState extends State<RegisterClientScreen> {
  final _formKey = GlobalKey<FormState>();
  
  bool _senhaVisivel = true;
  bool _visivel = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _visivel = true);
    });
  }

  void _showSnackBar(String mensagem, {bool isError = false}) {
    // Limpa snacks anteriores para evitar fila e atraso no feedback
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
        content: const Text('Sua conta foi criada com êxito.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Fecha o dialog
              if (mounted) context.pop(); // Retorna à tela anterior
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

      // Simulação de requisição (ex: integração com AWS ou Firebase)
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() => _isLoading = false);
        // Exibimos o snackbar e o dialog em sequência
        _showSnackBar("Dados processados com sucesso!");
        _showSuccessDialog();
      }
    } else {
      _showSnackBar("Por favor, preencha os campos corretamente", isError: true);
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
                child: Form(
                  key: _formKey,
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
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'CPF ou CNPJ',
                            prefixIcon: Icon(Icons.badge_outlined),
                            border: OutlineInputBorder(),
                            helperText: 'Apenas números (11 ou 14 dígitos)',
                          ),
                          keyboardType: TextInputType.number,
                          // Nova validação de Documento
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'O documento é obrigatório';
                            }
                            // Remove pontos, traços ou espaços
                            final cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                            
                            if (cleanValue.length != 11 && cleanValue.length != 14) {
                              return 'Documento inválido. Use 11 (CPF) ou 14 (CNPJ) dígitos';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      _fadeIn(
                        ordem: 4,
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'E-mail',
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
                        ordem: 5,
                        child: TextFormField(
                          obscureText: _senhaVisivel,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(_senhaVisivel ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _senhaVisivel = !_senhaVisivel),
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
                        ordem: 6,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
                          child: const Text('Cadastrar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withAlpha(77), // .withOpacity(0.3)
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}