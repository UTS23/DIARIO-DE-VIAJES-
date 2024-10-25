import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prueba/ProfileScreen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Panel de Administrador',
          style: TextStyle(color: Colors.teal),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.teal),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bienvenido, Administrador',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 20),

              // Sección de Usuarios
              _buildCollectionSection(
                context: context,
                title: 'Usuarios',
                stream: FirebaseFirestore.instance
                    .collection('usuarios')
                    .snapshots(),
                itemBuilder: (context, doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _buildListItem(
                    context: context,
                    title: '${data['Nombres']} ${data['Apellidos']}',
                    subtitle: 'Correo: ${data['Correo']}',
                    trailing: 'Edad: ${data['Edad']}',
                    onEdit: () => _editUser(context, doc.id, data),
                    onDelete: () => _deleteUser(context, doc.id),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Sección de Viajes
              _buildCollectionSection(
                context: context,
                title: 'Viajes',
                stream:
                    FirebaseFirestore.instance.collection('viajes').snapshots(),
                itemBuilder: (context, doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _buildListItem(
                    context: context,
                    title: data['titulo'] ?? 'Sin título',
                    subtitle:
                        'Descripción: ${data['descripcion'] ?? 'No disponible'}',
                    trailing: 'Fecha: ${data['fecha'] ?? 'No disponible'}',
                    onEdit: () => _editTrip(context, doc.id, data),
                    onDelete: () => _deleteTrip(context, doc.id),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Sección de Chats
              _buildCollectionSection(
                context: context,
                title: 'Chats',
                stream:
                    FirebaseFirestore.instance.collection('chats').snapshots(),
                itemBuilder: (context, doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _buildListItem(
                    context: context,
                    title: data['remitente'] ?? 'Desconocido',
                    subtitle:
                        'Mensaje: ${data['contenido'] ?? 'Sin contenido'}',
                    trailing: 'Fecha: ${data['fecha'] ?? 'No disponible'}',
                    onEdit: () => _editChat(context, doc.id, data),
                    onDelete: () => _deleteChat(context, doc.id),
                  );
                },
              ),

              const SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacementNamed(context, '/LoginScreen');
                    } catch (e) {
                      print('Error al cerrar sesión: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Error al cerrar sesión')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: const Text('Cerrar Sesión'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollectionSection({
    required BuildContext context,
    required String title,
    required Stream<QuerySnapshot> stream,
    required Widget Function(BuildContext context, DocumentSnapshot doc)
        itemBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: stream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Text('Error al cargar los datos');
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text('No hay datos disponibles');
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];
                return itemBuilder(context, doc);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildListItem({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String trailing,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.2),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  void _editUser(
      BuildContext context, String userId, Map<String, dynamic> data) {
    TextEditingController nameController =
        TextEditingController(text: data['Nombres']);
    TextEditingController lastNameController =
        TextEditingController(text: data['Apellidos']);
    TextEditingController emailController =
        TextEditingController(text: data['Correo']);
    TextEditingController ageController =
        TextEditingController(text: data['Edad'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombres'),
              ),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Apellidos'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Correo'),
              ),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(labelText: 'Edad'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('usuarios')
                    .doc(userId)
                    .update({
                  'Nombres': nameController.text,
                  'Apellidos': lastNameController.text,
                  'Correo': emailController.text,
                  'Edad': int.parse(ageController.text),
                });
                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Usuario'),
          content: const Text('¿Estás seguro de eliminar este usuario?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('usuarios')
                    .doc(userId)
                    .delete();
                Navigator.of(context).pop();
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _editTrip(
      BuildContext context, String tripId, Map<String, dynamic> data) {
    TextEditingController titleController =
        TextEditingController(text: data['titulo']);
    TextEditingController descriptionController =
        TextEditingController(text: data['descripcion']);
    TextEditingController dateController =
        TextEditingController(text: data['fecha']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Viaje'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Fecha'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('viajes')
                    .doc(tripId)
                    .update({
                  'titulo': titleController.text,
                  'descripcion': descriptionController.text,
                  'fecha': dateController.text,
                });
                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _deleteTrip(BuildContext context, String tripId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Viaje'),
          content: const Text('¿Estás seguro de eliminar este viaje?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('viajes')
                    .doc(tripId)
                    .delete();
                Navigator.of(context).pop();
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _editChat(
      BuildContext context, String chatId, Map<String, dynamic> data) {
    TextEditingController senderController =
        TextEditingController(text: data['remitente']);
    TextEditingController contentController =
        TextEditingController(text: data['contenido']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Chat'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: senderController,
                decoration: const InputDecoration(labelText: 'Remitente'),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Contenido'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('chats')
                    .doc(chatId)
                    .update({
                  'remitente': senderController.text,
                  'contenido': contentController.text,
                });
                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _deleteChat(BuildContext context, String chatId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Chat'),
          content: const Text('¿Estás seguro de eliminar este chat?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('chats')
                    .doc(chatId)
                    .delete();
                Navigator.of(context).pop();
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
}

// Función para obtener documentos de la colección 'ayuda'
Future<List<Map<String, dynamic>>> getAyudaCollection() async {
  QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('ayuda').get();
  return snapshot.docs
      .map((doc) => doc.data() as Map<String, dynamic>)
      .toList();
}

// Función para agregar un nuevo documento a la colección 'ayuda'
Future<void> addHelp(String titulo, String descripcion) async {
  await FirebaseFirestore.instance.collection('ayuda').add({
    'titulo': titulo,
    'descripcion': descripcion,
  });
}

// Función para editar un documento en la colección 'ayuda'
Future<void> updateHelp(String docId, String titulo, String descripcion) async {
  await FirebaseFirestore.instance.collection('ayuda').doc(docId).update({
    'titulo': titulo,
    'descripcion': descripcion,
  });
}

// Función para eliminar un documento de la colección 'ayuda'
Future<void> deleteHelp(String docId) async {
  await FirebaseFirestore.instance.collection('ayuda').doc(docId).delete();
}
