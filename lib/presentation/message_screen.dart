import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importa el paquete intl para formatear las fechas
import 'package:flutter/services.dart'; // Para copiar al portapapeles
import 'package:paycar/model/mensaje_model.dart';
import 'package:paycar/service/chat_service.dart';
import 'package:paycar/service/grupo_service.dart';

class MessageDetailsScreen extends StatefulWidget {
  final int idReceptor;
  final String nombreReceptor;

  const MessageDetailsScreen({
    Key? key,
    required this.idReceptor,
    required this.nombreReceptor,
  }) : super(key: key);

  @override
  _MessageDetailsScreenState createState() => _MessageDetailsScreenState();
}

class _MessageDetailsScreenState extends State<MessageDetailsScreen> {
  final ChatService chatService = ChatService();
  final GrupoService grupoService = GrupoService();
  late int idEmisor; // ID del usuario autenticado
  final TextEditingController _messageController = TextEditingController();
  List<Mensaje> mensajes = [];
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    fetchInitialMessages();
    startPolling();
  }

  Future<void> fetchInitialMessages() async {
    idEmisor = await chatService.getAuthenticatedUserId();
    var initialMessages = await chatService.obtenerMensajes(widget.idReceptor);
    setState(() {
      mensajes = initialMessages;
    });
  }

  void startPolling() {
    _pollingTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
      var newMessages = await chatService.obtenerMensajes(widget.idReceptor);
      if (newMessages.isNotEmpty && (mensajes.isEmpty || newMessages.last.hora != mensajes.last.hora)) {
        setState(() {
          mensajes = newMessages; // Update the entire list to avoid duplicates
        });
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _pollingTimer?.cancel();
    super.dispose();
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      try {
        String response = await chatService.enviarMensaje(widget.idReceptor, _messageController.text.trim());
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response)));
        _messageController.clear();
        fetchInitialMessages();  // Refetch messages after sending to show new messages immediately
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al enviar mensaje: $e')));
      }
    }
  }

  bool isInvitationCode(String text) {
    return text.contains(RegExp(r'^[0-9a-fA-F\-]{36}$'));
  }

  void joinGroup(BuildContext context, String invitationCode) async {
    final response = await grupoService.joinGroup(invitationCode);
    if (response) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Te has unido al grupo exitosamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al unirse al grupo')),
      );
    }
  }

  Widget _buildMessage(Mensaje mensaje, int index) {
    bool isSentByMe = mensaje.idEmisor == idEmisor;
    DateTime messageDate = DateTime.parse(mensaje.hora);
    String formattedDate = DateFormat('dd-MM-yyyy').format(messageDate);

    bool showDate = true;
    if (index > 0) {
      DateTime previousMessageDate = DateTime.parse(mensajes[index - 1].hora);
      showDate = DateFormat('dd-MM-yyyy').format(previousMessageDate) != formattedDate;
    }

    return Column(
      children: <Widget>[
        if (showDate) // Muestra la fecha si es diferente del mensaje anterior
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(formattedDate, style: TextStyle(color: Colors.white54, fontSize: 12)),
          ),
        Align(
          alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
              color: isSentByMe ? Colors.green[400] : Colors.grey[800],
              borderRadius: BorderRadius.circular(20),
            ),
            child: isInvitationCode(mensaje.mensaje)
                ? InkWell(
                    onTap: () => joinGroup(context, mensaje.mensaje),
                    child: Text(
                      mensaje.mensaje,
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                : Text(
                    "${mensaje.mensaje} ${mensaje.hora.substring(11, 16)}", // hora y minuto al lado del mensaje
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat con ${widget.nombreReceptor}", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color(0xFF2F3640),
      ),
      backgroundColor: Color(0xFF2F3640),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: mensajes.length,
              itemBuilder: (context, index) {
                return _buildMessage(mensajes[index], index);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Escribe un mensaje...",
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.green),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
