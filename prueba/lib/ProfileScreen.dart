import 'package:flutter/material.dart';
import 'package:browser_launcher/browser_launcher.dart';

const _googleUrl = 'https://www.google.com/';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true; // Estado de carga
  String _errorMessage = ''; // Mensaje de error

  @override
  void initState() {
    super.initState();
    _launchBrowser();
  }

  Future<void> _launchBrowser() async {
    try {
      // Lanza un navegador Chrome abierto a [_googleUrl].
      await Chrome.start([_googleUrl]);
      print('Lanzado Chrome con la URL de Google');
    } catch (e) {
      print('Error al abrir el navegador: $e');
      setState(() {
        _errorMessage =
            'Error al abrir el navegador'; // Guarda el mensaje de error
      });
    } finally {
      setState(() {
        _isLoading = false; // Cambia el estado de carga a false
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navegador Web'),
      ),
      body: Center(
        child: _isLoading
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(), // Indicador de carga
                  SizedBox(height: 20),
                  Text(
                    'Cargando navegador...',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              )
            : _errorMessage.isNotEmpty // Muestra el mensaje de error si existe
                ? Text(
                    _errorMessage,
                    style: const TextStyle(fontSize: 20, color: Colors.red),
                  )
                : const Text(
                    'Navegador listo!',
                    style: TextStyle(fontSize: 20),
                  ),
      ),
    );
  }
}
