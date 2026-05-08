import 'package:flutter/material.dart';
// IMPORTANTE: Adicione o pacote no seu pubspec.yaml (flutter pub add loading_overlay)
import 'package:loading_overlay/loading_overlay.dart';

class RecoverPasswordPage extends StatefulWidget {
  const RecoverPasswordPage({super.key});

  @override
  State<RecoverPasswordPage> createState() => _RecoverPasswordPageState();
}

class _RecoverPasswordPageState extends State<RecoverPasswordPage> {
  // 1. Chave para coordenar a validação
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  
  // 2. FocusNode para gerenciar o teclado
  final FocusNode _emailFocus = FocusNode();
  
  // 3. Estado de carregamento
  bool _carregando = false;

  @override
  void dispose() {
    // 4. Liberar os recursos de memória associados aos controllers e FocusNodes
    emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  // --- NOVO: Método para exibir o AlertDialog ---
  Future<bool> _confirmarEnvio(String email) async {
    final confirmado = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Impede o fechamento tocando fora
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Email'),
          content: Text('Deseja enviar o código de recuperação para:\n\n$email'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Editar email'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sim, enviar código'),
            ),
          ],
        );
      },
    );
    return confirmado ?? false; // Retorna false se o dialog for fechado de outra forma
  }

  Future<void> _enviarCodigo() async {
    // Valida o formulário antes de prosseguir
    if (!_formKey.currentState!.validate()) return;

    // Remove o foco para esconder o teclado virtual
    FocusScope.of(context).unfocus();

    final email = emailController.text.trim();

    // Aguarda a confirmação do usuário
    final confirmar = await _confirmarEnvio(email);
    
    // Se o usuário não confirmou ou o widget não estiver mais na tela, interrompe
    if (!confirmar || !mounted) return;

    // Ativa o LoadingOverlay
    setState(() => _carregando = true);

    try {
      // Simula o tempo de rede (API)
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        // Feedback visual de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Código enviado para $email com sucesso!')),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        // Após o envio com sucesso, podemos retornar automaticamente para o login
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Erro ao enviar o código. Tente novamente.')),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } finally {
      // Desativa o overlay independente do resultado
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- NOVO: LoadingOverlay envolve a tela ---
    return LoadingOverlay(
      isLoading: _carregando,
      color: Colors.black.withOpacity(0.5),
      progressIndicator: const CircularProgressIndicator(color: Colors.deepPurple),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F2F8),
        body: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Form( // --- NOVO: O widget Form envolve a coluna ---
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.lock_reset_rounded,
                            size: 80,
                            color: Colors.deepPurple,
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Recuperar senha',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Digite seu email para receber o código de recuperação.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 32),
                          // --- NOVO: Trocado TextField por TextFormField ---
                          TextFormField(
                            controller: emailController,
                            focusNode: _emailFocus, // Gerencia o foco
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _enviarCodigo(), // Aciona o envio pelo teclado
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            // Validador nativo
                            validator: (valor) {
                              if (valor == null || valor.trim().isEmpty) {
                                return 'O email é obrigatório';
                              }
                              final regexEmail = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                              if (!regexEmail.hasMatch(valor.trim())) {
                                return 'Informe um e-mail válido (ex: usuario@email.com)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _enviarCodigo,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Enviar código',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Lembrei! Voltar para login'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}