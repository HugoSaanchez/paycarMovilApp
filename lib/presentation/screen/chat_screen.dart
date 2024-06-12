import 'package:flutter/material.dart';
import 'package:paycar/presentation/message_screen.dart';
import 'package:paycar/service/chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Chats",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
      backgroundColor: Color(0xFF2F3640),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: chatService.obtenerDetallesReceptores(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child: Text('Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.red)));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                  child: Text("No tienes chats activos.",
                      style: TextStyle(color: Colors.white)));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var usuario = snapshot.data![index];
                  String nombre = usuario['nombre'];
                  int idReceptor = usuario['id']; // Suponiendo que también tienes el ID en los datos

                  return FutureBuilder<int>(
                    future: chatService
                        .obtenerConteoMensajesNoLeidosDeUsuario(idReceptor),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ListTile(
                          title: Text(
                            nombre,
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text('Cargando...',
                              style: TextStyle(color: Colors.white)),
                        );
                      } else if (snapshot.hasError) {
                        return ListTile(
                          title: Text(
                            nombre,
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text('Error al cargar mensajes no leídos',
                              style: TextStyle(color: Colors.red)),
                        );
                      } else {
                        int noLeidos = snapshot.data!;
                        return InkWell(
                          onTap: () async {
                            // Marcar mensajes como leídos
                            await chatService.marcarMensajesComoLeidos(idReceptor);

                            // Navegar a la pantalla de detalles del mensaje
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MessageDetailsScreen(
                                  idReceptor: idReceptor,
                                  nombreReceptor: nombre,
                                ),
                              ),
                            );
                          },
                          child: Container(
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
                              leading: CircleAvatar(
                                backgroundColor: Colors.green,
                                child: Text(
                                  nombre.isNotEmpty
                                      ? nombre[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    nombre,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  if (noLeidos > 0)
                                    Container(
                                      margin: const EdgeInsets.only(left: 8.0),
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '$noLeidos',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    },
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
