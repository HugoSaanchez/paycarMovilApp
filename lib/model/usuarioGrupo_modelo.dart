import 'package:paycar/model/grupo_modelo.dart';
import 'package:paycar/model/usuario_modelo.dart';

class UsuarioGrupo {
  Usuario usuario;
  Grupo grupo;
  String rol;
  double costepagado;
  double costetotal;

  UsuarioGrupo({
    required this.usuario,
    required this.grupo,
    required this.rol,
    required this.costepagado,
    required this.costetotal,
  });

  factory UsuarioGrupo.fromJson(Map<String, dynamic> json) {
    return UsuarioGrupo(
      usuario: Usuario.fromJson(json['usuario']),
      grupo: Grupo.fromJson(json['grupo']),
      rol: json['rol'],
      costepagado: (json['costepagado'] as num).toDouble(),
      costetotal: (json['costetotal'] as num).toDouble(),
    );
  }
}
