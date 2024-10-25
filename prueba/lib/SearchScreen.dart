import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prueba/DetailScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart'; // Importa Lottie

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _filteredViajes = [];
  bool _isLoading = false;
  String? _userId; // Variable para almacenar el userId

  @override
  void initState() {
    super.initState();
    _getUserId(); // Recuperar el userId cuando la pantalla se inicia
    _fetchViajes();
  }

  Future<void> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId =
          prefs.getString('userId'); // Obtiene el userId de SharedPreferences
    });
  }

  Future<void> _fetchViajes({String query = ''}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('viajes')
          .where('userId', isEqualTo: _userId) // Filtra por userId
          .where('nombre', isGreaterThanOrEqualTo: query)
          .where('nombre', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      _filteredViajes = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();

      setState(() {});
    } catch (e) {
      print('Error fetching viajes: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    _fetchViajes(query: value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Viajes'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                labelText: 'Buscar por nombre',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredViajes.isEmpty // Verifica si no hay viajes
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            'assets/images/cat.json', // Ruta a tu archivo Lottie
                            height: 200, // Ajusta la altura según necesites
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No hay viajes disponibles.',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: _filteredViajes.length,
                          itemBuilder: (context, index) {
                            final viaje = _filteredViajes[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Text(viaje['nombre']),
                                subtitle: Text(viaje['descripcion']),
                                trailing: Text(viaje['fecha']),
                                onTap: () {
                                  // Acción cuando se toca un viaje
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailScreen(
                                        nombre: viaje['nombre'],
                                        descripcion: viaje['descripcion'],
                                        destino: viaje['destino'],
                                        fecha: viaje['fecha'],
                                        documentId: viaje['id'],
                                        viajeId: '',
                                        videoUrl: '',
                                        userId: '',
                                      ),
                                    ),
                                  );
                                },
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
