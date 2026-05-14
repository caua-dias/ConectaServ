import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

import '../../auth_notifier.dart';

/// Classe estruturada para representar o Payload que será enviado ao backend Flask.
class AvaliacaoPayload {
  final String servico;
  final int nota;
  final List<String> comentariosRapidos;
  final String comentarioTexto;
  final DateTime dataEnvio;

  AvaliacaoPayload({
    required this.servico,
    required this.nota,
    required this.comentariosRapidos,
    required this.comentarioTexto,
    required this.dataEnvio,
  });

  AvaliacaoPayload.padrao({
    required this.servico,
    required this.nota,
  })  : comentariosRapidos = [],
        comentarioTexto = '',
        dataEnvio = DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'servico': servico,
      'nota': nota,
      'comentarios_rapidos': comentariosRapidos,
      'comentario_texto': comentarioTexto,
      'data_envio': dataEnvio.toIso8601String(),
    };
  }
}

class RaitingScreen extends StatelessWidget {
  const RaitingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Avaliação de Serviços',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB), // Azul vibrante moderno (Blue 600)
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const AvaliacaoScreen(
        nomeServico: 'Aluguel de Serviços',
      ),
    );
  }
}

class AvaliacaoScreen extends StatefulWidget {
  final String nomeServico;

  const AvaliacaoScreen({
    super.key,
    required this.nomeServico,
  });

  @override
  State<AvaliacaoScreen> createState() => _AvaliacaoScreenState();
}

