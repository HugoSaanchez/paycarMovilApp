import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class UsuarioService extends ChangeNotifier {
  final String baseURL = 'http://10.0.2.2:8080/api';
  final storage = const FlutterSecureStorage();
  static String user = '';
  static String userId = '';
  static String userName = '';

   Future<String?> register(
    String nombre,
    String username,
    String password,
    
  
  ) async {
    final Map<String, dynamic> authData = {
      'nombre': nombre,
      'username': username,
      'password': password,
    };

   

    final url = Uri.parse('$baseURL/register');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          "Authorization": "Some token",
        },
        body: json.encode(authData),
      );

      final Map<String, dynamic> decoded = json.decode(response.body);

      if (decoded['success'] == true) {
        await storage.write(key: 'token', value: decoded['data']['token']);
        await storage.write(key: 'name', value: decoded['data']['name'].toString());
        return null; // Registro exitoso, devuelve null
      } else {
        if (decoded['data'] != null && decoded['data']['error'] != null) {
         
          return decoded['data']['error'];
        } 
      }
    } catch (e) {
      print('Error de conexión: $e');
      return 'Error de conexión: $e';
    }
  }

    
   Future<String?> login(String username, String password) async {
    final url = Uri.parse('$baseURL/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {
          'user': username,
          'password': password,
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = json.decode(response.body);

        // Asegúrate de que las claves existen en el JSON decodificado antes de acceder a ellas
        if (decoded.containsKey('token') && decoded.containsKey('nombre') && decoded.containsKey('id') && decoded.containsKey('rol')) {
          await storage.write(key: 'token', value: decoded['token']);
          await storage.write(key: 'name', value: decoded['nombre']);
          await storage.write(key: 'userId', value: decoded['id'].toString());
          await storage.write(key: 'user', value: decoded['username']);
          await storage.write(key: 'rol', value: decoded['rol']);
       
          await storage.write(key: 'activado', value: decoded['activado'].toString());
          await storage.write(key: 'borrado', value: decoded['borrado'].toString());

          return null; 
        } else {
          return 'Respuesta del servidor inválida';
        }
      } else {
        return 'Credenciales inválidas';
      }
    } catch (e) {
      print("Error: ${e.toString()}");
      return 'Error de red';
    }
  }


  Future<List<Map<String, dynamic>>> verAmigos() async {
    final url = Uri.parse('$baseURL/ver-amigos');
    final token = await storage.read(key: 'token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
          String stringResponse = const Utf8Decoder().convert(response.body.codeUnits);

        List<dynamic> decoded = json.decode(stringResponse);
        return decoded.cast<Map<String, dynamic>>(); // Convertir a lista de mapas
      } else {
        print('Error al obtener amigos: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error de conexión: $e');
      return [];
    }
  }

  Future<String> agregarAmigo(int idAmigo) async {
    final url = Uri.parse('$baseURL/agregar-amigo?idAmigo=$idAmigo');
    final token = await storage.read(key: 'token');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('Usuario agregado como amigo correctamente');
        return 'Usuario agregado como amigo correctamente';
      } else {
        print('Error al agregar amigo: ${response.statusCode}');
        return 'Error al agregar amigo: ${response.statusCode}';
      }
    } catch (e) {
      print('Error de conexión: $e');
      return 'Error de conexión: $e';
    }
  }

  // Método para obtener usuario por email
Future<Map<String, dynamic>?> buscarPorEmail(String email) async {
  final url = Uri.parse('$baseURL/buscar-por-email?email=$email');
  final token = await storage.read(key: 'token');

  try {
    final response = await http.get(
      url,
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      String stringResponse = const Utf8Decoder().convert(response.body.codeUnits);
      return json.decode(stringResponse) as Map<String, dynamic>;
    } else {
      print('Error al obtener usuario por email: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error de conexión: $e');
    return null;
  }
}

Future<void> logout() async {
    await storage.deleteAll(); 
    notifyListeners();
  }
    Future<int> obtenerNumeroAmigos() async {
    final url = Uri.parse('$baseURL/numero-amigos');
    final token = await storage.read(key: 'token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error al obtener el número de amigos: ${response.statusCode}');
        return 0;
      }
    } catch (e) {
      print('Error de conexión: $e');
      return 0;
    }
  }

