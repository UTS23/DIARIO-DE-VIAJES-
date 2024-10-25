import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:prueba/login.dart'; // Asegúrate de que este archivo exista y esté correctamente importado

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _ocupacionController = TextEditingController();

  bool _isLoading = false;

  Future<void> _registerUser(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    CollectionReference usuarios =
        FirebaseFirestore.instance.collection('usuarios');

    String emailPattern = r'^[^@]+@[^@]+\.[^@]+';
    RegExp regExp = RegExp(emailPattern);

    if (!regExp.hasMatch(_correoController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor ingresa un correo electrónico válido.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (_nombresController.text.trim().isEmpty ||
        _apellidosController.text.trim().isEmpty ||
        _correoController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _edadController.text.trim().isEmpty ||
        _ocupacionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todos los campos son obligatorios.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Verificar si el correo ya está registrado
    var querySnapshot = await usuarios
        .where('Correo', isEqualTo: _correoController.text.trim())
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('El correo electrónico ya está registrado.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      String hashedPassword =
          BCrypt.hashpw(_passwordController.text.trim(), BCrypt.gensalt());

      await usuarios.add({
        'Nombres': _nombresController.text.trim(),
        'Apellidos': _apellidosController.text.trim(),
        'Correo': _correoController.text.trim(),
        'password': hashedPassword,
        'Edad': int.tryParse(_edadController.text.trim()) ?? 0,
        'Ocupacion': _ocupacionController.text.trim(),
      });

      // Navegar a la pantalla de inicio de sesión después de 3 segundos
      Future.delayed(const Duration(seconds: 3), () {
        setState(() {
          _isLoading = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar el usuario: $error')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Usuario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Registro de Usuario',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _nombresController,
                    label: 'Nombres',
                    icon: Icons.person,
                  ),
                  _buildTextField(
                    controller: _apellidosController,
                    label: 'Apellidos',
                    icon: Icons.person_outline,
                  ),
                  _buildTextField(
                    controller: _correoController,
                    label: 'Correo',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Contraseña',
                    icon: Icons.lock,
                    isPassword: true,
                  ),
                  _buildTextField(
                    controller: _edadController,
                    label: 'Edad',
                    icon: Icons.calendar_today,
                    keyboardType: TextInputType.number,
                  ),
                  _buildTextField(
                    controller: _ocupacionController,
                    label: 'Ocupación',
                    icon: Icons.work,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed:
                          _isLoading ? null : () => _registerUser(context),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 32,
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Registrarse',
                              style: TextStyle(fontSize: 16),
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
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
