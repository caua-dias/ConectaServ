import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  bool _clientHovered = false;
  bool _companyHovered = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      body: Center(
        child: SingleChildScrollView( 
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, 
              children: [
                
                _buildRegisterSection(
                  title: 'Registro para ser cliente',
                  imageUrl: 'https://cdn-icons-png.flaticon.com/512/3011/3011270.png', 
                  isHovered: _clientHovered,
                  onHover: (hovered) {
                    setState(() {
                      _clientHovered = hovered;
                    });
                  },
                ),
                const SizedBox(height: 48), 

                
                _buildRegisterSection(
                  title: 'Registro para ser empresa',
                  imageUrl: 'https://cdn-icons-png.flaticon.com/512/3233/3233290.png', 
                  isHovered: _companyHovered,
                  onHover: (hovered) {
                    setState(() {
                      _companyHovered = hovered;
                    });
                  },
                ),
                const Spacer(), 

                Center(
                  child: TextButton(
                    onPressed: () {
                     
                      Navigator.pop(context); 
                    },
                    child: const Text(
                      'Retornar para o login',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blueAccent, 
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildRegisterSection({
    required String title,
    required String imageUrl,
    required bool isHovered,
    required ValueChanged<bool> onHover,
  }) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16), 

        
        MouseRegion(
          onEnter: (_) => onHover(true), 
          onExit: (_) => onHover(false), 
          child: GestureDetector(
            onTap: () {
              
              print('Selecionado registro de: $title');
            },
           
            child: AnimatedScale(
              scale: isHovered ? 1.15 : 1.0, 
              duration: const Duration(milliseconds: 200), 
              curve: Curves.easeInOut, 
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[100], 
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                  
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Image.network(
                    imageUrl, 
                    fit: BoxFit.contain, 
                    errorBuilder: (context, error, stackTrace) {
                  
                      return const Icon(
                        Icons.image_not_supported,
                        size: 80,
                        color: Colors.grey,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}