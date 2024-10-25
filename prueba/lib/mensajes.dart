import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ChatScreen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  String? currentUserId;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
  }

  Future<void> _loadCurrentUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getString('userId');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'I love traveling',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchField(),
          Expanded(child: _buildUserList(context)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Lógica para iniciar un nuevo chat
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comparte tus experiencias',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Aquí puedes ver usuarios registrados.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: 'Buscar usuarios...',
          prefixIcon: const Icon(Icons.search, color: Colors.black54),
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildUserList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('usuarios').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Error al cargar usuarios.',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No hay usuarios registrados.'));
        }

        var filteredUsers = snapshot.data!.docs.where((usuario) {
          var nombre = (usuario['Nombres'] ?? '').toLowerCase();
          var apellidos = (usuario['Apellidos'] ?? '').toLowerCase();
          return nombre.contains(searchQuery) ||
              apellidos.contains(searchQuery);
        }).toList();

        return ListView.builder(
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            var usuario = filteredUsers[index];

            if (usuario.id == currentUserId) {
              return const SizedBox.shrink();
            }

            return Dismissible(
              key: Key(usuario.id),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                // Implementar lógica para eliminar chats
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .where('users', arrayContains: currentUserId)
                    .where('chatUserId', isEqualTo: usuario.id)
                    .snapshots(),
                builder: (context, chatSnapshot) {
                  if (chatSnapshot.hasError) {
                    return const SizedBox.shrink();
                  }

                  int newMessagesCount = 0;
                  String lastMessage = 'No hay mensajes';
                  DateTime? lastMessageTime;

                  if (chatSnapshot.connectionState == ConnectionState.active) {
                    newMessagesCount = chatSnapshot.data!.docs
                        .where((doc) =>
                            !doc['isRead'] && doc['senderId'] != currentUserId)
                        .length;

                    if (chatSnapshot.data!.docs.isNotEmpty) {
                      var lastChatDoc = chatSnapshot.data!.docs.last;
                      lastMessage = lastChatDoc['message'] ?? 'Mensaje vacío';
                      lastMessageTime =
                          (lastChatDoc['timestamp'] as Timestamp).toDate();
                    }
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 4,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey[300],
                            child: const Icon(
                              Icons.person,
                              color: Colors.black87,
                              size: 30,
                            ),
                          ),
                          if (newMessagesCount > 0)
                            Positioned(
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6.0),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  newMessagesCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(
                        usuario['Nombres'] ?? 'Usuario ${index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            usuario['Apellidos'] ?? 'Sin apellidos',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  lastMessage,
                                  style: TextStyle(color: Colors.grey[500]),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (lastMessageTime != null)
                                Text(
                                  '${lastMessageTime.day}/${lastMessageTime.month}/${lastMessageTime.year}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios,
                          color: Colors.grey),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              currentUserId: currentUserId ?? '',
                              chatUserId: usuario.id,
                              chatUserName:
                                  usuario['Nombres'] ?? 'Usuario ${index + 1}',
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
