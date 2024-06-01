import 'package:flutter/material.dart';
import 'package:paycar/presentation/message_screen.dart';
import 'package:paycar/service/chat_service.dart';
 // Asegúrate de importar la pantalla de detalles

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
        title: Text("Chats"),
        backgroundColor: Color(0xFF2F3640),
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
              return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("No tienes chats activos.", style: TextStyle(color: Colors.white)));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var usuario = snapshot.data![index];
                  String nombre = usuario['nombre'];
                  int idReceptor = usuario['id'];  // Suponiendo que también tienes el ID en los datos
                  return InkWell(
                    onTap: () {
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
                    child: Card(
                      color: Colors.grey[900],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.green, width: 1.5),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Text(
                            nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          nombre,
                          style: TextStyle(color: Colors.white),
                        ),
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
