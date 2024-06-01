import 'package:paycar/model/usuarioGrupo_modelo.dart';

class Grupo {
  int id;
  String titulo;
  String descripcion;
  double consumoGasolina;
  int kilometrosRecorridos;
  double dineroGasolina;
  bool activado;
  bool borrado;
  List<UsuarioGrupo> usuarios;

  Grupo({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.consumoGasolina,
    required this.kilometrosRecorridos,
    required this.dineroGasolina,
    required this.activado,
    required this.borrado,
    required this.usuarios,
  });

  factory Grupo.fromJson(Map<String, dynamic> json) {
    return Grupo(
      id: json['id'] ?? 0,
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      consumoGasolina: (json['consumoGasolina'] ?? 0.0).toDouble(),
      kilometrosRecorridos: json['kilometrosRecorridos'] ?? 0,
      dineroGasolina: (json['dineroGasolina'] ?? 0.0).toDouble(),
      activado: json['activado'] ?? false,
      borrado: json['borrado'] ?? false,
      usuarios: json['usuarios'] != null
          ? List<UsuarioGrupo>.from(json['usuarios'].map((x) => UsuarioGrupo.fromJson(x)))
          : [],
    );
  }
}
