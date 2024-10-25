import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prueba/VideoScreen.dart';
import 'package:prueba/fotos.dart'; // Asegúrate de importar la pantalla de fotos

class AddScreen extends StatefulWidget {
  final String? userId;

  const AddScreen({super.key, this.userId});

  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _destinoController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _videoUrlController =
      TextEditingController(); // Controlador para la URL del video

  bool _isLoading = false;

  Future<void> _addViaje() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String? userId = widget.userId;

        if (userId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'No se encontró el ID de usuario. Inicia sesión nuevamente.'),
            ),
          );
          return;
        }

        // Agregar viaje a Firestore
        await FirebaseFirestore.instance.collection('viajes').add({
          'nombre': _nombreController.text,
          'descripcion': _descripcionController.text,
          'destino': _destinoController.text,
          'fecha': _fechaController.text,
          'videoUrl': _videoUrlController.text, // Guardar la URL del video
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Viaje agregado exitosamente')),
        );

        // Limpiar campos
        _nombreController.clear();
        _descripcionController.clear();
        _destinoController.clear();
        _fechaController.clear();
        _videoUrlController.clear(); // Limpiar el campo de URL del video

        Navigator.of(context).popUntil((route) => route.isFirst);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar el viaje: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Nuevo Viaje'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PhotoScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VideoScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ingrese los detalles del viaje',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildTextFormField(
                          controller: _nombreController,
                          labelText: 'Nombre del Viaje',
                          icon: Icons.title,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa el nombre del viaje';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                          controller: _descripcionController,
                          labelText: 'Descripción',
                          icon: Icons.description,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa una descripción';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                          controller: _destinoController,
                          labelText: 'Destino',
                          icon: Icons.location_on,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa el destino';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                          controller: _fechaController,
                          labelText: 'Fecha (YYYY-MM-DD)',
                          icon: Icons.date_range,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa una fecha';
                            }
                            if (!RegExp(r'^\d{4}-\d{2}-\d{2}$')
                                .hasMatch(value)) {
                              return 'Por favor ingresa una fecha válida (YYYY-MM-DD)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                          controller: _videoUrlController,
                          labelText: 'URL del Video',
                          icon: Icons.video_library,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa una URL de video';
                            }
                            if (!Uri.tryParse(value)!.isAbsolute) {
                              return 'Por favor ingresa una URL válida';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : Center(
                                child: ElevatedButton(
                                  onPressed: _addViaje,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 30,
                                      vertical: 15,
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  child: const Text('Agregar Viaje'),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '¡Gracias por agregar un viaje! Aquí puede ver todos los viajes que ha creado y explorar más sobre ellos.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.teal[600],
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required FormFieldValidator<String> validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _destinoController.dispose();
    _fechaController.dispose();
    _videoUrlController
        .dispose(); // Asegúrate de limpiar el controlador de URL de video
    super.dispose();
  }
}
