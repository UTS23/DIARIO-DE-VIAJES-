import 'package:flutter/material.dart';

class UserDetailScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const UserDetailScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Usuario'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nombre: ${userData['Nombres']} ${userData['Apellidos']}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Correo: ${userData['Correo']}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('Edad: ${userData['Edad']}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('Ocupación: ${userData['Ocupacion']}',
                style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
