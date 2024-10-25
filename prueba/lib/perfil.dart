import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:prueba/EditFieldScreen.dart';
import 'package:prueba/LoadingScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? userId;
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _getUserId();
  }

  Future<void> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
    });
  }

  void _editField(String fieldName, String currentValue) {
    if (userId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditFieldScreen(
            fieldName: fieldName,
            currentValue: currentValue,
            userId: userId!,
          ),
        ),
      );
    }
  }

  Future<void> _logout() async {
    bool? shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar cierre de sesión'),
          content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoadingScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _captureAndSaveImage() async {
    try {
      // Obtén el RenderRepaintBoundary
      RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;

      // Captura la imagen en formato de bytes
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Guarda la imagen en el dispositivo
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/perfil_usuario.png';
      final File imgFile = File(path);
      await imgFile.writeAsBytes(pngBytes);

      // Muestra un mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imagen descargada con éxito')),
      );
    } catch (e) {
      // Manejo de errores
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al capturar la imagen')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Perfil',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download, color: Colors.teal),
            onPressed: _captureAndSaveImage,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _logout,
          ),
        ],
      ),
      body: userId == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('usuarios')
                  .doc(userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    !snapshot.data!.exists) {
                  return const Center(
                    child: Text(
                      'Error o no se encontró información del usuario',
                      style: TextStyle(fontSize: 18, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final userData = snapshot.data!.data()! as Map<String, dynamic>;

                // Envolver en RepaintBoundary para capturar la pantalla
                return RepaintBoundary(
                  key: _repaintBoundaryKey,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView(
                      children: [
                        _buildProfileCard(
                          icon: Icons.person,
                          title: 'Nombres:',
                          content: userData['Nombres'] ?? 'No disponible',
                          onEdit: () =>
                              _editField('Nombres', userData['Nombres'] ?? ''),
                        ),
                        const SizedBox(height: 16),
                        _buildProfileCard(
                          icon: Icons.person_outline,
                          title: 'Apellidos:',
                          content: userData['Apellidos'] ?? 'No disponible',
                          onEdit: () => _editField(
                              'Apellidos', userData['Apellidos'] ?? ''),
                        ),
                        const SizedBox(height: 16),
                        _buildProfileCard(
                          icon: Icons.email,
                          title: 'Correo:',
                          content: userData['Correo'] ?? 'No disponible',
                          onEdit: () =>
                              _editField('Correo', userData['Correo'] ?? ''),
                        ),
                        const SizedBox(height: 16),
                        _buildProfileCard(
                          icon: Icons.cake,
                          title: 'Edad:',
                          content:
                              userData['Edad']?.toString() ?? 'No disponible',
                          onEdit: () => _editField(
                              'Edad', userData['Edad']?.toString() ?? ''),
                        ),
                        const SizedBox(height: 16),
                        _buildProfileCard(
                          icon: Icons.work,
                          title: 'Ocupación:',
                          content: userData['Ocupacion'] ?? 'No disponible',
                          onEdit: () => _editField(
                              'Ocupacion', userData['Ocupacion'] ?? ''),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildProfileCard({
    required IconData icon,
    required String title,
    required String content,
    required VoidCallback onEdit,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Bordes redondeados
      ),
      elevation: 4,
      shadowColor: Colors.teal.withOpacity(0.3), // Sombra más suave
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.1), // Fondo del ícono
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.black, // Ícono negro
            size: 30,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w500, // Fuente seminegrita
            ),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.black), // Ícono negro
          onPressed: onEdit,
        ),
      ),
    );
  }
}
