import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bcrypt/bcrypt.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSubmitting = false;
  String? _userId;
  String? _storedHashedPassword;

  @override
  void initState() {
    super.initState();
    _getUserId();
  }

  Future<void> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId'); // Recupera el ID del usuario
    });
    if (_userId != null) {
      _getStoredPassword(); // Obtener la contraseña almacenada
    }
  }

  Future<void> _getStoredPassword() async {
    // Obtén la contraseña almacenada desde Firestore
    if (_userId != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(_userId)
          .get();

      setState(() {
        _storedHashedPassword = userSnapshot['password'];
      });
    }
  }

  String _hashPassword(String password) {
    // Hashear la contraseña usando bcrypt
    return BCrypt.hashpw(password, BCrypt.gensalt());
  }

  bool _verifyPassword(String password, String hashedPassword) {
    // Verificar la contraseña usando bcrypt
    return BCrypt.checkpw(password, hashedPassword);
  }

  Future<void> _changePassword() async {
    // Validación de que las contraseñas coinciden
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las contraseñas no coinciden'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validación de la contraseña actual
    if (_storedHashedPassword != null) {
      bool isCurrentPasswordCorrect = _verifyPassword(
          _currentPasswordController.text, _storedHashedPassword!);

      if (!isCurrentPasswordCorrect) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La contraseña actual no es correcta'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo obtener la contraseña actual'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Hashear la nueva contraseña
      String hashedPassword = _hashPassword(_newPasswordController.text);

      // Actualiza la contraseña en Firestore
      if (_userId != null) {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(_userId)
            .update({'password': hashedPassword});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contraseña cambiada con éxito'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo recuperar el ID del usuario'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cambiar la contraseña: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });

      // Navegar de regreso a la pantalla anterior
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cambiar Contraseña',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ingrese su contraseña actual y nueva para cambiarla.',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _currentPasswordController,
                      labelText: 'Contraseña Actual',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _newPasswordController,
                      labelText: 'Nueva Contraseña',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _confirmPasswordController,
                      labelText: 'Confirmar Nueva Contraseña',
                    ),
                    const SizedBox(height: 20),
                    _isSubmitting
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _changePassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: Text('Cambiar Contraseña'),
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildSecurityMessage(),
          ],
        ),
      ),
      backgroundColor: Colors.white, // Fondo blanco para la pantalla
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
  }) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildSecurityMessage() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Asegúrese de que la nueva contraseña sea segura. Incluya letras, números y caracteres especiales para mayor seguridad.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[800],
          ),
        ),
      ),
    );
  }
}
