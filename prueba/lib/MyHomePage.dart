import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart'; // Importar CurvedNavigationBar
import 'package:prueba/DetailScreen.dart';
import 'package:prueba/ProfileScreen.dart';
import 'package:prueba/SearchScreen.dart';
import 'package:prueba/add.dart';
import 'package:prueba/confi.dart';
import 'package:prueba/mensajes.dart';
import 'package:prueba/perfil.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importar SharedPreferences
import 'package:lottie/lottie.dart'; // Importar Lottie

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  String? _userId; // Variable para almacenar el userId

  @override
  void initState() {
    super.initState();
    _getUserId(); // Recuperar el userId cuando la pantalla se inicia
  }

  Future<void> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
    });
  }

  final List<Widget> _pages = [
    HomeScreen(),
    SearchScreen(),
    Profile(),
    MessagesScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Diario de Viajes',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 26,
              letterSpacing: 1.2,
            ),
          ),
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        body: const Center(
          child:
              CircularProgressIndicator(), // Indicador de carga si userId es nulo
        ),
        floatingActionButton:
            const SizedBox(), // Ocultar el botón flotante si userId es nulo
        bottomNavigationBar:
            const SizedBox(), // Ocultar la barra de navegación si userId es nulo
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Diario de Viajes',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 26,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      NotificationSettingsScreen(), // Navegar a la pantalla de configuración
                ),
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddScreen(userId: _userId!), // Pasar userId a AddScreen
            ),
          );
        },
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 56,
          height: 56,
          child: Lottie.asset(
            'assets/images/plane.json', // Ruta a tu archivo Lottie
            fit: BoxFit.cover,
          ),
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 60.0,
        items: const <Widget>[
          Icon(Icons.home, size: 30, color: Colors.black),
          Icon(Icons.search, size: 30, color: Colors.black),
          Icon(Icons.person, size: 30, color: Colors.black),
          Icon(Icons.message, size: 30, color: Colors.black),
        ],
        color: Colors.white,
        buttonBackgroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _deleteTravel(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('viajes')
          .doc(documentId)
          .delete();
    } catch (e) {
      print('Error al eliminar el viaje: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId =
        (context.findAncestorStateOfType<_MyHomePageState>())?._userId;

    if (userId == null) {
      return const Center(child: Text('No se pudo recuperar el usuario.'));
    }

    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: _buildTravelList(context, userId),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bienvenido a tu Diario de Viajes',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Aquí puedes ver y organizar tus aventuras.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTravelList(BuildContext context, String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('viajes')
          .where('userId', isEqualTo: userId) // Filtrar por userId
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Ocurrió un error al cargar los viajes.',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                    'No hay viajes disponibles.'), // Mostrar mensaje si no hay viajes
                Lottie.asset(
                  'assets/images/cat.json', // Asegúrate de que el archivo JSON de la animación esté en la carpeta assets
                  width: 200,
                  height: 200,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var viaje = snapshot.data!.docs[index];

            return Dismissible(
              key: Key(viaje.id),
              background: Container(
                color: Colors.redAccent,
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                _deleteTravel(viaje.id);
              },
              child: Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                elevation: 6,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade100,
                    child: Lottie.asset(
                      'assets/images/qw.json', // Asegúrate de que el archivo JSON de la animación esté en la carpeta assets
                      width: 30,
                      height: 30,
                    ),
                  ),
                  title: Text(
                    viaje['nombre'] ?? 'Viaje ${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.teal.shade800,
                    ),
                  ),
                  subtitle: Text(viaje['descripcion'] ?? 'Sin descripción'),
                  trailing: Icon(Icons.arrow_forward_ios,
                      color: Colors.teal.shade800),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(
                          nombre: viaje['nombre'] ?? 'Viaje ${index + 1}',
                          descripcion:
                              viaje['descripcion'] ?? 'Sin descripción',
                          destino: viaje['destino'] ?? 'Destino desconocido',
                          fecha: viaje['fecha'] ?? 'Fecha desconocida',
                          documentId: viaje.id,
                          viajeId: null,
                          videoUrl: null,
                          userId: '',
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
