import 'package:paycar/model/usuario_modelo.dart';

class Comentario {
  int id;
  Usuario pasajero;
  Usuario conductor;
  String comentario;

  Comentario({
    required this.id,
    required this.pasajero,
    required this.conductor,
    required this.comentario,
  });

  factory Comentario.fromJson(Map<String, dynamic> json) {
    return Comentario(
      id: json['id'],
      pasajero: Usuario.fromJson(json['pasajero']),
      conductor: Usuario.fromJson(json['conductor']),
      comentario: json['comentario'],
    );
  }
}
