import 'package:flutter/material.dart';

class ServiceScreen extends StatelessWidget {
  const ServiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        title: const Text(
          'Serviços',
          style: TextStyle(color: Colors.black, fontSize: 24),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false, 
      ),
      
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Gestão de marketing digital',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black),
              ),
              const SizedBox(height: 24),

              Container(
                height: 160,
                decoration: BoxDecoration(),
                alignment: Alignment.center,
                padding: EdgeInsets.all(20),
                child: Image.network('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTOHNDctaIc4YYGBgh55wsNSkZogf9RYmaVkA&s'),
              ),
              const SizedBox(height: 24),

              const Text('Descrição', style: TextStyle(fontSize: 16, color: Colors.black)),
              const SizedBox(height: 8),
              Container(
                height: 100,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: const Color.fromARGB(255, 5, 170, 199)),
                alignment: Alignment.center,
                padding: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: const Text(
                  'Somos uma empresa especializada em gestão de marketing digital, oferecendo soluções personalizadas para impulsionar a presença online de nossos clientes. Com uma equipe experiente e dedicada, trabalhamos para criar estratégias eficazes que aumentam a visibilidade, engajamento e conversões. Nossos serviços incluem gerenciamento de redes sociais, criação de conteúdo, campanhas publicitárias e análise de desempenho, tudo com o objetivo de ajudar nossos clientes a alcançar seus objetivos de negócios.',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
                  
              ),
              const SizedBox(height: 24),

              const Text('Preço do serviço', style: TextStyle(fontSize: 16, color: Colors.black)),
              const SizedBox(height: 8),
              Container(
                height: 48,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: const Color.fromARGB(255, 5, 170, 199)),
                alignment: Alignment.center,
                child: const Text('R\$ 150,00', style: TextStyle(fontSize: 18, color: Colors.black)),
              ),

              const SizedBox(height: 48),

              ElevatedButton(
                onPressed: () {}, // Mantenha a lógica de onPressed aqui se houver
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Cor vibrante para o botão (ex: verde)
                  foregroundColor: Colors.black, // Cor branca para o texto
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Cantos arredondados no botão
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16), // Ajuste o padding vertical
                ),
                child: const Text('Comprar', style: TextStyle(fontSize: 16)), // Texto do botão
              ),

              
            ],
          ),
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0), // Dá um respiro ao redor do botão
        color: Colors.white, // Opcional: deixa o fundo do rodapé branco
        child: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Voltar', 
            style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}