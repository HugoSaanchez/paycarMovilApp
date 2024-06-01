import 'package:paycar/model/datosVehiculo_model.dart';
class DatosVehiculos {
  int? id;
  String marca;
  int anio;
  String modelo;
  String version;
  String? mixto;
  bool alquilado;
  DateTime? fechaInicio;
  DateTime? fechaFin;

  DatosVehiculos({
    this.id,
    required this.marca,
    required this.anio,
    required this.modelo,
    required this.version,
    this.mixto,
    this.alquilado = false,
    this.fechaInicio,
    this.fechaFin,
  });

  factory DatosVehiculos.fromJson(Map<String, dynamic> json) {
    return DatosVehiculos(
      id: json['id'],
      marca: json['marca'],
      anio: json['anio'],
      modelo: json['modelo'],
      version: json['version'],
      mixto: json['mixto'],
      alquilado: json['alquilado'],
      fechaInicio: json['fecha_inicio'] != null ? DateTime.parse(json['fecha_inicio']) : null,
      fechaFin: json['fecha_fin'] != null ? DateTime.parse(json['fecha_fin']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'marca': marca,
      'anio': anio,
      'modelo': modelo,
      'version': version,
      'mixto': mixto,
      'alquilado': alquilado,
      'fecha_inicio': fechaInicio?.toIso8601String(),
      'fecha_fin': fechaFin?.toIso8601String(),
    };
  }
}
