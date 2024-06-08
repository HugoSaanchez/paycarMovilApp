import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:paycar/model/grupo_modelo.dart';

class GrupoService extends ChangeNotifier {
  final String baseURL = 'http://10.0.2.2:8080/api';
  final storage = const FlutterSecureStorage();

  // Método para crear un grupo
  Future<String?> createGroup(
    String titulo,
    String descripcion,
    double consumoGasolina,
    double kilometrosRecorridos,
    double dineroGasolina,
  ) async {
    final String? token = await storage.read(key: 'token'); // Leer el token almacenado

    final Map<String, dynamic> groupData = {
      'titulo': titulo,
      'descripcion': descripcion,
      'consumoGasolina': 0,
      'kilometrosRecorridos': 0,
      'dineroGasolina': 0,
      'activado': true,
      'borrado': false,
   
    };

    final url = Uri.parse('$baseURL/crear-grupo');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // Incluye el token en la solicitud
        },
        body: json.encode(groupData),
      );

      if (response.statusCode == 200) {
        final String grupoCreado = response.body;
        return grupoCreado; 
      } else {
        final Map<String, dynamic> decoded = json.decode(response.body);
  
        return 'Error: ${decoded['message'] ?? 'Unknown error'}';
        
      }
    } catch (e) {
      print('Error de conexión: $e');
      return 'Error de conexión: $e';
    }
  }

  Future<List<Map<String, dynamic>>> getGrupos() async {
    final String? token = await storage.read(key: 'token'); // Leer el token almacenado
    final url = Uri.parse('$baseURL/grupos');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // Incluye el token en la solicitud
        },
      );

      if (response.statusCode == 200) {
        String stringResponse = const Utf8Decoder().convert(response.body.codeUnits);
        final List<dynamic> decoded = json.decode(stringResponse);
        final List<Map<String, dynamic>> grupos = decoded.map((group) {
          return {
            'id': group['id'],
            'titulo': group['titulo'],
            'descripcion': group['descripcion'],
            'consumoGasolina': group['consumoGasolina'],
            'kilometrosRecorridos': group['kilometrosRecorridos'],
            'dineroGasolina': group['dineroGasolina'],
            'activado': group['activado'],
            'borrado': group['borrado'],
            'usuarios': List<int>.from(group['usuarios']), 
          };
        }).toList();
        return grupos;
      } else {
      String stringResponse = const Utf8Decoder().convert(response.body.codeUnits);
        final Map<String, dynamic> decoded = json.decode(stringResponse);
        print('Error: ${decoded['message']}');
        return [];
      }
    } catch (e) {
      print('Error de conexión: $e');
      return [];
    }
  }

   Future<Map<String, dynamic>?> getUsuarioRolNombre(int usuarioId, int grupoId) async {
    final String? token = await storage.read(key: 'token'); // Leer el token almacenado
    final url = Uri.parse('$baseURL/usuario-grupo?usuarioId=$usuarioId&grupoId=$grupoId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // Incluye el token en la solicitud
        },
      );

      if (response.statusCode == 200) {
        String stringResponse = const Utf8Decoder().convert(response.body.codeUnits);
        final Map<String, dynamic> decoded = json.decode(stringResponse);
        return {
          'id' : decoded['id'],
          'nombre': decoded['nombre'],
          'rol': decoded['rol']
        };
      } else {
        
          String stringResponse = const Utf8Decoder().convert(response.body.codeUnits);
        final Map<String, dynamic> decoded = json.decode(stringResponse);
        print('Error: ${decoded['error']}');
        return null;
      }
    } catch (e) {
      print('Error de conexión: $e');
      return null;
    }
  }

Future<Map<String, dynamic>?> calcularCostoViaje(int grupoId) async {
  final String? token = await storage.read(key: 'token'); // Leer el token almacenado

  final url = Uri.parse('$baseURL/calcular-costo-viaje?grupoId=$grupoId');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token', // Incluye el token en la solicitud
      },
    );

    if (response.statusCode == 200) {
     String stringResponse = const Utf8Decoder().convert(response.body.codeUnits);
        final Map<String, dynamic> decoded = json.decode(stringResponse);
      return {
        'costoViaje': decoded['costoViaje'],
        'tituloGrupo': decoded['tituloGrupo'],
        'grupoId': decoded['grupoId']
      };
    } else {
      print('Error al calcular el costo del viaje: ${response.body}');
      return null;
    }
  } catch (e) {
    print('Error de conexión: $e');
    return null;
  }
}

