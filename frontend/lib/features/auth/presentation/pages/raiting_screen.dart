import 'package:flutter/material.dart';
import 'dart:convert';

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

class _AvaliacaoScreenState extends State<AvaliacaoScreen> with SingleTickerProviderStateMixin {
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
    super.dispose();
  }

  void _enviarAvaliacao() {
    if (_nota == 0) return;

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

    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
        content: Row(
          children: const [
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
                     isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                     color: isSelected ? Colors.amber.shade400 : Colors.grey.shade300,
                     size: 48,
                     shadows: isSelected ? [
                       Shadow(
                         color: Colors.amber.withOpacity(0.4),
                         blurRadius: 12,
                         offset: const Offset(0, 4)
                       )
                     ] : [],
                   ),
                 );
               },
            )
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50, // Fundo levemente acinzentado e moderno
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
            // Container responsivo (LayoutBuilder + ConstrainedBox limitam para não esticar demais)
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Center(
                child: ConstrainedBox(
                  // Em telas grandes (Desktop/Tablets), limita o tamanho máximo criando um efeito "Card"
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Container(
                    padding: const EdgeInsets.all(32.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.04),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Cabeçalho estilizado
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                          decoration: BoxDecoration(
                             color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
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
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Pergunta Central
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

                        // Seção de feedback rápido
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
                        
                        // Chips de seleção
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
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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
                              selectedColor: Theme.of(context).colorScheme.primary,
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
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 40),

                        // Campo de texto
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
                        TextField(
                          controller: _comentarioController,
                          maxLines: 5,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            hintText: 'Escreva detalhes sobre o atendimento, qualidade...',
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
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
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: const EdgeInsets.all(20),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Botão de Enviar
                        ElevatedButton(
                          onPressed: _nota > 0 ? _enviarAvaliacao : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: _nota > 0 ? 6 : 0,
                            shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                            disabledBackgroundColor: Colors.grey.shade200,
                            disabledForegroundColor: Colors.grey.shade400,
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
            );
          },
        ),
      ),
    );
  }
}