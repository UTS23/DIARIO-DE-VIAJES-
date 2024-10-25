import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class NoViajesScreen extends StatelessWidget {
  const NoViajesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/images/cat.json', // Asegúrate de que el archivo JSON de la animación esté en la carpeta assets
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 20),
          const Text(
            'No hay viajes disponibles',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Añade tus próximos viajes y organiza tus aventuras',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
