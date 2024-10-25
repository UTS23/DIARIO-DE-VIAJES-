import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prueba/EditScreen.dart';
import 'dart:math';
import 'package:video_player/video_player.dart';

class DetailScreen extends StatelessWidget {
  final String nombre;
  final String descripcion;
  final String destino;
  final String fecha;
  final String documentId;

  DetailScreen({
    super.key,
    required this.nombre,
    required this.descripcion,
    required this.destino,
    required this.fecha,
    required this.documentId,
    required viajeId,
    required videoUrl,
    required String userId,
  });

  final List<String> _travelQuotes = [
    "El viaje es la recompensa. - Proverbio chino",
    "Viajar es vivir. - Hans Christian Andersen",
    "La aventura puede ser una experiencia extraordinaria, pero lo que realmente cuenta es el viaje. - David Platt",
    "No se viaja para escapar de la vida, sino para que la vida no se nos escape. - Anónimo",
    "Viajar es una manera de descubrir que el mundo es mucho más grande de lo que pensabas. - Anónimo",
    "La vida es un viaje y solo tú tienes el mapa. - Anónimo",
  ];

  String _getRandomQuote() {
    final random = Random();
    return _travelQuotes[random.nextInt(_travelQuotes.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalles del Viaje',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple[700], // Morado
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditScreen(
                    documentId: documentId,
                    nombre: nombre,
                    descripcion: descripcion,
                    destino: destino,
                    fecha: fecha,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 6,
                shadowColor: Colors.black54,
                color: Colors.white, // Fondo blanco
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                          icon: Icons.title, label: 'Nombre', value: nombre),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                          icon: Icons.description,
                          label: 'Descripción',
                          value: descripcion),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                          icon: Icons.location_on,
                          label: 'Destino',
                          value: destino),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                          icon: Icons.date_range, label: 'Fecha', value: fecha),
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          _getRandomQuote(),
                          style: TextStyle(
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                              color: Colors.purple[700]), // Morado
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('viajes')
                            .doc(documentId)
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(
                                child: Text(
                                    'Error al cargar los datos: ${snapshot.error}',
                                    style: const TextStyle(
                                        color: Colors.black))); // Texto negro
                          }
                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return const Center(
                                child: Text(
                                    'El documento no existe o no se encontró.',
                                    style: TextStyle(
                                        color: Colors.black))); // Texto negro
                          }

                          var videoUrl = snapshot.data!.get('videoUrl');
                          if (videoUrl != null && videoUrl.isNotEmpty) {
                            return VideoWidget(url: videoUrl);
                          } else {
                            return const Center(
                                child: Text('No hay video disponible',
                                    style: TextStyle(
                                        color: Colors.black))); // Texto negro
                          }
                        },
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

  Widget _buildDetailRow(
      {required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.purple[700], size: 30), // Morado
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[700]), // Morado
                ),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 16, color: Colors.black)), // Texto negro
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VideoWidget extends StatefulWidget {
  final String url;

  const VideoWidget({super.key, required this.url});

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _controller;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {}); // Actualiza la UI cuando el video está listo
        _controller.play(); // Reproduce el video automáticamente
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? SizedBox(
            width: double.infinity,
            height: 300, // Ajusta la altura del video
            child: Column(
              children: [
                Expanded(child: VideoPlayer(_controller)),
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.purple[700], // Morado
                  ),
                  onPressed: () {
                    setState(() {
                      _isPlaying ? _controller.pause() : _controller.play();
                      _isPlaying = !_isPlaying;
                    });
                  },
                ),
              ],
            ),
          )
        : const Center(child: CircularProgressIndicator());
  }
}
