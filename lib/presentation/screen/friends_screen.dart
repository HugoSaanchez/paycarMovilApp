import 'package:flutter/material.dart';
import 'package:paycar/presentation/message_screen.dart';
import 'package:paycar/presentation/screen/friends_request_screen.dart';
import 'package:paycar/service/usuario_service.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({Key? key}) : super(key: key);

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final UsuarioService usuarioService = UsuarioService();
  late Future<List<Map<String, dynamic>>> amigosFuture;
  late Future<int> numeroAmigosFuture;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    amigosFuture = usuarioService.verAmigosConfirmados();
    numeroAmigosFuture = usuarioService.obtenerNumeroAmigos();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _addFriend() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2F3640),
          title: const Text(
            'Agregar Amigo',
            style: TextStyle(color: Colors.green),
          ),
          content: TextField(
            controller: _textController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Ingrese el correo del usuario',
              hintStyle: const TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.green),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.green),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Agregar',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () async {
                final email = _textController.text;
                if (email.isNotEmpty) {
                  final usuario = await usuarioService.buscarPorEmail(email);
                  if (usuario != null) {
                    print('Usuario encontrado: ID = ${usuario['id']}');
                    final result = await usuarioService.agregarAmigo(usuario['id']);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result)),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Usuario no encontrado')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Correo electrónico no válido')),
                  );
                }
                Navigator.of(context).pop();
                setState(() {
                  amigosFuture = usuarioService.verAmigosConfirmados();
                  numeroAmigosFuture = usuarioService.obtenerNumeroAmigos();
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _viewFriendRequests() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FriendRequestsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Amigos'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.green),
            onPressed: _addFriend,
          ),
          FutureBuilder<int>(
            future: numeroAmigosFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Stack(
                  children: [
                    const Icon(Icons.group_add, color: Colors.green),
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: const Text(
                          '',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return const Icon(Icons.group_add, color: Colors.green);
              } else {
                final int numAmigos = snapshot.data ?? 0;
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.group_add, color: Colors.green),
                      onPressed: _viewFriendRequests,
                    ),
                    if (numAmigos > 0)
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          child: Text(
                            '$numAmigos',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              }
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: amigosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No tienes amigos.', style: TextStyle(color: Colors.white)));
            } else {
              final amigos = snapshot.data!;
              return ListView.builder(
                itemCount: amigos.length,
                itemBuilder: (context, index) {
                  final amigo = amigos[index];
                  return Card(
                    color: Colors.grey[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(
                        color: Colors.green,
                        width: 1.5,
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        amigo['nombre'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        'Username: ${amigo['username']}\nRol: ${amigo['rol']}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.chat, color: Colors.green),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MessageDetailsScreen(
                                idReceptor: amigo['id'], // Asumiendo que 'id' es el ID del receptor
                                nombreReceptor: amigo['nombre'],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