Future<List<Map<String, dynamic>>> verAmigosConfirmados() async {
    final url = Uri.parse('$baseURL/ver-amigosConfirmado');
    final token = await storage.read(key: 'token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
          String stringResponse = const Utf8Decoder().convert(response.body.codeUnits);
        List<dynamic> decoded = json.decode(stringResponse);
        return decoded.cast<Map<String, dynamic>>(); // Convertir a lista de mapas
      } else {
        print('Error al obtener amigos: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error de conexión: $e');
      return [];
    }
  }
  Future<String> confirmarAmigo(int idAmigo) async {
    final url = Uri.parse('$baseURL/confirmar-amigo?idAmigo=$idAmigo');
    final token = await storage.read(key: 'token');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return 'Amigo confirmado correctamente';
      } else {
        return 'Error al confirmar amigo: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error de conexión: $e';
    }
  }
 Future<String?> verComentario(int idConductor, int idGrupo) async {
    final url = Uri.parse('$baseURL/ver-comentario?idConductor=$idConductor&idGrupo=$idGrupo');
    final token = await storage.read(key: 'token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        String stringResponse = const Utf8Decoder().convert(response.body.codeUnits);
        final String responseBody = stringResponse;
        final String comentario = responseBody.replaceFirst('Comentario: ', '');
        return comentario;
      } else {
        print('Error al obtener comentario: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error de conexión: $e');
      return null;
    }
  }

Future<int?> verValoracion(int idConductor, int idGrupo) async {
  final url = Uri.parse('$baseURL/ver-valoracion?idConductor=$idConductor&idGrupo=$idGrupo');
  final token = await storage.read(key: 'token');

  try {
    final response = await http.get(
      url,
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final String responseBody = response.body.trim();
      final String valoracionString = responseBody.replaceFirst('ValoraciÃ³n: ', '');
      print("la valoracion es  $valoracionString");
      final int valoracion = int.parse(valoracionString);
      return valoracion;
    } else {
      print('Error al obtener valoración: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error de conexión: $e');
    return null;
  }
}

 Future<String> valorarUsuario(int idConductor, int valoracion, int idGrupo) async {
    final url = Uri.parse('$baseURL/valorar-usuario?idConductor=$idConductor&valoracion=$valoracion&idGrupo=$idGrupo');
    final token = await storage.read(key: 'token');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('Usuario valorado correctamente');
        return 'Usuario valorado correctamente';
      } else {
        print('Error al valorar usuario: ${response.statusCode}');
        return 'Error al valorar usuario: ${response.statusCode}';
      }
    } catch (e) {
      print('Error de conexión: $e');
      return 'Error de conexión: $e';
    }
  }

  Future<String> comentarUsuario(int idConductor, String comentario, int idGrupo) async {
    final url = Uri.parse('$baseURL/comentar-usuario?idConductor=$idConductor&comentario=$comentario&idGrupo=$idGrupo');
    final token = await storage.read(key: 'token');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('Comentario agregado correctamente');
        return 'Comentario agregado correctamente';
      } else {
        print('Error al agregar comentario: ${response.statusCode}');
        return 'Error al agregar comentario: ${response.statusCode}';
      }
    } catch (e) {
      print('Error de conexión: $e');
      return 'Error de conexión: $e';
    }
  }
  Future<Map<String, dynamic>?> verEstadisticas() async {
  final url = Uri.parse('$baseURL/ver-estadisticas');
  final token = await storage.read(key: 'token');

  try {
    final response = await http.get(
      url,
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      print('Error al obtener estadísticas: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error de conexión: $e');
    return null;
  }
}

Future<List<Map<String, dynamic>>> verTodosLosComentarios() async {
    final url = Uri.parse('$baseURL/comentarios');
    final token = await storage.read(key: 'token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
         String stringResponse = const Utf8Decoder().convert(response.body.codeUnits);
        List<dynamic> decoded = json.decode(stringResponse);
        return decoded.cast<Map<String, dynamic>>();
      } else {
        print('Error al obtener comentarios: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error de conexión: $e');
      return [];
    }
  }

  Future<double> verMediaValoracion() async {
    final url = Uri.parse('$baseURL/valoraciones');
    final token = await storage.read(key: 'token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    print(response.statusCode);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return decoded['mediaValoracion'] ?? 0.0;
      } else {
        print('Error al obtener media de valoraciones: ${response.statusCode}');
        return 0.0;
      }
    } catch (e) {
      print('Error de conexión: $e');
      return 0.0;
    }
  }

  Future<String> rechazarAmigo(int idAmigo) async {
  final url = Uri.parse('$baseURL/rechazar-amigo?idAmigo=$idAmigo');
  final token = await storage.read(key: 'token');

  try {
    final response = await http.put(
      url,
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return 'Solicitud de amistad rechazada correctamente';
    } else {
      return 'Error al rechazar solicitud de amistad: ${response.statusCode}';
    }
  } catch (e) {
    return 'Error de conexión: $e';
  }
}



  }





