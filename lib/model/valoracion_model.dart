import 'package:paycar/model/usuario_modelo.dart';

class Valoracion {
  int id;
  Usuario pasajero;
  Usuario conductor;
  int valoracion;

  Valoracion({
    required this.id,
    required this.pasajero,
    required this.conductor,
    required this.valoracion,
  });

  factory Valoracion.fromJson(Map<String, dynamic> json) {
    return Valoracion(
      id: json['id'],
      pasajero: Usuario.fromJson(json['pasajero']),
      conductor: Usuario.fromJson(json['conductor']),
      valoracion: json['valoracion'],
    );
  }
}