Future<String?> editarGrupo(int grupoId, double consumoGasolina, int kilometrosRecorridos, double dineroGasolina) async {
  final String? token = await storage.read(key: 'token'); // Leer el token almacenado

  final Map<String, dynamic> grupoData = {
    'consumoGasolina': consumoGasolina,
    'kilometrosRecorridos': kilometrosRecorridos,
    'dineroGasolina': dineroGasolina,
  };

  final url = Uri.parse('$baseURL/editar-grupo?grupoId=$grupoId');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token', // Incluye el token en la solicitud
      },
      body: json.encode(grupoData),
    );

    if (response.statusCode == 200) {
      return 'Grupo actualizado exitosamente';
    } else {
      final Map<String, dynamic> decoded = json.decode(response.body);
      return 'Error: ${decoded['message'] ?? 'Unknown error'}';
    }
  } catch (e) {
    print('Error de conexión: $e');
    return 'Error de conexión: $e';
  }
}


 Future<Grupo?> obtenerGrupo(int grupoId) async {
    final String? token = await storage.read(key: 'token'); // Leer el token almacenado
    final url = Uri.parse('$baseURL/obtener-grupo?grupoId=$grupoId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // Incluye el token en la solicitud
        },
      );

      if (response.statusCode == 200) {
        String stringResponse = const Utf8Decoder().convert(response.body.codeUnits);
        final Map<String, dynamic> decoded = json.decode(stringResponse);
        return Grupo.fromJson(decoded);
      } else {
        String stringResponse = const Utf8Decoder().convert(response.body.codeUnits);
        final Map<String, dynamic> decoded = json.decode(stringResponse);
        print('Error: ${decoded['message']}');
        return null;
      }
    } catch (e) {
      print('Error de conexión: $e');
      return null;
    }
  }


Future<Map<String, double>?> calcularDiferenciaCoste(int grupoId) async {
  final String? token = await storage.read(key: 'token'); // Leer el token almacenado

  final url = Uri.parse('$baseURL/calcular-diferencia-coste?grupoId=$grupoId');

  try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token', // Incluye el token en la solicitud
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body);
      return decoded.map((key, value) => MapEntry(key, value.toDouble()));
    } else {
      print('Error al calcular la diferencia de coste: ${response.body}');
      return null;
    }
  } catch (e) {
    print('Error de conexión: $e');
    return null;
  }
}

Future<Map<String, dynamic>?> actualizarCostepagado(int grupoId, int usuarioId) async {
  final String? token = await storage.read(key: 'token'); // Leer el token almacenado

  final url = Uri.parse('$baseURL/actualizar-costepagado');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token', // Incluye el token en la solicitud
      },
      body: {
        'grupoId': grupoId.toString(),
        'usuarioId': usuarioId.toString(),
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body);
      return {
        'usuarioId': decoded['usuarioId'],
        'grupoId': decoded['grupoId'],
        'costepagadoUsuario': decoded['costepagadoUsuario'],
        'costetotalUsuario': decoded['costetotalUsuario'],
        'costepagadoConductor': decoded['costepagadoConductor'],
      };
    } else {
      print('Error al actualizar el costepagado: ${response.body}');
      return null;
    }
  } catch (e) {
    print('Error de conexión: $e');
    return null;
  }
}

Future<String?> crearInvitacion(int grupoId) async {
    final String? token = await storage.read(key: 'token'); // Leer el token almacenado
    final url = Uri.parse('$baseURL/crear-invitacion/$grupoId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // Incluye el token en la solicitud
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = json.decode(response.body);
        return decoded['url']; // Devolvemos la URL de la invitación
      } else {
        final Map<String, dynamic> decoded = json.decode(response.body);
        print('Error: ${decoded['message']}');
        return null;
      }
    } catch (e) {
      print('Error de conexión: $e');
      return null;
    }
  }
  Future<String?> obtenerInvitacion(int grupoId) async {
  final String? token = await storage.read(key: 'token'); // Leer el token almacenado
  final url = Uri.parse('$baseURL/obtener-invitacion?grupoId=$grupoId');

  try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token', // Incluye el token en la solicitud
      },
    );

    if (response.statusCode == 200) {
      final String invitacionUrl = response.body;
      return invitacionUrl;
    } else {
      print('Error al obtener la invitación: ${response.body}');
      return null;
    }
  } catch (e) {
    print('Error de conexión: $e');
    return null;
  }
}
  Future<bool> joinGroup(String codigoInvitacion) async {
    String? token = await storage.read(key: 'token');
    if (token == null) {
      throw Exception('Token de autenticación no encontrado');
    }

    final url = Uri.parse('$baseURL/unirse-grupo?codigo=$codigoInvitacion');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Error al unirse al grupo: ${response.body}');
      return false;
    }
  }


Future<bool> borrarGrupo(int id) async {
  final String? token = await storage.read(key: 'token'); // Leer el token almacenado

  final url = Uri.parse('$baseURL/grupo/borrar?id=$id');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token', // Incluye el token en la solicitud
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Error al borrar el grupo: ${response.body}');
      return false;
    }
  } catch (e) {
    print('Error de conexión: $e');
    return false;
  }
}

 Future<bool> salirGrupo(int grupoId) async {
    final String? token = await storage.read(key: 'token'); // Leer el token almacenado

    final url = Uri.parse('$baseURL/grupo/salir?grupoId=$grupoId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // Incluye el token en la solicitud
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error al salir del grupo: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error de conexión: $e');
      return false;
    }
  }

}
