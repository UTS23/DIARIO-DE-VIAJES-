import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';

class HelpScreen extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayuda'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Aquí puedes encontrar ayuda sobre cómo utilizar la aplicación.',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              const Text(
                '1. Iniciar Sesión: Introduce tu correo y contraseña.',
                style: TextStyle(fontSize: 16),
              ),
              const Text(
                '2. Registro: Si no tienes cuenta, presiona "¿No tienes cuenta? Regístrate".',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 40),
              const Text(
                'Si necesitas más ayuda, completa el siguiente formulario:',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              _buildHelpForm(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpForm(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.help_outline, size: 48, color: Colors.black),
            const SizedBox(height: 20),
            _buildTextField(_nameController, 'Nombre'),
            const SizedBox(height: 16),
            _buildTextField(_emailController, 'Correo Electrónico',
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildTextField(_phoneController, 'Número de Teléfono',
                keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            _buildTextField(_messageController, 'Mensaje', maxLines: 4),
            const SizedBox(height: 20),
            _buildSubmitButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _submitForm(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const Text(
        'Enviar',
        style: TextStyle(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _submitForm(BuildContext context) async {
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String phone = _phoneController.text.trim();
    final String message = _messageController.text.trim();

    // Validación de campos
    if (name.isEmpty || email.isEmpty || phone.isEmpty || message.isEmpty) {
      _showSnackBar(context, 'Todos los campos son obligatorios');
      return;
    }

    // Mostrar animación de Lottie mientras se envía el formulario
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: SizedBox(
          width: 100,
          height: 100,
          child: Lottie.asset('assets/images/qw.json'),
        ),
      ),
    );

    try {
      // Guardar los datos en la colección "ayuda" en Firestore
      await FirebaseFirestore.instance.collection('ayuda').add({
        'nombre': name,
        'correo': email,
        'telefono': phone,
        'mensaje': message,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Cerrar el diálogo de carga
      Navigator.of(context).pop();

      _showSnackBar(context, 'Formulario enviado con éxito');

      // Regresar a la pantalla anterior después de un breve retraso
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).popUntil((route) => route.isFirst);
      });

      // Limpiar los campos después de enviar
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _messageController.clear();
    } catch (e) {
      Navigator.of(context)
          .pop(); // Cerrar el diálogo de carga en caso de error
      _showSnackBar(
          context, 'Error al enviar el formulario. Inténtalo de nuevo.');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.deepPurpleAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
