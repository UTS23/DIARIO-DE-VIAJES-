import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:prueba/ayuda.dart';
import 'package:prueba/password.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bcrypt/bcrypt.dart';
import 'MyHomePage.dart';
import 'admin_screen.dart';
import 'register.dart';

import 'package:lottie/lottie.dart'; // Asegúrate de haber agregado esta dependencia en pubspec.yaml

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _showFingerprint = false;
  bool _obscurePassword = true; // Controla la visibilidad de la contraseña
  final LocalAuthentication _localAuth = LocalAuthentication();
  String? storedUserId; // Nueva variable para almacenar el ID del usuario

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _showFingerprint = prefs.getBool('showFingerprint') ?? false;
    });
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Por favor autentíquese para iniciar sesión',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? userId = prefs.getString('userId');

        if (userId != null) {
          // Almacenamos el ID en la variable `storedUserId`
          setState(() {
            storedUserId = userId;
          });

          print('El ID del usuario es: $storedUserId');

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
          );
        } else {
          _showSnackBar('No se pudo recuperar el usuario.');
        }
      } else {
        _showSnackBar('Autenticación fallida');
      }
    } catch (e) {
      _showSnackBar('Error de autenticación: ${e.toString()}');
    }
  }

  Future<void> _login(BuildContext context) async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Correo y contraseña son requeridos');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (email == 'admin@gmail.com' && password == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminScreen()),
        );
        return;
      }

      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('Correo', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        var userDoc = userQuery.docs.first;
        String storedHashedPassword = userDoc['password'];
        bool passwordMatch = BCrypt.checkpw(password, storedHashedPassword);

        if (passwordMatch) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', userDoc.id);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
          );
        } else {
          _showSnackBar('Contraseña incorrecta');
        }
      } else {
        _showSnackBar('Correo no registrado');
      }
    } catch (error) {
      _showSnackBar('Error al iniciar sesión: ${error.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterScreen()),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.deepPurpleAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ForgotPasswordScreen()), // Cambia a ForgotPasswordScreen
    );
  }

  void _navigateToHelp() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => HelpScreen()), // Navega a la pantalla de ayuda
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Center(
          child: Image.asset(
            'assets/images/Colombia.png',
            height: 40,
            width: 40,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Iniciar Sesión',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help, color: Colors.black),
            onPressed: _navigateToHelp, // Navega a la pantalla de ayuda
            tooltip: 'Ayuda',
            padding: const EdgeInsets.all(8),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Card(
                color: Colors.white,
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Lottie.asset('assets/images/qw.json',
                          height: 150), // Aquí está la animación
                      _buildTextField(
                        controller: _emailController,
                        label: 'Correo',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Contraseña',
                        icon: Icons.lock,
                        isPassword: true,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => _login(context),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Iniciar Sesión',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _navigateToForgotPassword,
                        child: const Text(
                          '¿Olvidaste tu contraseña?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _navigateToRegister,
                        child: const Text(
                          '¿No tienes cuenta? Regístrate',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_showFingerprint)
                        Center(
                          child: ElevatedButton(
                            onPressed: _authenticateWithBiometrics,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(20),
                            ),
                            child: const Icon(Icons.fingerprint,
                                color: Colors.white, size: 32),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            ),
        ],
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
        obscureText:
            isPassword ? _obscurePassword : false, // Controla la visibilidad
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.black54,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword =
                          !_obscurePassword; // Cambia la visibilidad
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