class _AvaliacaoScreenState extends State<AvaliacaoScreen>
    with SingleTickerProviderStateMixin {
  
  // --- NOVOS ESTADOS ---
  bool _carregando = false;
  final _formKey = GlobalKey<FormState>();
  final _comentarioFocus = FocusNode();

  int _nota = 0;
  final TextEditingController _comentarioController = TextEditingController();

  // Opções para os chips de seleção rápida
  final List<String> _opcoesAvaliacao = [
    "Rápido",
    "Atencioso",
    "Preço Justo",
    "Qualidade",
    "Recomendaria"
  ];
  final Set<String> _selecoes = {};

  @override
  void dispose() {
    _comentarioController.dispose();
    _comentarioFocus.dispose(); // IMPORTANTE: Descartar FocusNode para evitar memory leak
    super.dispose();
  }

  // --- NOVO: Método para confirmar o envio com AlertDialog ---
  Future<bool> _confirmarEnvio() async {
    final confirmado = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Força uma escolha explícita
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Avaliação'),
          content: const Text('Deseja enviar sua avaliação agora? Não será possível alterá-la depois.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Revisar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Enviar Avaliação'),
            ),
          ],
        );
      },
    );
    return confirmado ?? false;
  }

  // Método atualizado para ser assíncrono e coordenar os feedbacks
  Future<void> _enviarAvaliacao() async {
    // 1. Validação simples para a nota
    if (_nota == 0) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione uma nota (estrelas).'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 2. Aciona o formKey para validar os TextFormFields
    if (!_formKey.currentState!.validate()) return;

    // 3. Remove o foco do teclado antes do diálogo
    FocusScope.of(context).unfocus();

    // 4. Solicita a confirmação do usuário (AlertDialog)
    final confirmar = await _confirmarEnvio();
    if (!confirmar || !mounted) return;

    // 5. Ativa o loading overlay
    setState(() => _carregando = true);

    try {
      // Simula o tempo de requisição ao Backend (Flask)
      await Future.delayed(const Duration(seconds: 2));

      final payload = AvaliacaoPayload(
        servico: widget.nomeServico,
        nota: _nota,
        comentariosRapidos: _selecoes.toList(),
        comentarioTexto: _comentarioController.text,
        dataEnvio: DateTime.now(),
      );

      final jsonString = jsonEncode(payload.toJson());
      print("--- INÍCIO DO PAYLOAD JSON (FLASK) ---");
      print(jsonString);
      print("--- FIM DO PAYLOAD ---");

      // 6. Resposta de sucesso (SnackBar)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Avaliação enviada com sucesso!'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          ),
        );
        // Após a mensagem, você pode voltar o usuário para a home
        // context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ocorreu um erro ao enviar. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // 7. Desativa o loading, independentemente do resultado
      if (mounted) setState(() => _carregando = false);
    }
  }

  Widget _buildRatingBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final isSelected = index < _nota;
        return GestureDetector(
          onTap: () {
            setState(() {
              _nota = index + 1;
            });
          },
          child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: isSelected ? 1.0 : 0.0),
                duration: const Duration(milliseconds: 300),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 1.0 + (value * 0.15),
                    child: Icon(
                      isSelected
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: isSelected
                          ? Colors.amber.shade400
                          : Colors.grey.shade300,
                      size: 48,
                      shadows: isSelected
                          ? [
                              Shadow(
                                  color: Colors.amber.withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4))
                            ]
                          : [],
                    ),
                  );
                },
              )),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- NOVO: Envolvendo o Scaffold com o LoadingOverlay ---
    return LoadingOverlay(
      isLoading: _carregando,
      color: Colors.black.withOpacity(0.5),
      progressIndicator: const CircularProgressIndicator(color: Colors.blueAccent),
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text(
            'Avaliação de Serviço',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black87,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Container(
                      padding: const EdgeInsets.all(32.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.04),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      // --- NOVO: Envolvendo a coluna do comentário com o Form ---
                      child: Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer
                                    .withOpacity(0.4),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Você está avaliando o',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    widget.nomeServico,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 36),
                            const Text(
                              'O que achou do serviço?',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            _buildRatingBar(),
                            const SizedBox(height: 40),
                            const Text(
                              'Compartilhe a sua experiência',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            Wrap(
                              spacing: 12.0,
                              runSpacing: 12.0,
                              alignment: WrapAlignment.center,
                              children: _opcoesAvaliacao.map((opcao) {
                                final isSelected = _selecoes.contains(opcao);
                                return FilterChip(
                                  label: Text(
                                    opcao,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black87,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                                  ),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selecoes.add(opcao);
                                      } else {
                                        _selecoes.remove(opcao);
                                      }
                                    });
                                  },
                                  backgroundColor: Colors.grey.shade100,
                                  selectedColor:
                                      Theme.of(context).colorScheme.primary,
                                  showCheckmark: isSelected,
                                  checkmarkColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    side: BorderSide(
                                      color: isSelected
                                          ? Theme.of(context).colorScheme.primary
                                          : Colors.grey.shade200,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 40),
                            const Text(
                              'Detalhamento (opcional)',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.start,
                            ),
                            const SizedBox(height: 12),
                            // --- NOVO: Substituído TextField por TextFormField ---
                            TextFormField(
                              controller: _comentarioController,
                              focusNode: _comentarioFocus, // Vinculando FocusNode
                              maxLines: 5,
                              textInputAction: TextInputAction.done,
                              // Adicionando uma validação customizada para exemplo:
                              // Se o usuário der 1 ou 2 estrelas, ele é obrigado a escrever um detalhe
                              validator: (valor) {
                                if (_nota > 0 && _nota <= 2 && (valor == null || valor.trim().isEmpty)) {
                                  return 'Por favor, nos diga como podemos melhorar.';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText:
                                    'Escreva detalhes sobre o atendimento, qualidade...',
                                hintStyle: TextStyle(
                                    color: Colors.grey.shade400, fontSize: 15),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.grey.shade200),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.primary,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Colors.red),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                contentPadding: const EdgeInsets.all(20),
                              ),
                            ),
                            const SizedBox(height: 40),
                            ElevatedButton(
                              onPressed: _enviarAvaliacao,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 6,
                                shadowColor: Theme.of(context)
                                    .colorScheme
                                    .primary,
                              ),
                              child: const Text(
                                'Confirmar Avaliação',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          onTap: (index) {
            if (index == 0) {
              context.go('/home');
            } else if (index == 1) {
              context.go('/service');
            } else if (index == 2) {
              print('Ir para Perfil (Rota não criada)');
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.build_circle_outlined),
              label: 'Serviços',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Conta',
            ),
          ],
        ),
      ),
    );
  }
}