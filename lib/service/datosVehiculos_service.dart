import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class DatosVehiculosService extends ChangeNotifier {
  final String baseURL = 'https://paycar-x6i3.onrender.com/api';
  final storage = FlutterSecureStorage();

  Future<List<String>> getMarcas() async {
    final url = Uri.parse('$baseURL/marcas');
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
        return decoded.cast<String>();
      } else {
        print('Error al obtener marcas: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error de conexión: $e');
      return [];
    }
  }

  Future<List<int>> getAniosPorMarca(String marca) async {
    final url = Uri.parse('$baseURL/anios?marca=$marca');
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
        return decoded.cast<int>();
      } else {
        print('Error al obtener años: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error de conexión: $e');
      return [];
    }
  }

  Future<List<String>> getModelosPorMarcaYAnio(String marca, int anio) async {
    final url = Uri.parse('$baseURL/modelos?marca=$marca&anio=$anio');
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
        return decoded.cast<String>();
      } else {
        print('Error al obtener modelos: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error de conexión: $e');
      return [];
    }
  }

  Future<List<String>> getVersionesPorMarcaAnioYModelo(String marca, int anio, String modelo) async {
    final url = Uri.parse('$baseURL/versiones?marca=$marca&anio=$anio&modelo=$modelo');
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
        return decoded.cast<String>();
      } else {
        print('Error al obtener versiones: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error de conexión: $e');
      return [];
    }
  }
Future<double> getMixtoPorMarcaAnioModeloVersion(String marca, int anio, String modelo, String version) async {
  final url = Uri.parse('$baseURL/mixto?marca=$marca&anio=$anio&modelo=$modelo&version=$version');
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
      return json.decode(stringResponse);
    } else {
      print('Error al obtener mixto: ${response.statusCode}');
      return 0.0;
    }
  } catch (e) {
    print('Error de conexión: $e');
    return 0.0;
  }
}
 Future<Map<String, dynamic>> getAlquiladoStatusPorMarcaAnioModeloVersion(String marca, int anio, String modelo, String version) async {
    final url = Uri.parse('$baseURL/alquilado?marca=$marca&anio=$anio&modelo=$modelo&version=$version');
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
        return json.decode(stringResponse);
      } else {
        print('Error al obtener estado de alquiler: ${response.statusCode}');
        return {"alquilado": 0};
      }
    } catch (e) {
      print('Error de conexión: $e');
      return {"alquilado": 0};
    }
  }
Future<String> alquilarVehiculo(String marca, int anio, String modelo, String version, String fechaInicio, String fechaFin) async {
    final url = Uri.parse('$baseURL/alquilar?marca=$marca&anio=$anio&modelo=$modelo&version=$version&fechaInicio=$fechaInicio&fechaFin=$fechaFin');
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
        return 'Vehículo alquilado exitosamente';
      } else {
        print('Error al alquilar vehículo: ${response.statusCode}');
        return 'Error al alquilar vehículo';
      }
    } catch (e) {
      print('Error de conexión: $e');
      return 'Error de conexión';
    }
  }

Future<List<Map<String, dynamic>>> getVehiculosAlquilados() async {
    final url = Uri.parse('$baseURL/vehiculos-alquilados');
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
        List<dynamic> decoded = json.decode(response.body);
        return decoded.cast<Map<String, dynamic>>();
      } else {
        print('Error al obtener vehículos alquilados: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error de conexión: $e');
      return [];
    }
  }
   Future<String> actualizarEstadoAlquilado() async {
    final url = Uri.parse('$baseURL/actualizar-alquilados');
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
        return 'Estado de alquiler actualizado exitosamente';
      } else {
        print('Error al actualizar estado de alquiler: ${response.statusCode}');
        return 'Error al actualizar estado de alquiler';
      }
    } catch (e) {
      print('Error de conexión: $e');
      return 'Error de conexión';
    }
  }
}
