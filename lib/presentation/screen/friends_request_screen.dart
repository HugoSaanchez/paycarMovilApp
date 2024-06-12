import 'package:flutter/material.dart';
import 'package:paycar/service/usuario_service.dart';
import 'main_screen.dart'; // Importa MainScreen

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({Key? key}) : super(key: key);

  @override
  _FriendRequestsScreenState createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  final UsuarioService usuarioService = UsuarioService();
  late Future<List<Map<String, dynamic>>> solicitudesFuture;

  @override
  void initState() {
    super.initState();
    solicitudesFuture = usuarioService.verAmigos();
  }

  void _aceptarSolicitud(int idUsuario) async {
    try {
      String result = await usuarioService.confirmarAmigo(idUsuario);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
      setState(() {
        solicitudesFuture = usuarioService.verAmigos(); // Refrescar la lista de solicitudes
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _rechazarSolicitud(int idUsuario) async {
    try {
      String result = await usuarioService.rechazarAmigo(idUsuario);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen(selectedIndex: 1)), // Navegar a MainScreen con la pestaña de Amigos seleccionada
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Solicitudes de Amistad',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
      backgroundColor: Color(0xFF2F3640),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: solicitudesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No tienes solicitudes de amistad.', style: TextStyle(color: Colors.white)));
            } else {
              final solicitudes = snapshot.data!;
              return ListView.builder(
                itemCount: solicitudes.length,
                itemBuilder: (context, index) {
                  final solicitud = solicitudes[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F3640),
                      borderRadius: BorderRadius.circular(10),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.green,
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        solicitud['nombre'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        'Username: ${solicitud['username']}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.check, color: Colors.green),
                            onPressed: () => _aceptarSolicitud(solicitud['id']),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.red),
                            onPressed: () => _rechazarSolicitud(solicitud['id']),
                          ),
                        ],
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
