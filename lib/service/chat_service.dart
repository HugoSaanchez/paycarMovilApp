import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:paycar/model/mensaje_model.dart';

class ChatService extends ChangeNotifier {
  final String baseURL = 'https://paycar-x6i3.onrender.com/api';
  final storage = FlutterSecureStorage();

  Future<List<Map<String, dynamic>>> obtenerDetallesReceptores() async {
    final url = Uri.parse('$baseURL/chats');
    String? token = await storage.read(key: 'token');

    if (token == null) {
      throw Exception('No se encontró el token de autenticación');
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
         String stringResponse = const Utf8Decoder().convert(response.body.codeUnits);
        List<dynamic> data = jsonDecode(stringResponse);
        List<Map<String, dynamic>> usuarios = data.map((item) => item as Map<String, dynamic>).toList();
        return usuarios;
      } else {
        throw Exception('Error al obtener los detalles de los receptores: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al conectar al servidor: $e');
    }
  }
 
  Future<List<Mensaje>> obtenerMensajes(int idReceptor) async {
    int idEmisor = await getAuthenticatedUserId();
    String? token = await storage.read(key: 'token');
    if (token == null) {
      throw Exception('Token de autenticación no encontrado');
    }

    final url = Uri.parse('$baseURL/ver-mensajes?idEmisor=$idEmisor&idReceptor=$idReceptor');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
       String stringResponse = const Utf8Decoder().convert(response.body.codeUnits);
      List<dynamic> data = jsonDecode(stringResponse);
      return data.map((json) => Mensaje.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load messages: ${response.statusCode}');
    }
  }
  Future<int> getAuthenticatedUserId() async {
    String? id = await storage.read(key: 'userId');
    if (id == null) throw Exception('User ID not found in the secure storage');
    return int.parse(id);
  }

Future<String> enviarMensaje(int idReceptor, String mensaje) async {
  String? token = await storage.read(key: 'token');
  if (token == null) {
    throw Exception('Token de autenticación no encontrado');
  }

  final url = Uri.parse('$baseURL/enviar-mensaje?idReceptor=$idReceptor&mensaje=${Uri.encodeComponent(mensaje)}');
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    return "";
  } else {
    print('Error al enviar mensaje: ${response.body}');
    return 'Error al enviar mensaje: ${response.body}'; // Mostrar el cuerpo de la respuesta puede dar más información sobre el error
  }
}
Future<int> countUnreadMessages() async {
    String? token = await storage.read(key: 'token');
    if (token == null) {
      throw Exception('Token de autenticación no encontrado');
    }

    final url = Uri.parse('$baseURL/noleido');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return int.parse(response.body);
    } else {
      throw Exception('Error al obtener el número de mensajes no leídos: ${response.statusCode}');
    }
  }
Future<int> obtenerConteoMensajesNoLeidosDeUsuario(int idEmisor) async {
    String? token = await storage.read(key: 'token');
    if (token == null) {
      throw Exception('Token de autenticación no encontrado');
    }

    final url = Uri.parse('$baseURL/usuarios-noleidos?idEmisor=$idEmisor');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return int.parse(response.body);
    } else {
      throw Exception('Error al obtener el número de mensajes no leídos de un usuario: ${response.statusCode}');
    }
  }
Future<void> marcarMensajesComoLeidos(int idEmisor) async {
  String? token = await storage.read(key: 'token');
  if (token == null) {
    throw Exception('Token de autenticación no encontrado');
  }

  final url = Uri.parse('$baseURL/marcar-leidos?idEmisor=$idEmisor');
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Error al marcar mensajes como leídos: ${response.statusCode}');
  }
}


}
