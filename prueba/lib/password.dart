import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importa Firestore
import 'package:lottie/lottie.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
// Importa el paquete Lottie

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor ingresa tu correo electrónico')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Verifica si el correo está en la colección de usuarios
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('Correo', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        // Envía un correo de recuperación usando SMTP
        await _sendRecoveryEmail(email);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enlace de restablecimiento enviado a tu correo'),
            backgroundColor: Colors.teal,
          ),
        );
        Navigator.pop(context); // Regresar a la pantalla de inicio de sesión
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('El correo no está registrado en el sistema')),
        );
      }
    } catch (error) {
      print("Error al enviar el enlace de restablecimiento: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar el enlace: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendRecoveryEmail(String email) async {
    final smtpServer = SmtpServer(
      'smtp.gmail.com', // Cambia esto con el servidor SMTP correcto
      port: 587, // Cambia el puerto si es necesario
      username: 'mosoto231242@gmail.com',
      password: 'dgip bxlc cmwc hqsh',
    );

    final message = Message()
      ..from = const Address('mosoto231242@gmail.com', 'Soporte de Aplicación')
      ..recipients.add(email)
      ..subject = 'Recuperación de Contraseña'
      ..html = """
      <html>
        <body>
          <h1>Recuperación de Contraseña</h1>
          <p>Hola,</p>
          <p>Hemos recibido una solicitud para restablecer la contraseña de tu cuenta.</p>
          <p>Por favor, haz clic en el siguiente enlace para restablecer tu contraseña:</p>
          <p>
            <a href="https://example.com/reset-password" style="color: #007BFF; text-decoration: none;">Restablecer Contraseña</a>
          </p>
          <p>O puedes volver a la <a href="https://example.com/pantalla-inicio" style="color: #007BFF; text-decoration: none;">pantalla de inicio</a>.</p>
          <p>Si no solicitaste este cambio, por favor ignora este mensaje.</p>
          <p>Saludos,</p>
          <p>El equipo de soporte</p>
        </body>
      </html>
      """;

    try {
      final sendReport = await send(message, smtpServer);
      print('Mensaje enviado: ${sendReport.toString()}');
    } catch (e) {
      print('Error al enviar el mensaje: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restablecer Contraseña'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Lottie.asset(
                'assets/images/qw.json', // Añade la animación Lottie aquí
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text(
                        'Restablecer Contraseña',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Correo electrónico',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _resetPassword,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 32,
                          ),
                        ),
                        child: const Text('Enviar Enlace de Restablecimiento',
                            style: TextStyle(color: Colors.black)),
                      ),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child:
                              CircularProgressIndicator(), // Muestra la animación de carga
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
