import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class DatosVehiculosService extends ChangeNotifier {
  final String baseURL = 'http://10.0.2.2:8080';
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
        List<dynamic> decoded = json.decode(response.body);
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
        List<dynamic> decoded = json.decode(response.body);
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
        List<dynamic> decoded = json.decode(response.body);
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
        List<dynamic> decoded = json.decode(response.body);
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
      return json.decode(response.body);
    } else {
      print('Error al obtener mixto: ${response.statusCode}');
      return 0.0;
    }
  } catch (e) {
    print('Error de conexión: $e');
    return 0.0;
  }
}



}
