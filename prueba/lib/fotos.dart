import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PhotoScreen extends StatefulWidget {
  const PhotoScreen({super.key});

  @override
  _PhotoScreenState createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  List<XFile>? _imageFiles;
  final ImagePicker _picker = ImagePicker();
  String? _userId; // Variable para almacenar el userId
  bool _isLoading = false; // Variable para el estado de carga
  final FirebaseStorage _storage =
      FirebaseStorage.instance; // Inicializa Firebase Storage
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Inicializa Firestore

  @override
  void initState() {
    super.initState();
    _getUserId(); // Recuperar el userId cuando la pantalla se inicia
  }

  Future<void> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString(
          'userId'); // Asegúrate de que 'userId' esté guardado en SharedPreferences
    });
  }

  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _imageFiles = pickedFiles;
        _isLoading = true; // Activar el estado de carga
      });

      // Guardar las imágenes en la colección
      for (var file in _imageFiles!) {
        await saveImageToCollection(
            _userId, file); // Llama a la función para guardar la imagen
      }

      setState(() {
        _isLoading = false; // Desactivar el estado de carga
      });
    }
  }

  Future<void> saveImageToCollection(String? userId, XFile file) async {
    try {
      // Sube la imagen a Firebase Storage
      final filePath = 'images/$userId/${file.name}';
      await _storage.ref(filePath).putFile(File(file.path));

      // Obtiene la URL de descarga de la imagen
      String downloadUrl = await _storage.ref(filePath).getDownloadURL();

      // Guarda la URL en Firestore
      await _firestore.collection('fotos').add({
        'userId': userId,
        'imageUrl': downloadUrl,
        'timestamp': FieldValue.serverTimestamp(), // Guarda la fecha y hora
      });
    } catch (e) {
      print('Error al guardar la imagen: $e');
      // Manejo de errores (opcional)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Fotos'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
                  children: [
                    const Text(
                      'Agrega imágenes a tu viaje',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _pickImages,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                      ),
                      child: const Text('Seleccionar Imágenes'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator()) // Disco de carga
            else
              Expanded(
                child: _imageFiles == null
                    ? const Center(
                        child: Text('No se han seleccionado imágenes.'))
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _imageFiles!.length,
                        itemBuilder: (context, index) {
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 4,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(_imageFiles![index].path),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
