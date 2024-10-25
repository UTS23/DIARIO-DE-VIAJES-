import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prueba/cambio.dart'; // Asegúrate de que esta ruta sea correcta

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  _NotificationSettingsScreenState createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _notificationsEnabled = true; // Estado del interruptor de notificaciones
  bool _showFingerprint = false; // Estado del interruptor para mostrar huella

  String _localNotificationId =
      ""; // Variable para almacenar ID local de notificaciones
  String _localFingerprintId = ""; // Variable para almacenar ID local de huella

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _showFingerprint = prefs.getBool('showFingerprint') ?? false;

      // Asignar valores locales para simular IDs
      _localNotificationId = _notificationsEnabled ? "notiID123" : "notiID456";
      _localFingerprintId = _showFingerprint ? "fingerID123" : "fingerID456";
    });
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setBool('showFingerprint', _showFingerprint);

    // Guardar valores en variables adicionales cuando cambie el estado
    setState(() {
      _localNotificationId = _notificationsEnabled ? "notiID123" : "notiID456";
      _localFingerprintId = _showFingerprint ? "fingerID123" : "fingerID456";
    });
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Información de la Aplicación'),
          content: const Text(
              'Desarrollador: Ing Brayan Steven Moreno Soto\nVersión: 1.0 \n2024'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Configuración de Notificaciones',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white, // Cambia el color a blanco
        iconTheme: const IconThemeData(color: Colors.black), // Íconos en negro
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline), // Ícono de información
            onPressed: _showInfoDialog, // Muestra el diálogo al presionar
          ),
        ],
      ),
      body: Container(
        width: double.infinity, // Ajustar al ancho completo
        padding: const EdgeInsets.all(16.0), // Espaciado uniforme
        decoration: const BoxDecoration(
          color: Colors.white, // Fondo blanco para la pantalla
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          // Permite desplazamiento si el contenido excede la pantalla
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Configuraciones de Notificaciones',
                style: TextStyle(
                  fontSize: 24, // Tamaño de texto ajustado
                  fontWeight: FontWeight.w800,
                  color: Colors.teal,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 20), // Espacio reducido
              _buildCard(
                title: 'Notificaciones:',
                description:
                    'Recibirás notificaciones sobre actualizaciones y recordatorios.',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Activar notificaciones',
                        style: TextStyle(fontSize: 16)),
                    Switch(
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                          _saveSettings();
                        });
                      },
                      activeColor: Colors.teal,
                      inactiveThumbColor: Colors.grey,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20), // Espacio reducido
              _buildCard(
                title: 'Inicio de Sesión:',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Mostrar huella en la pantalla de inicio',
                        style: TextStyle(fontSize: 16)),
                    Switch(
                      value: _showFingerprint,
                      onChanged: (value) {
                        setState(() {
                          _showFingerprint = value;
                          _saveSettings();
                        });
                      },
                      activeColor: Colors.teal,
                      inactiveThumbColor: Colors.grey,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangePasswordScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // Botón en color teal
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: Text('Cambiar Contraseña'),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'ID de Notificaciones (local): $_localNotificationId',
                style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black), // Tamaño de texto reducido
              ),
              Text(
                'ID de Huella (local): $_localFingerprintId',
                style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black), // Tamaño de texto reducido
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.grey[100], // Fondo claro para mejorar la UX
    );
  }

  Widget _buildCard(
      {required String title, Widget? child, String? description}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 8, // Aumenta la elevación para dar más profundidad
      shadowColor: Colors.grey[400], // Sombra más clara
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
            const SizedBox(height: 10),
            child ?? Container(),
          ],
        ),
      ),
    );
  }
}
